
% Close previously opened images
close all

% Read in two images
image1 = imread('DanaOffice/DSC_0308.JPG');
image2 = imread('DanaOffice/DSC_0309.JPG');

images = {image1, image2};
harris_objs = {};
ncc_threshold = .9


% Create and show both Harris Objects. 
for index=1:length(images)
    name = strcat("Image", num2str(index));
    image = images{index};
    
    harris_objs{index} = HarrisObj(name, image);

    figure;
    plot(harris_objs{index});
end

% For every corner in obj1

obj1_points = zeros(harris_objs{1}.getNumPoints(), 2);
obj2_points = zeros(harris_objs{1}.getNumPoints(), 2);

for index=1:harris_objs{1}.getNumPoints()
    fprintf("Corner %d of %d\n", index, harris_objs{1}.getNumPoints());
    match_sub = matchCorners(harris_objs{1}, index, harris_objs{2});
    
    if(match_sub(3) > ncc_threshold)
       fprintf("\t ncc value: %6.2f\n", match_sub(3));    
       obj1_points(index, :) = harris_objs{1}.getPoint(index);
       obj2_points(index, :) = sub2point(match_sub(1:2)); 
    else
        fprintf("\t Dropped ncc value of %6.2f\n", match_sub(3));
    end
    
end

% Remove rows below threshold
obj1_points = obj1_points(any(obj1_points,2),:);
obj2_points = obj2_points(any(obj2_points,2),:);

figure;
showMatchedFeatures(harris_objs{1}.getRGB(),harris_objs{2}.getRGB(),...
                    obj1_points, obj2_points,...
                    'montage');
title('Candidate point matches');
legend('Matched points 1','Matched points 2');