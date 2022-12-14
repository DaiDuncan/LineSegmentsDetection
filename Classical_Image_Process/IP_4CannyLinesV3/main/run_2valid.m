%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: pay attention to the following things
%   1 the initial variables
%       - FLAG_VALID = 1: only for valid process: flag is 1
%       - index: initial index of output_data
%   2 the path  (in 'config_path.m': line 66)
%       - imgInputPath
%       - imgInputPath
%       - imgName
%       - imgOutputPath
% 
% Things you need to modify for validation
%   1 index limit: set the limitation for index of output_data (in 'train1_singleSample.m': line 25) 
%   2 hyperparameters optimization (in 'train1_singleSample.m': line 33)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% run script:
clear;
config_path;

global is_plot is_save;
is_plot = 0; is_save = 0;

FLAG_VALID = 1; % only for valid process: flag is 1
index = 1;


%% valid single sample
img_rgb = imread([imgInputPath, filesep, folderName, filesep, imgName]);

t1 = datestr(now);
train1_singleSample(img_rgb, folderName, imgName, imgOutputPath);
t2 = datestr(now);


%% valid single folder
t1 = datestr(now);
folderName = '2022-04-28_13-09-34';
train2_singleFolder(imgInputPath, folderName, imgOutputPath);
t2 = datestr(now);

output_data = select_data_with_label(output_data);


t = clock; % Get current time
%%% 1 original output_data (all records are with labels)
% example: out_valid_0922_1347.mat
fname = ['out_valid_', ...
              num2str(t(2:3), '%02d'), '_', ...   % -month-day_
              num2str(t(4:5), '%02d'), '_', folderName, '(CannyLines).mat']; % hour min

save_data_path = [imgOutputPath, filesep, fname];  
save(save_data_path, 'output_data');


load chirp
sound(y,Fs)
%% valid all folders: 
load chirp
sound(y,Fs)

t1 = datestr(now);
train3_folders(imgInputPath, imgOutputPath);
t2 = datestr(now);

%%% save data
output_data = select_data_with_label(output_data);

% metric = 'metric_RMSE_polyfit';
metric = 'metric_RMSE_vertical';
fprintf('(in run_2valid.m) Please set mean_metric_RMSE!!! metric_RMSE is "%s"', metric);
output_data = set_metric_RMSE(output_data, metric);   %  'metric_RMSE_vertical' or 'metric_RMSE_polyfit'


t = clock; % Get current time
%%% 1 original output_data (all records are with labels)
% example: out_valid_0922_1347.mat
fname = ['out_valid_', ...
              num2str(t(2:3), '%02d'), '_', ...   % -month-day_
              num2str(t(4:5), '%02d'), '(lsd).mat']; % hour min

save_data_path = [imgOutputPath, filesep, fname];  
save(save_data_path, 'output_data');


load chirp
sound(y,Fs)

% load handel
% sound(y,Fs)


clear y Fs t  fname  save_data_path;