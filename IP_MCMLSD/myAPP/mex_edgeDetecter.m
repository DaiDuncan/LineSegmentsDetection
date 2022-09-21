function [runTime_PHT, runTime_MCM, edgeLines] = mex_edgeDetecter(img)
% Note: This is not mex function, but just in consistent to the train,
% valid and futher test scripts
%
% Input(s):
%   - image: can be either rgb or grayscale image, but double image (in matlab) is not allowed
%           in function `main_edge` (line 13-16: the input image will be double image)
%
%   - selectedLineNumber: hyperparameter
%
%
% Output(s):
%   - runTime_PHT
%   - runTime_MCM
%   - edgeLines: arranged in one row (x1, x2, x3, x4)

global kernels   kernels_flip   kernel_params;
%% step1: PHT -> LSD
% The lines variable contains the detected line segmentations it arranged as [x1 y1 x2 y2 probability]
% The fullLines are the detected lines. It is arranged as [rho theta probability]
ticId1 = tic;
[lines, fullLines] = lineSegmentation_HighRes(img, kernels, kernels_flip, kernel_params);
runTime_PHT = toc(ticId1);
disp(['Running time in PHT/LSD = ', num2str(runTime_PHT), ' second(s)']);


%% step2: MCM -> get high score lines
ticId2 = tic;
% The lines2 is arranged as [x1 y1 x2 y2 probability score], see mcmlsd2Algo() to know what score is
[lines2] = mcmlsd2Algo(lines, img);
runTime_MCM = toc(ticId2);
disp(['Running time in MCM = ', num2str(runTime_MCM), ' second(s)']);

edgeLines = sortrows(lines2, -6);
end




