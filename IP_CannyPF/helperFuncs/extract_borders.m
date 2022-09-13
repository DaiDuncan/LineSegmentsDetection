function  [left_border_index, right_border_index, windows_features, full_edges_filter_by_angle] = extract_borders(edges, scale, imageWidth, windowWidth, windowStepSize, ...
                                                                                                            angle_expect, angle_tolerance, prior_mandrel_percent) %, prior_mandrel_diameter, lenth_threshold, number_threshold)
% Description: From the detected edges, use moving window to count the
% edges number in the window (the edges should have a angle within the angle tolerance) and
% calculate the edges length in the window to give a rank to the index in x
% axis, from which we select the left and right border index.
%
% Inputs:
%   - edges: different edge detecters produce different types of edges.
%       for LSD: two endpoints (OpenCV)
%       for EDLines: two endpoints (OpenCV)
%       for CannyPF: edgeChains -> use the start and end points in the chain as endpoints
%       for MCMLSD: two endpoints
%       The elements in one row of `edges` is (x1, y1, x2, y2)
%   - scale (default is 4): the scale/resize size in x axis
%   - imageWidth (in pixels): the width of the original image (before resizing)
%   - windowWidth (in pixels): the width of the border (recommended: 10 ~ 40 pixels)
%   - windowStepSize (in pixels): (recommended: 1/4 of the window width)
%   - angle_expect (in rad): angle of inclination of the border (recomended: (90 degree /180*pi) rad)
%   - angle_tolerance: tolerance of the angle (recomended: (5 degree /180*pi) rad)
%   - lenth_threshold: to be determined after calculating in train dataset...
%   - number_threshold: to be determined after calculating in train dataset...
%   - prior_mandrel_percent:  the middle part to be ignored (recommended: 1/4 of the original image 
%                           -> it's better use a small number, to avoid borders being ignored)
%   - prior_mandrel_diameter: to deal with corner case, when the left border is hard to be detected
%
% Outputs:
%   - left_border_index: left border in the original image
%   - right_border_index： right border in the original image
%   - windows_features: the total number and length of valid edges in all
%   moving windows
%   - full_edges_filter_by_angle: elements in one row -> (x1, y1, x2, y2, ..., length, angle)
%   
% Preconditions: none
%
% Author: Dinggen DAI (daidinggen@hotmail.com)
% Date: 2022.09.12

[lengths, angles] = get_line_properties(edges);
full_edges = [edges, lengths, angles];

valid_inds = filter_by_angle(angles, angle_expect, angle_tolerance);
full_edges_filter_by_angle = full_edges(valid_inds, :);

windows_num = idivide(imageWidth, int32(windowStepSize), 'ceil');
windows_features = zeros(windows_num, 3);   % the 3 elements in a row -> (number, length, window_pos)
for i = 1:windows_num
    windowStart = 1 + (windowStepSize * (i-1));
    windowEnd = windowStart + windowWidth - 1;
    windows_features(i) = extract_window_features(full_edges_filter_by_angle, scale, ...
                                                                  windowStart, windowEnd);
end

%% find the border index: left peak, right peak
% 1 prior knowledge: the percentage of mandrel in image ->  (1/4 ~ 1/3) -> 
% this part will be ignored, this also divide the image into 2 parts: 
% left part & right part


% 2 corner case: using prior_mandrel_diameter
% lenth_threshold, number_threshold help to determine whether it's a corner
% case or not




end