
function hw2()
    global images;
    images = genImages(10);
    
    for ii = 1:size(images, 3)
        %display(strcat('Image ', num2str(ii)));
        imshow(images(:, :, ii));
        drawnow;
    end
    global noise
    noise = EST_NOISE(images);
    
    display('**************************************');
    display('Filtering Images')
    display('**************************************');
    
    displayNoise('Noisy Images:', mean2(noise));
    
    box3.filtered = boxCube(images, 3);
    box3.noise = EST_NOISE(box3.filtered);
    displayNoise('Box 3 Filtered:', mean2(box3.noise));
    
    gauss.filtered = gaussCube(images, 3, 2);
    gauss.noise = EST_NOISE(gauss.filtered);
    displayNoise('Gauss Filtered:', mean2(gauss.noise));

    gauss2.filtered = gaussCube2(images, 3, 2);
    gauss2.noise = EST_NOISE(gauss2.filtered);
    displayNoise('Gauss Filtered Separable:', mean2(gauss2.noise));

    averagingFilters(false);
end

function displayNoise(type, noise)
% Prints the type of noise and the corresponding average noise
    display(strcat(type, ' ', num2str(noise)));
end

function images = genImages(numImages)
% Generates numImages images of color gray level 128 with zero mean
% gaussian noise with standard deviation 2. 
% Returns cube with the image on XY plane and the stack of images going
% back along Z plane. 
    images = [];
    for i = 1:numImages
        image = uint8(128 * ones(256, 256));
        image = imnoise(image, 'gaussian', 0, 2^2);
        images = cat(3, images, image);
    end
    
end

function filtered = boxCube(cube, n)
% Applies an n by n box filter to the given cube. Cube consists of multiple
% frames. Returns the filtered result. 
    filtered = [];
    for frameNum = 1:size(cube, 3)
        frame = cube(:, :, frameNum);
        filtered = cat(3, filtered, box(frame, n));
    end
    
end

function filtered = box(frame, n)
% Applies an n by n box filter to the given frame.
% Returns the filtered result. 
    filtered = imfilter(frame, (1/(n * n)) * ones(n));
end

function filtered = gaussCube(cube, n, sigma)
% Applies an n by n box filter to the given cube.
    filtered = [];
    for frameNum = 1:size(cube, 3)
        frame = cube(:, :, frameNum);
        filtered = cat(3, filtered, gaussian(frame, n, sigma));
    end
    
end

function filtered = gaussian(frame, n, sigma)
% Applies an n by n box filter to the given frame.
% https://stackoverflow.com/questions/27499057/how-do-i-create-and-apply-a-gaussian-filter-in-matlab-without-using-fspecial-im

    % Generate horizontal and vertical co-ordinates, where
    % the origin is in the middle
    ind = -floor(n/2) : floor(n/2);
    [X Y] = meshgrid(ind, ind);

    % Create Gaussian Mask
    h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));

    % Normalize so that total area (sum of all weights) is 1
    h = h / sum(h(:));
    
    filtered = imfilter(frame, h);
end

function filtered = gaussCube2(cube, n, sigma)
% Applies an n by n box filter to the given cube.
    filtered = [];
    for frameNum = 1:size(cube, 3)
        frame = cube(:, :, frameNum);
        filtered = cat(3, filtered, gaussianSeparable(frame, n, sigma));
    end
    
end

function filtered = gaussianSeparable(frame, k, sigma)
    % Generate horizontal and vertical co-ordinates, where
    % the origin is in the middle
    ind = -floor(k/2) : floor(k/2);
    [X, Y] = meshgrid(ind, ind);

    hx = gaussian1D(X);
    hy = gaussian1D(Y);
    
    for row = 1: size(frame, 1)
        frame(row, :) = conv(frame(row, :), hx, 'same');
    end
    
    for col = 1: size(frame, 2)
        frame(:, col) = conv(frame(:, col), hy, 'same');
    end
    
    filtered = frame;
    
    function h = gaussian1D(vector)
        % Create Gaussian Mask
        h = exp(-(vector.^2) / (2*sigma*sigma))/sqrt(k);
        
        % Normalize so that total area (sum of all weights) is 1
        h = h / sum(h);
    end
end

function noise = EST_NOISE(images)
% Images is a data cube with XY being the representation of a single image
% and Z being imagne number n. 
    E_Images = double(sum(images, 3) / size(images, 3));
    
    noise = double(zeros(size(images, 1), size(images,2)));
    for image = 1:size(images, 3)
        this_iteration = (E_Images - double(images(:, :, image))).^2; 
        noise = noise + this_iteration;
    end
        
    noise = sqrt(noise / (size(images, 3) - 1));
end

function averagingFilters(showImage)

    filterA = 1/5 * [1 1 1 1 1];
    filterB = 1/10 * [1 2 3 2 1];
    image = [10 10 10 10 10 40 40 40 40 40];
    
    filteredUniform = conv(image, filterA, 'same');
    filteredGaussian = conv(image, filterB, 'same');
    
    if showImage
        figure;
        subplot(1, 3, 1);
        imshow(image);
        subplot(1, 3, 2);
        imshow(filteredUniform);
        subplot(1, 3, 3);
        imshow(filteredGaussian);
    end
    
    display('**************************************');
    display('Averaging Filters')
    display('**************************************');
    display(strcat('Original image: ', mat2str(image)));
    display(strcat('Filtered Uniform : ', mat2str(filteredUniform)));
    display(strcat('Filtered Gaussian: ', mat2str(filteredGaussian)));

end