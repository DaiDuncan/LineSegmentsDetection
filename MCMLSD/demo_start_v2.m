clear
clc
close all

% attention: filesep in linux is '/', in windows is '\' -> matlab will
% recognize it
addpath(genpath('code/'));
addpath('Imgs/');
addpath(genpath('edges-master/'));
addpath('v2/');

%%% dinggen test
% img = imread(['Imgs', filesep, 'P1040823hr.jpg']);
img = imread(['..\imgSamples', filesep, 'test1.png']);

% 1/16 size to the original image
% dinggen 08.26 test: full size
% img = imresize(img, [round(size(img,1)/4), round(size(img,2)/4)]);

%compute the kernel for the image size
%you only need to compute the kernal once for one an image size
% dinggen 2022.08.26 you only need to compute the kernal once for one type image size
[kernels, kernels_flip, kernel_params] =kernelInitialization(img);



%% 2022-04-28_14-02-34  2022-04-28_15-39-22    2022-04-28_16-21-50
imgPath = ['U:\my_projs\LineSegmentsDetection\imgSamples', filesep, '2022-04-28_16-21-50'];

imgSamples = dir(imgPath);
for k = 3:length(imgSamples)
    try
        img = imread([imgPath, filesep, imgSamples(k).name]);
    catch ME
        fprintf('There was a problem reading file #%d, "%s"\n', k, imgSamples(k).name);
        continue
    end 
    
    tmp = img;
    % 1/16 size to the original image
%     img = imresize(img, [round(size(img,1)/4), round(size(img,2)/4)]);
    
    ticId = tic;
    %the lines variable contains the detected line segmentations it arranged as
    %[x1 y1 x2 y2 probability]
    %The fullLines are the detected lines. It is arranged as [rho theta probability]
    [lines, fullLines] =lineSegmentation_HighRes(img, kernels, kernels_flip, kernel_params);
    display('Total time');
    toc(ticId)
    fig = figure;
    imshow(img);
    hold all
    %Order lines by probability
    lines = sortrows(lines, -5);
    
    linesNum = size(lines,1);
    plotLineNum = min(50, linesNum);
    for i = 1:plotLineNum
        %plot the top 90 lines
        line([lines(i,1) lines(i,3)], [lines(i,2) lines(i,4)],'Color', rand(1,3), 'LineWidth', 2.5);
    end
%     imwrite(fig, ['..\g_output', filesep, imgSamples(k).name(1:end-4), filesep, '_1.png']);
    saveas(fig, ['U:\my_projs\LineSegmentsDetection\g_output', filesep, imgSamples(k).name(1:end-4), '_1.png']);


    %please use code in Evaluation code.zip to evaluate the performance of the line segmentation algorithm
    [lines2] = mcmlsd2Algo(lines,img);
    fig = figure;
    imshow(img);
    hold all
    %Order lines by probability
    lines2 = sortrows(lines2, -5);
    
    linesNum = size(lines2,1);
    plotLineNum = min(50, linesNum);
    for i = 1:plotLineNum
        %plot the top 90 lines
        line([lines2(i,1) lines2(i,3)], [lines2(i,2) lines2(i,4)],'Color', rand(1,3), 'LineWidth', 2.5);
    end
%     imwrite(fig, ['..\g_output', filesep, imgSamples(k).name(1:end-4), filesep, '_2.png']);
    saveas(fig, ['U:\my_projs\LineSegmentsDetection\g_output', filesep, imgSamples(k).name(1:end-4), '_2.png']);
end
