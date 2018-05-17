
function motion_detector()
% Main kick off for script... 
% Load the folder into an imageDatastore, start the processing pipeline
    global THRESHOLD 
    global WHITE 
    global BLACK 
    global BOX3
    global BOX5
    global GAUSS 
    global TEMPORAL_SCALE
    global GAUSS_STD

    THRESHOLD = 8;
    WHITE = 255;
    BLACK = 0;
    TEMPORAL_SCALE = 1;
    GAUSS_STD = 2;

    BOX3 = '3x3Box';
    BOX5 = '5x5Box';
    GAUSS = 'gauss';

    % Specify the folder where the files live.
    myFolder = '/Users/Andrew/Dropbox/Northeastern/2018Summer1/eece5639/project1/RedChair/'
    % Check to make sure that folder actually exists.  Warn user if it doesn't.
    if ~isdir(myFolder)
      errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
      uiwait(warndlg(errorMessage));
      return;
    end

    % Get a list of all files in the folder with the desired file name pattern.
    % filePattern = fullfile(myFolder, '*.jpg'); % Change to whatever pattern you need.
    % theFiles = dir(filePattern);

    video = imageDatastore(myFolder)
    processing_pipeline(video)
end

function processing_pipeline(video)
% Handle the processing of the image datastore after its been loaded

    global TEMPORAL_SCALE
    global GAUSS
    global BOX3
    global BOX5
    % Start at 2nd image, end at length - 1 because the nth term is the 
    % difference of n-1 and n+1
    %for k = 2 : length(video.Files) - 1
    %    previous = readimage(video, k - 1) * TEMPORAL_SCALE;
    %    next = readimage(video, k + 1) * TEMPORAL_SCALE;
    %    frame.color = readimage(video, k);

    %    [frame.gauss_filter, frame.gauss_mask, frame.gauss_movement] = ...
    %        processing_pipeline_helper(frame.color, previous, next, GAUSS);
    %    [frame.box3_filter, frame.box3_mask, frame.box3_movement] = ...
    %        processing_pipeline_helper(frame.color, previous, next, BOX3);
    %    [frame.box5_filter, frame.box5_mask, frame.box5_movement] = ...
    %        processing_pipeline_helper(frame.color, previous, next, BOX5);

    %    % Display...
    %    display_frame(frame);
    %end

    % Gaussian 1D
    % 1/16 * [1 4 6 4 1] over each pixel with respect to time. 

    for k = 3 : length(video.Files) - 5
        kernelCube = getGaussCube(video, size(readimage(video, 1)));
        temporalCube = getTemporalCube(video, k);
        differentialImage = sum(double(temporalCube) .* kernelCube, 3);

        

        % Threshold values - above a THRESHOLD and the coresponding pixel should
        % be white, otherwise, black.
        mask = delta_threshold(differentialImage);

        global WHITE
        color = readimage(video, k);
        movement = uint8(double(rgb2gray(color)) .* (mask/WHITE));

        % Image
        subplot(2,4,1);
        imshow(color);  
        title('Color')
        
        % Filter
        subplot(2,4,2);
        imshow(differentialImage); 
        title('Delta')
        
        % Mask
        subplot(2,4,3);
        imshow(mask); % Multiply by WHITE value to get a binary image 
        title('Gauss Mask')
        
        % Show gray image of mask 
        subplot(2,4,4);
        imshow(uint8(movement));  % Display mask.
        title('Gauss Movement')

        subplot(2, 4, [5, 6]);
        display(std2(differentialImage));
        scatter(k, std2(differentialImage), 'r');
        title('Standard Deviation of Differntial')
        xlabel('Frame number')
        ylabel('STD')
        hold on;
        
        subplot(2, 4, [7, 8]);
        scatter(k, (mean2(differentialImage .* differentialImage)), 'r');
        title('Mean Squared Value of Differential')
        xlabel('Frame number')
        ylabel('Mean Squared')
        hold on;
        drawnow;
    end

end

