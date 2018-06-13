
function p3()
% https://www.youtube.com/watch?v=1r8E9uAcn4E
    THRESHOLD = 1;
    close all;
    clc;
    
    myFolder = '/Users/Andrew/Dropbox/Northeastern/2018Summer1/eece5639/project3/images/garden/'
    isRGB = false;

    % Commented out for testing purposes.
%     images = getImages(myFolder, isRGB);
%     g1 = readimage(images, 1);
%     g2 = readimage(images, 2);
    g1 = testImage(0);
    g2 = testImage(1);
    pyramid = buildGaussPyramid(g1, g2, 2);

    % Optical flow on top of pyramid first
    [pyramid(2).Vx, pyramid(2).Vy] = opticalFlow(pyramid(2).gray1, pyramid(2).gray2);
    
    ofScaledUp.X = pyramid(2).Vx * 2;
    ofScaledUp.Y = pyramid(2).Vy * 2;
    
    ofScaledUp.X = duplicationInterpolation(ofScaledUp.X);
    ofScaledUp.Y = duplicationInterpolation(ofScaledUp.Y);
    
    [pyramid(1).Vx, pyramid(1).Vy] = opticalFlow(pyramid(1).gray1, pyramid(1).gray2);

    mergedOF.X = max(ofScaledUp.X, pyramid(1).Vx);
    mergedOF.Y = max(ofScaledUp.Y, pyramid(1).Vy);
    
    % Plot the final Result
    figure;
    
    subplot(2, 1, 1);
    quiver(mergedOF.X, mergedOF.Y);
    hax = gca; %get the axis handle
    imshow(uint8(pyramid(1).gray2)); %plot the image within the axis limits
    hold on;
    quiver(mergedOF.X, mergedOF.Y);
    
    subplot(2, 1, 2);
    imshow(double(ones(size(g2)))); %plot the image within the axis limits
    hold on;
    quiver(mergedOF.X, mergedOF.Y);
    
    
end

function pyramid = buildGaussPyramid(gIm1, gIm2, sigma)
% Builds a 2 level gaussian pyramid of the two given images. 
% Pyramid of form 
%   Pyramid(n).gray1
%   Pyramid(n).gray2
%   Pyramid(n).gray1blur
%   Pyramid(n).gray2blur
% Image at level 1 (n = 1) is the largest image.
% Image at level n is size(Image at level 1)/(2^(n-1))

    pyramid(1).gray1 = gIm1;
    pyramid(1).gray2 = gIm2;
    pyramid(1).gray1blur = imgaussfilt(pyramid(1).gray1, sigma);
    pyramid(1).gray2blur = imgaussfilt(pyramid(1).gray2, sigma);
    
    pyramid(2).gray1 = subsample(pyramid(1).gray1blur, 2);
    pyramid(2).gray2 = subsample(pyramid(1).gray2blur, 2);
    pyramid(2).gray1blur = imgaussfilt(pyramid(2).gray1, sigma);
    pyramid(2).gray2blur = imgaussfilt(pyramid(2).gray2, sigma);
    
end

function larger = duplicationInterpolation(inputImage)
% Returns the given image with double the width and height. Values are
% copied to double the size

    larger = zeros(2 * size(inputImage));
    
    larger(1:2:end, 1:2:end) = inputImage;
    larger(2:2:end, :) = larger(1:2:end, :);
    larger(:, 2:2:end) = larger(:, 1:2:end);

end

function subsampled = subsample(im, num)
% Takes an MxN matrix representing a grayscale image. 
% Returns an image with every num'th row and col. 

subsampled = im(1:num:end, 1:num:end);
end

function [Vx Vy] = opticalFlow(g1, g2)
% Implements the LK algorithm for dense optical flow on two given images. Returns
% Vx and Vy for every pixel. 

% 1. Read image1 and image2, and convert to double flow greyscale image 
% frames.
    imageSize = size(g1)
    windowSize = 5; % How large of a window

