% This file is part of LSM.
% 
% LSM is free software: you can redistribute it and/or modify
% it under the terms of the GNU v3.0 General Public License as published by
% the Free Software Foundation.
% 
% LSM is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details
% <http://www.gnu.org/licenses/>.

function [ img] = display_image( lines, im )
clf;
hfig = figure(1); 
close;
clf;
axis off

imm=zeros(size(im));
imagesc(imm); 
% colormap white;
hold on;axis off

drawlines(lines,cmap); drawnow;

axis image
% img = hardcopy(hfig, '-Dzbuffer', '-r0');  % there is no hardcopy() in the new version 
img = frame2im(getframe(hfig));
hold off;close;

end