function gaussCube = getGaussCube(video, imageSize)
    gauss = [1 4 6 4 1] * (1/16);
    differential = [-1 0 1];
    kernel = conv(gauss, differential, 'same');
    differentialImage = ones(imageSize(1), imageSize(2));
    gaussCube = repmat(kernel, [imageSize(1) * imageSize(2), 1]);
    gaussCube = reshape(gaussCube, [imageSize(1), imageSize(2), length(kernel)]);
end

function slice = getTemporalCube(video, k, m, n)
    slice = [];
    for i = 1 : 5
        slice = cat(3, slice, rgb2gray(readimage(video, k - 3 + i)));
    end
end

function [filter, mask, movement] = ... 
    processing_pipeline_helper(color, previous, next, filter_selector)
    % Apply spatial filter, threshold values, apply mask
        
    [previous_frame, next_frame] ...
        = apply_spatial_filter(previous, next, filter_selector);

    %imshowpair(previous_frame, next_frame, 'montage')

    filter = rgb2gray(next_frame);
    delta = rgb2gray(next_frame) - rgb2gray(previous_frame);

    % Threshold values - above a THRESHOLD and the coresponding pixel should
    % be white, otherwise, black.
    mask = delta_threshold(delta);

    global WHITE
    movement = rgb2gray(color) .* (mask/WHITE);
end

function [previous_frame, next_frame] = apply_spatial_filter(previous, next, selector)
% Applies the requested filter to the given frames. returns the frames.
    global BOX3
    global BOX5
    global GAUSS
    global GAUSS_STD

    switch selector
        case BOX3
            [previous_frame, next_frame] = box(3);
        case BOX5
            [previous_frame, next_frame] = box(5);
        case GAUSS
            previous_frame = imgaussfilt(previous, GAUSS_STD);
            next_frame = imgaussfilt(next, GAUSS_STD);
    end

    function [previous_frame, next_frame] = box(n)
        previous_frame = imfilter(previous, (1/(n * n)) * ones(n));
        next_frame = imfilter(next, (1/(n * n)) * ones(n));
    end
end

function mask = delta_threshold(frame)
    global WHITE
    global BLACK
    global THRESHOLD

    frame(abs(frame) >= THRESHOLD) = WHITE;
    frame(abs(frame) < THRESHOLD) = 0;

    mask = frame;
end

function display_frame(frame)
    % Image
    subplot(3,4,1);
    imshow(frame.color);  
    title('Color')
    
    % Filter
    subplot(3,4,2);
    imshow(frame.gauss_filter); 
    title('Gauss Filter')
    
    % Mask
    subplot(3,4,3);
    imshow(frame.gauss_mask); % Multiply by WHITE value to get a binary image 
    title('Gauss Mask')
    
    % Show gray image of mask 
    subplot(3,4,4);
    imshow(frame.gauss_movement);  % Display mask.
    title('Gauss Movement')
    
    % Image
    %subplot(3,4,5);
    %imshow(frame.color);  
    %title('Color')
    
    % Filter
    subplot(3,4,6);
    imshow(frame.box3_filter); 
    title('Box 3 Filter')
    
    % Mask
    subplot(3,4,7);
    imshow(frame.box3_mask); % Multiply by WHITE value to get a binary image 
    title('Box3 Mask')
    
    % Show gray image of mask 
    subplot(3,4,8);
    imshow(frame.box3_movement);  % Display mask.
    title('Box3 Movement')
    
    % Image
    %subplot(3,4,9);
    %imshow(frame.color);  
    %title('Color')
    
    % Filter
    subplot(3,4,10);
    imshow(frame.box5_filter); 
    title('Box 5 Filter')
    
    % Mask
    subplot(3,4,11);
    imshow(frame.box5_mask); % Multiply by WHITE value to get a binary image 
    title('Box5 Mask')
    
    % Show gray image of mask 
    subplot(3,4,12);
    imshow(frame.box5_movement);  % Display mask.
    title('Box5 Movement')

    drawnow; % Force display to update immediately.
end
