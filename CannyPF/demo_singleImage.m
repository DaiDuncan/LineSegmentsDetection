addpath('./mexfile'); 

%%
img_origin=imread('U:\my_projs\LineSegmentsDetection\CannyLinesPF\Images\_origin_rgb.png');

img_gray = rgb2gray(img_origin);  
img = double(img_gray);
GaussSize = uint8(3);
VMGradient = 70.0;

ticId = tic;
[edgeMap, edgeChains] = cannyPF_mex(img, GaussSize, VMGradient);
toc(ticId)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 show the image after filtered by CannyPF
img_cannyPF = edgeMap;
img_edges = zeros(size(img_gray), 'like', img_gray);

imshow(edgeMap);

% 2 show the image after edge chain judgment criteria
x_range = size(img_gray, 2);
edge_count = zeros(x_range,1);
edge_number = size(edgeChains, 1);  

for edgeIdx = 1:edge_number
    one_edge_chain = edgeChains{edgeIdx};
    point_number = size(one_edge_chain, 1);
    for point_idx = 1:point_number
        x_coord = one_edge_chain(point_idx, 1) + 1;  % in C/C++ index/coordinate 0-based
        y_coord = one_edge_chain(point_idx, 2) + 1;

        img_edges(y_coord, x_coord) = 255;
        edge_count(x_coord) = edge_count(x_coord) + 1;
    end
end

img_all = [img_gray, img_cannyPF, img_edges];

% 3 calculate the distribution of edgeChains
edge_range = size(edge_count,1);
edge_segment_range = idivide(edge_range, uint16(4));

[max_val_one, max_idx_one] = max(edge_count(1:edge_segment_range, :));
[max_val_two, max_idx_two] = max(edge_count(end-edge_segment_range+1:end, :));
max_idx_two = max_idx_two + edge_range - edge_segment_range;

fig = figure;
imshow(img_gray);
hold on;
plot([max_idx_one, max_idx_one], [1,2064], 'Color', 'r', 'LineWidth', 2);
plot([max_idx_two, max_idx_two], [1,2064], 'Color', 'r', 'LineWidth', 2);

%     imwrite(fig, ['..\g_output', filesep, imgSamples(k).name(1:end-4), filesep, '.png']);
% saveas(fig, ['U:\my_projs\g_output', filesep, imgSamples(k).name(1:end-4), '_label.png']);

% save data
% save_path = ['U:\my_projs\g_output', filesep, imgSamples(k).name(1:end-4), '_data_edge_count.mat'];
% save(save_path, 'edge_count');
% close(fig);