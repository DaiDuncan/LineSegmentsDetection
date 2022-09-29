%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: pay attention to the following things
%   1 the initial variables
%       - FLAG_VALID = 0: only for valid process: flag is 1
%       - index: initial index of output_data
%   2 the path  (in 'main0_header.m': line 43)
%       - imgInputPath
%       - imgInputPath
%       - imgName
%       - imgOutputPath
% 
% Things you need to modify for testing
%   1 set the optimized hyperparameters (in line 25)
%   2 index limit: set the limitation for index of output_data (in 'train1_singleSample.m': line 25)
%   3 plot and analyzing (in 'train1_singleSample.m': line 118)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% run script: 
clear; clc; close;
main0_header;

global is_plot is_save;
is_plot = 1; is_save = 1;

FLAG_VALID = 0;  % only for valid process: flag is 1
index = 1;
%% TODO: optimized hyperparameters
load('U:\my_projs\LineSegmentsDetection\IP_2EDLines\myAPP\dataAnalyse\result_0929_0828.mat');
result = sortrows(result,'mean_metric_RMSE','ascend');
output = result(1, :);

scale = output.scale; 
        
angle_expect = output.angle_expect ;
angle_tolerance = output.angle_tolerance;   %angle_tolerance = 9;
windowWidth = output.windowWidth; windowWidth = single(windowWidth);
windowStepSize = output.windowStepSize; windowStepSize = single(windowStepSize);
decision_criter = output.decision_criter; decision_criter = char(decision_criter);   %decision_criter = 'length*number';
prior_excluded_middle_percent = output.prior_excluded_middle_percent;   prior_excluded_middle_percent = 5/16;

img_rgb = imread([imgInputPath, filesep, folderName, filesep, imgName]);
resizeImageHeight = size(img_rgb, 1) / scale;  resizeImageWidth = size(img_rgb, 2) / scale;

%% test all folders
% TODO: imgInputPath (imgOutputPath is determained according to the platform: Pool or PC)
imgInputPath = 'D:\dataset_test'; % portable HDD or network driver


t1 = datestr(now);
train3_folders(imgInputPath, imgOutputPath);
t2 = datestr(now);


%%% save data
t = clock; % Get current time
% example: out_test_0922_1347.mat
fname = ['out_test_', ...
              num2str(t(2:3), '%02d'), '_', ...   % -month-day_
              num2str(t(4:5), '%02d'), '.mat']; % hour min


save_data_path = [imgOutputPath, filesep, folderName, filesep, fname];
save(save_data_path, 'output_data');

load chirp
sound(y,Fs)

clear  t fname save_data_path y Fs;

