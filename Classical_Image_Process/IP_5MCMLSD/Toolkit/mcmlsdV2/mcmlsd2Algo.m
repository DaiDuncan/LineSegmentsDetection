function [out] = mcmlsd2Algo(hitlines,img)
% Description: Compute the precision and recall values for different number
% of algorithm line segments. The algorithm and ground truth are optimally
% associated 1 to 1 based on the amount of associated locations. The
% precision and recall are computed at two levels: line segment and pixels.
% Input:
%   - algout: Set of algorithm detected contours in the dataset
%   - runSettype: train / test
%
% Output:
%   - Set of precision and recall (line segment and pixel level) values for
% different number of algorithm contours.
%
% Preconditions: algout is an array of structs where each position stores
% the name of an image in the dataset and the array with the detected
% contours [x1, y1, x2, y2]
%
% Author: Emilio Almazan
% Date: Nov 15


out = [];
%parameters

global edgeMap;
load('mcmlsdV2/trainLOGRecallEW3.mat');

[Nallsegreal,~] = size(hitlines);
linefeatureImg=zeros(Nallsegreal,2);

bandWidth=3;
edgeStruct = main_edge(img,5,1,10,1,0,1);

edgeMap=edgeStruct;
saliencyEdges=edgesRun(img);

for k=1:Nallsegreal
    
    x1 = hitlines(k,1);
    x2 = hitlines(k,3);
    y1 = hitlines(k,2);
    y2 = hitlines(k,4);
    if sqrt((x1-x2).^2+(y1-y2).^2)<3
        continue;
    end
    linefeatureImg(k,1)=hitlines(k,5)/sqrt((x1-x2).^2+(y1-y2).^2);
    lineHolderEdge=getLineBandEdge(x1,y1,x2,y2,img,bandWidth,double(saliencyEdges));
    
    temp=lineHolderEdge(:,bandWidth-1:bandWidth+3);
    
    linefeatureImg(k,2)=mean(temp(temp>0));
end
% 1st element of `feature`: the probs from PHT/LSD generalized by the length  of edgeLine
% 2nd element of `feature`: the mean value of the temp variable, generated by lineHolderEdge
feature=linefeatureImg;
negativeScore=feature(:,1)==0;
feature=feature-xmean;
feature=feature./xstd;
score = glmval(b,feature,'logit');  % score is predict value of Generalized linear model (sigmoid function): b is a vector of coefficient estimates as returned by the glmfit function, 'logit' is link function, features are the inputs X
% The score of negetive value and nan is -1
score(negativeScore)=-1;
score(isnan(score))=-1;
[val,ind]=sort(score,'descend');
out=[hitlines(ind,:),val];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
