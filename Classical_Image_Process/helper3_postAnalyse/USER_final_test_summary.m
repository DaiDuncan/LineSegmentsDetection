%% create table 
OUTPUT_ELEMENTS = 4 + 12 + 2 +8 + 1;   % 26 + 1 elements in one row (imgFolderName, imgName, runTime_cpp, runTime_matlab, windows_features, left_border_pos, left_border_label, right_border_pos, right_border_label, metric_RMSE, scale, angle_expect, angle_tolerance, windowWidth, windowStepSize, decision_criter, prior_mandrel_percent)
sz = [1508 OUTPUT_ELEMENTS];
varTypes = {'string', 'string', 'single', 'single', ...
    'single', 'single', 'single', 'single', 'single', 'single', 'single', 'single', 'single', 'single', 'single', 'single',...
    'single', 'single', ...
    'single', 'single', 'single', 'uint8', 'uint8', 'string', 'single', 'logical', 'string'};  % by using class() to check the type of variable
varNames = {'folderName', 'imgName', 'runTime_cpp', 'runTime_matlab', ...
    'left_window_start', 'left_pos1', 'left_pos2', 'left_border_label', 'left_num', 'left_len', 'right_window_start', 'right_pos1', 'right_pos2', 'right_border_label', 'right_num', 'right_len',...
    'metric_RMSE_vertical', 'metric_RMSE_polyfit', ...
    'scale', 'angle_expect', 'angle_tolerance', 'windowWidth', 'windowStepSize', 'decision_criter', 'prior_excluded_middle_percent', 'is_labeled', 'method'};

% Notice: angle's unit is degree
test_result_lsd = table('Size',sz, 'VariableTypes',varTypes, 'VariableNames',varNames);
test_result_mcmlsd = table('Size',sz, 'VariableTypes',varTypes, 'VariableNames',varNames); 
test_result_canny = table('Size',sz, 'VariableTypes',varTypes, 'VariableNames',varNames);
test_result_ed = table('Size',sz, 'VariableTypes',varTypes, 'VariableNames',varNames);

test_result_lsd(:, 1:26) = output_data_lsd;  test_result_lsd.method(1:end) = 'LSD';
test_result_mcmlsd(:, 1:26) = output_data_mcmlsd;  test_result_mcmlsd.method(1:end) = 'MCMLSD';
test_result_canny(:, 1:26) = output_data_canny;  test_result_canny.method(1:end) = 'CannyPF';
test_result_ed(:, 1:26) = output_data_ed;  test_result_ed.method(1:end) = 'EDLines';

result_summary = [test_result_lsd; test_result_mcmlsd; test_result_canny; test_result_ed];
result_summary.runTime = result_summary.runTime_cpp + result_summary.runTime_matlab;

clear  OUTPUT_ELEMENTS  sz  varTypes  varNames;

%%
% result_summary.RMSE_lsd = output_data_lsd.metric_RMSE_vertical;
% result_summary.runTime_cpp_lsd = output_data_lsd.runTime_cpp;
% result_summary.runTime_matlab_lsd = output_data_lsd.runTime_matlab;
% result_summary.runTime_lsd = result_summary.runTime_cpp_lsd + result_summary.runTime_matlab_lsd;
% 
% result_summary.RMSE_mcmlsd = output_data_mcmlsd.metric_RMSE_vertical;
% result_summary.runTime_cpp_mcmlsd = output_data_mcmlsd.runTime_cpp;
% result_summary.runTime_matlab_mcmlsd = output_data_mcmlsd.runTime_matlab;
% result_summary.runTime_mcmlsd = result_summary.runTime_cpp_mcmlsd + result_summary.runTime_matlab_mcmlsd;
% 
% result_summary.RMSE_canny = output_data_canny.metric_RMSE_vertical;
% result_summary.runTime_cpp_canny = output_data_canny.runTime_cpp;
% result_summary.runTime_matlab_canny = output_data_canny.runTime_matlab;
% result_summary.runTime_canny = result_summary.runTime_cpp_canny + result_summary.runTime_matlab_canny;
% 
% result_summary.RMSE_ed = output_data_ed.metric_RMSE_vertical;
% result_summary.runTime_cpp_ed = output_data_ed.runTime_cpp;
% result_summary.runTime_matlab_ed = output_data_ed.runTime_matlab;
% result_summary.runTime_ed = result_summary.runTime_cpp_ed + result_summary.runTime_matlab_ed;

%%
figure;
% h_boxplot = boxplot([result_summary.RMSE_lsd,result_summary.RMSE_ed,result_summary.RMSE_canny,result_summary.RMSE_mcmlsd]);
h = findobj(gca,'Tag','Median');
% set(h,'Visible','off');
set(h,{'xData'},{[1];[2];[3]}, ...
      {'yData'},{[0.1];[0.2];[0.3]}, ...
      'marker','*','color','k');
  
% xgroupdata = ['LSD', 'MCMLSD', 'EDLines', 'CannyPF'];
% ydata = [result_summary.metric_RMSE_vertical, result_summary.runTime];
% h_boxchart = boxchart(result_summary.method, result_summary.metric_RMSE_vertical);  % if ydata is independent vector -> xgroupdata can't be used




%% RMSE
methodOrder = {'LSD', 'CannyPF', 'EDLines', 'MCMLSD'};
namedMethod = categorical(result_summary.method, methodOrder);

meanRMSE = groupsummary(result_summary.metric_RMSE_vertical,namedMethod,'mean');

b = boxchart(namedMethod, result_summary.metric_RMSE_vertical);
title('Distribution of RMSE')
xlabel('Methods')
ylabel('RMSE(pixels)')

hold on
plot(meanRMSE,'-o')
hold off
l = legend(["RMSE", "RMSE Mean"])
set(l,'box','off', 'Location', 'northeastoutside')


b.JitterOutliers = 'on';
b.MarkerStyle = '.';
% ylim([0 700])

%% run time
methodOrder = {'LSD', 'CannyPF', 'EDLines', 'MCMLSD'};
namedMethod = categorical(result_summary.method, methodOrder);

meanRunTime = groupsummary(result_summary.runTime,namedMethod,'mean');

b = boxchart(namedMethod, result_summary.runTime);
title('Distribution of run time')
xlabel('Methods')
ylabel('run time(s)')

hold on
plot(meanRunTime,'-o')
hold off
l = legend(["Runtime", "Runtime Mean"])
set(l,'box','off', 'Location', 'northeastoutside')


b.JitterOutliers = 'on';
b.MarkerStyle = '.';
ylim([0 0.6])