% 2. Compute the spatial intensity gradients Ix and Iy of image2. 
% Recall that it is a good idea to smooth before taking the derivative, 
% for example by using derivative of Gaussian operators.
    %smoothG2 = imgaussfilt(g2, 2);
    smoothG2 = g2;
    Ix = abs(conv2(smoothG2, [-1 0 1], 'same'));
    Iy = abs(conv2(smoothG2, [-1 0 1]', 'same'));

% 3. Compute the temporal gradient It by subtracting a smoothed version of 
% image1 from a smoothed version of image2.
    %smoothG1 = imgaussfilt(g1, 2);
    smoothG1 = g1;
    It = abs(smoothG2 - smoothG1);

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
    subplot(5, 2, 1);
    imshow(uint8(g1));
    title('G1')
    
    subplot(5, 2, 2);
    imshow(uint8(g2));
    title('G2')
    
    subplot(5, 2, 3)
    imshow(uint8(Ix))
    title('Delta X G2')
    
    subplot(5, 2, 4)
    imshow(uint8(Iy))
    title('Delta Y G2')
    
    subplot(5, 2, 5)
    imshow(uint8(smoothG2))
    title('Smooth G2')
    
    subplot(5, 2, 6)
    imshow(uint8(It))
    title('Delta T')
    
    subplot(5, 2, 7:10);
    quiver(Vx, Vy);
    hax = gca; %get the axis handle
    imshow(uint8(g2)); %plot the image within the axis limits
%     imshow(double(ones(size(g2)))); %plot the image within the axis limits
    hold on;
    quiver(Vx, Vy);
end

function [X, Y] = getV(Ix, Iy, It, row, col, windowSize)
    edgeBuffer = (windowSize - 1)/2;
    
    % Just ignore the edges for now...
    if row <= edgeBuffer || row >= size(Ix, 1) - edgeBuffer
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
        XWindow = reshape(XWindow, [], 1);
        
        YWindow = Iy((row - edgeBuffer):(row + edgeBuffer), ...
                    (col - edgeBuffer):(col + edgeBuffer));
        YWindow = reshape(YWindow, [], 1);
        
        TWindow = It((row - edgeBuffer):(row + edgeBuffer), ...
                    (col - edgeBuffer):(col + edgeBuffer));
        
        % Calculate b and A
        b = 1 * reshape(TWindow, [], 1);
        A = cat(2, XWindow, YWindow);
        ATA = A' * A;
        
        % Calculate v if the ATA is invertable. 
        if(det(ATA) ~= 0)    
            % If it is, return the velocities. 
            % v = (A^T*A)^-1 * A^T * b
            v = ATA \  A' * b;

            X = v(1);
            Y = v(2);
        else
            % Otherwise, return 0 for velocities
            X = 0;
            Y = 0; 
        end
        
    end
end

function images = getImages(myFolder, isRGB)
    % Specify the folder where the files live.
    
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
    if isRGB
        
        %scale = [8 8 1];
        scale = [1 1 1];
        inputSize = size(readimage(images, 1))./scale;

        images.ReadFcn = @(images)double(rgb2gray(imresize(imread(images), inputSize(1:2))));
    else
        scale = [1 1];
        inputSize = size(readimage(images, 1))./scale;

        images.ReadFcn = @(images)double(imresize(imread(images), inputSize(1:2)));
    end
end


function ret = testImage(imageNum)
% Return test images for algorithm development. 
    imSize = 256;
    WHITE = 255;
    BLACK = 0;
    blockSize = 32;
    
    noise = 128 * randn(blockSize); 
    
    size(noise)
    
    a = ones(imSize, imSize) * BLACK;
    %a(1:3, 1:3) = 256;
    a(32:63, 32:63) = (ones(blockSize) * 128) + noise ;

    b = ones(imSize, imSize) * BLACK;
    b(37:68, 37:68) = (ones(blockSize) * 128) + noise ;
    
    if(imageNum == 1)
        ret = a;
    else
        ret = b;
    end
end