
function p3()
% https://www.youtube.com/watch?v=1r8E9uAcn4E

close all;
clc;
% To summarize the LK algorithm for computing flow:
% 1. Read image1 and image2, and convert to double flow greyscale image 
% frames.

% Commented out for testing purposes.
%     images = getImages();
%     g1 = readimage(images, 1);
%     g2 = readimage(images, 2);
     g1 = testImage(1);
     g2 = testImage(2);

    imageSize = size(g1);
    windowSize = 3; % How large of a window

% 2. Compute the spatial intensity gradients Ix and Iy of image2. 
% Recall that it is a good idea to smooth before taking the derivative, 
% for example by using derivative of Gaussian operators.
    smoothG2 = imgaussfilt(g2, 2);
    Ix = conv2(smoothG2, [-1 0 1], 'same');
    Iy = conv2(smoothG2, [-1 0 1]', 'same');

% 3. Compute the temporal gradient It by subtracting a smoothed version of 
% image1 from a smoothed version of image2.
    smoothG1 = imgaussfilt(g1, 2);
    It = smoothG2 - smoothG1;

% 4. For a given window size W , form a system of linear equations at each 
% pixel by summing over products of gradients in its neighborhood, as 
% specified by the Lucas-Kanade method. That is, at each pixel, you will 
% have a set of equations:
% [Vx; Vy] = -[Sum IxIt; Sum IyIt]/[Sum Ix^2 Sum IxIy; Sum IxIy SumIy^2]
    Vx = zeros(imageSize);
    Vy = zeros(imageSize);
    
    
% 5. Solve for the flow vector [u, v] at each pixel. It is convenient to
% represent this vector field by two images, one containing the u 
% component, and the other the v component of flow.
    % Iterate through to calculate at each iteration
    for row = 1:imageSize(1)
       for col = 1:imageSize(2)
           [Vx(row, col), Vy(row, col)] = getV(Ix, Iy, It, row, col, windowSize);
       end
    end
    
% 6. Display the flow vectors overlaid on the image. You can use matlab 
% ?quiver? to show the flow field.

    figure;
    subplot(4, 2, 1);
    imshow(g1);
    title('G1')
    
    subplot(4, 2, 2);
    imshow(g2);
    title('G2')
    
    subplot(4, 2, 3)
    imshow(Ix)
    title('Delta X G2')
    
    subplot(4, 2, 4)
    imshow(Iy)
    title('Delta Y G2')
    
    subplot(4, 2, 5:8);
    quiver(Vx, Vy);
    hax = gca; %get the axis handle
    image([0, 16], [0, 16], g1); %plot the image within the axis limits
    hold on;
    quiver(Vx, Vy);
end

function [X, Y] = getV(Ix, Iy, It, row, col, windowSize)
    edgeBuffer = (windowSize - 1)/2;
    
    if row <= edgeBuffer || row >= size(Ix, 2) - edgeBuffer
    	X = 0;
        Y = 0;
        return;
    elseif col <= edgeBuffer || col >= size(Ix, 2) - edgeBuffer
        X = 0;
        Y = 0;
        return;
    else
        % Get the windows
        XWindow = Ix((row - edgeBuffer):(row + edgeBuffer), ...
                    (col - edgeBuffer):(col + edgeBuffer));
        YWindow = Iy((row - edgeBuffer):(row + edgeBuffer), ...
                    (col - edgeBuffer):(col + edgeBuffer));
        TWindow = It((row - edgeBuffer):(row + edgeBuffer), ...
                    (col - edgeBuffer):(col + edgeBuffer));
        
        % Calculate Corner Matrix        
        X2 = sum(sum(XWindow.^2));
        Y2 = sum(sum(YWindow.^2));
        XY = sum(sum(XWindow.*YWindow));
        CornerMatrix = [X2 XY; XY Y2];
        
        % Calculate Transform Matrix
        Tx = sum(sum(XWindow.*TWindow));
        Ty = sum(sum(YWindow.*TWindow));
        TransformMatrix = -1 * [Tx; Ty];
        
        VxVy = CornerMatrix \ TransformMatrix;
        X = VxVy(1);
        Y = VxVy(2);
    end
end

function images = getImages()
    % Specify the folder where the files live.
    myFolder = '/Users/Andrew/Dropbox/Northeastern/2018Summer1/eece5639/project3/images/'
    % Check to make sure that folder actually exists.  Warn user if it doesn't.
    if ~isdir(myFolder)
      errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
      uiwait(warndlg(errorMessage));
      return;
    end

    % Get a list of all files in the folder with the desired file name pattern.
    % filePattern = fullfile(myFolder, '*.jpg'); % Change to whatever pattern you need.
    % theFiles = dir(filePattern);

    images = imageDatastore(myFolder);
    %scale = [8 8 1];
    scale = [1 1 1];
    inputSize = size(readimage(images, 1))./scale;
    
    images.ReadFcn = @(images)double(rgb2gray(imresize(imread(images), inputSize(1:2))));
end


function ret = testImage(imageNum)
% Return test images for algorithm development. 
    a = zeros(16, 16);
    a(1:3, 1:3) = 256;
    a(13:16, 1:3) = 256;

    b = zeros(16, 16);
    b(4:7, 4:7) = 256;
    
    if(imageNum == 1)
        ret = a;
    else
        ret = b;
    end
end