#!/usr/bin/env python3
"""Process an image with the trained neural network
Usage:
    demo.py [options] <yaml-config> <checkpoint> <images>...
    demo.py (-h | --help )

Arguments:
   <yaml-config>                 Path to the yaml hyper-parameter file
   <checkpoint>                  Path to the checkpoint
   <images>                      Path to images

Options:
   -h --help                     Show this screen.
   -d --devices <devices>        Comma seperated GPU devices [default: 0]
"""

import os
import os.path as osp
import pprint
import random

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import skimage.io
import skimage.transform
import torch
import yaml
from docopt import docopt
import scipy.io as sio

import lcnn
from lcnn.config import C, M
from lcnn.models.line_vectorizer import LineVectorizer
from lcnn.models.multitask_learner import MultitaskHead, MultitaskLearner
from lcnn.models.HT import hough_transform

from lcnn.postprocess import postprocess
from lcnn.utils import recursive_to

PLTOPTS = {"color": "#33FFFF", "s": 15, "edgecolors": "none", "zorder": 5}
cmap = plt.get_cmap("jet")
norm = mpl.colors.Normalize(vmin=0.9, vmax=1.0)
sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
sm.set_array([])


def c(x):
    return sm.to_rgba(x)


def main():
    args = docopt(__doc__)
    config_file = args["<yaml-config>"] or "config/wireframe.yaml"
    C.update(C.from_yaml(filename=config_file))
    M.update(C.model)
    pprint.pprint(C, indent=4)

    random.seed(0)
    np.random.seed(0)
    torch.manual_seed(0)

    device_name = "cpu"
    os.environ["CUDA_VISIBLE_DEVICES"] = args["--devices"]
    if torch.cuda.is_available():
        device_name = "cuda"
        torch.backends.cudnn.deterministic = True
        torch.cuda.manual_seed(0)
        print("Let's use", torch.cuda.device_count(), "GPU(s)!")
    else:
        print("CUDA is not available")
    device = torch.device(device_name)
    checkpoint = torch.load(args["<checkpoint>"], map_location=device)

    # Load model
    if os.path.isfile(C.io.vote_index):
        vote_index = sio.loadmat(C.io.vote_index)['vote_index']
    else:
        vote_index = hough_transform(rows=128, cols=128, theta_res=3, rho_res=1)
        sio.savemat(C.io.vote_index, {'vote_index': vote_index})  # original save the .mat data (> 1GB)
    vote_index = torch.from_numpy(vote_index).float().contiguous().to(device)
    print('load vote_index', vote_index.shape)

    model = lcnn.models.hg(
        depth=M.depth,
        head=lambda c_in, c_out: MultitaskHead(c_in, c_out),
        num_stacks=M.num_stacks,
        num_blocks=M.num_blocks,
        num_classes=sum(sum(M.head_size, [])),
        vote_index=vote_index,

    )
    model = MultitaskLearner(model)
    model = LineVectorizer(model)
    model.load_state_dict(checkpoint["model_state_dict"])
    model = model.to(device)
    model.eval()

    for imname in args["<images>"]:
        print(f"Processing {imname}")
        im = skimage.io.imread(imname)
        if im.ndim == 2:
            im = np.repeat(im[:, :, None], 3, 2)
        im = im[:, :, :3]
        im_resized = skimage.transform.resize(im, (512, 512)) * 255
        #  adapted normalization
        mean = [np.mean(im_resized[:,:,i]) for i in range(3)] 
        stddev = [np.std(im_resized[:,:,i]) for i in range(3)] 
        # image = (im_resized - M.image.mean) / M.image.stddev
        image = (im_resized - mean) / stddev
        image = torch.from_numpy(np.rollaxis(image, 2)[None].copy()).float()
        with torch.no_grad():
            input_dict = {
                "image": image.to(device),
                "meta": [
                    {
                        "junc": torch.zeros(1, 2).to(device),
                        "jtyp": torch.zeros(1, dtype=torch.uint8).to(device),
                        "Lpos": torch.zeros(2, 2, dtype=torch.uint8).to(device),
                        "Lneg": torch.zeros(2, 2, dtype=torch.uint8).to(device),
                    }
                ],
                "target": {
                    "jmap": torch.zeros([1, 1, 128, 128]).to(device),
                    "joff": torch.zeros([1, 1, 2, 128, 128]).to(device),
                },
                "mode": "testing",
            }
            H = model(input_dict)["preds"]

        ### !!! lines (2, 2, 2) 
        # lines[0][0]: [y00, x00]
        # lines[0][1]: [y01, x01]
        # lines[1][0]: [y10, x10]
        # lines[1][1]: [y11, x11]
        '''lines (2 lines)
        array([[[1.41094317e+01, 2.70200000e+03],
                [2.06198438e+03, 2.70200000e+03]],

                [[2.04900879e+03, 2.17125069e+02],
                [1.13395390e+00, 2.17125253e+02]]])
        '''
        lines = H["lines"][0].cpu().numpy() / 128 * im.shape[:2]  # resize back to the original im size
        scores = H["score"][0].cpu().numpy()
        for i in range(1, len(lines)):
            if (lines[i] == lines[0]).all():  # if find the same line at the first time: which implies duplicated lines
                lines = lines[:i]
                scores = scores[:i]
                break

        # postprocess lines to remove overlapped lines
        diag = (im.shape[0] ** 2 + im.shape[1] ** 2) ** 0.5
        nlines, nscores = postprocess(lines, scores, diag * 0.01, 0, False)

        for i, t in enumerate([0.97, 0.98, 0.99]):  # t is threshold for lines confidence
            plt.gca().set_axis_off()
            plt.subplots_adjust(top=1, bottom=0, right=1, left=0, hspace=0, wspace=0)
            plt.margins(0, 0)
            for (a, b), s in zip(nlines, nscores):
                if s < t:
                    continue
                plt.plot([a[1], b[1]], [a[0], b[0]], c=c(s), linewidth=2, zorder=s)
                plt.scatter(a[1], a[0], **PLTOPTS)
                plt.scatter(b[1], b[0], **PLTOPTS)
            plt.gca().xaxis.set_major_locator(plt.NullLocator())
            plt.gca().yaxis.set_major_locator(plt.NullLocator())
            plt.imshow(im)
            # plt.savefig(imname.replace(".png", f"-{t:.02f}.svg"), bbox_inches="tight")  # save in the path, where test.png is -> but change suffix .png to .svg
            plt.show()
            plt.close()


if __name__ == "__main__":
    main()
