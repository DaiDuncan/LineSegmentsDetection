from yacs.config import CfgNode as CN

RESNETS = CN()
RESNETS.NUM_GROUPS = 1
RESNETS.WIDTH_PER_GROUP = 64
#RESNETS.STRIDE_IN_1X1 = True

# RESNETS.TRANS_FUNC = "BottleneckWithFixedBatchNorm"
RESNETS.NORM_FUNC = 'BatchNorm'
RESNETS.STEM_FUNC = "Stem"
RESNETS.STEM_OUT_CHANNELS = 64
RESNETS.STEM_KERNEL_SIZE = 7
RESNETS.STEM_RETURN_FEATURE = False
RESNETS.BACKBONE_OUT_CHANNELS = 256 * 4
RESNETS.RES2_OUT_CHANNELS = 256


RESNETS.STAGE_SPECS = (3,4,6,3) # ResNet 50

