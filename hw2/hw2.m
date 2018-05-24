
function hw2()
    global images;
    images = genImages(10);
    showImage = false;
    
    if showImage
        for ii = 1:size(images, 3)
            %display(strcat('Image ', num2str(ii)));
            imshow(images(:, :, ii));
            drawnow;
        end
    end
    
    global noise
    noise = EST_NOISE(images);
    
    display('**************************************');
    display('Problem 1-3: Filtering Images')
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

    averagingFilters(showImage);
    saltPepperImage();
    medianFilter();
    stepProfile();
end

function displayNoise(type, noise)
% Prints the type of noise and the corresponding average noise
    display(strcat(type, ' ', num2str(noise)));
end

function images = genImages(numImages)
% Problem 1
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
% Problem 2
% Applies an n by n box filter to the given cube. Cube consists of multiple
% frames. Returns the filtered result. 
    filtered = [];
    for frameNum = 1:size(cube, 3)
        frame = cube(:, :, frameNum);
        filtered = cat(3, filtered, box(frame, n));
    end
    
end

function filtered = box(frame, n)
% Problem 2
% Applies an n by n box filter to the given frame.
% Returns the filtered result. 
    filtered = imfilter(frame, (1/(n * n)) * ones(n));
end

function filtered = gaussCube(cube, n, sigma)
% Problem 3
%
% Applies an n by n gauss filter to the given cube using the 2D gaussian 
% filter.
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
% Problem 3
% Applies an n by n gauss filter to the given cube using the two 1D 
% gaussian filters.
    filtered = [];
    for frameNum = 1:size(cube, 3)
        frame = cube(:, :, frameNum);
        filtered = cat(3, filtered, gaussianSeparable(frame, n, sigma));
    end
    
end

function filtered = gaussianSeparable(frame, k, sigma)
    % Problem 3
    % Creates two 1D Masks that can be convolved to produce a 2D gaussian
    % filter
    
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
% General funciton for estimating the noise as per Chapter 2 of Trucco and
% Verri
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
% Problem 4
% Applies two different averaging filters to the image given in problem 4. 
% Prints the filtered results. 

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
    display('Problem 4: Averaging Filters')
    display('**************************************');
    display(strcat('Original image: ', mat2str(image)));
    display(strcat('Filtered Uniform : ', mat2str(filteredUniform)));
    display(strcat('Filtered Gaussian: ', mat2str(filteredGaussian)));

end

function saltPepperImage()
% Problem 5
% Finds the PDF for the pixels surrounding a gray line on a salt and pepper
% background. 
    PEPPER = 100;
    SALT = 0;
    GRAY = 50;
    
    % Create the salt and pepper background
    image = rand(500, 5);
    image(image >= .7) = PEPPER;
    image(image < .7) = SALT;
    
    % Draw the vertical line 
    for row = 1:size(image, 1)
       image(row, ceil(size(image,2)/2)) = GRAY;
    end
    
    figure;
    subplot(1, 2, 1);
    imshow(image);
    filter = [-1, 2, -1];
    filterResults = imfilter(image, filter, 'same');
    resultsOfInterest = cat(1, filterResults(:, 2), filterResults(:, 4));
    
    subplot(1, 2, 2);
    pie(categorical(resultsOfInterest));
    title('Problem 5: Distribution of values surrounding vertical line');

end

function medianFilter()
% Problem 6
% Filters the image described in problem 6 using a 3x3 median filter. 
    % Create image
    image = zeros(8, 8);
    
    for i = 1:8
        for j = 1:8
            image(i, j) = abs((i - 1) - (j -1));
        end
    end
    
    % Filter
    filtered = zeros(8, 8);
    filtered(1, :) = image(1, :);
    filtered(8, :) = image(8, :);
    filtered(:, 1) = image(:, 1);
    filtered(:, 8) = image(:, 8);
    
    for i = 2:7
        for j = 2:7
            filtered(i, j) = median9(image, i, j);
        end 
    end
    
    function med = median9(image, i, j)
        values = zeros(3, 3);
        
        for i2 = -1:1
            for j2 = -1:1
                values(i2 + 2, j2 + 2) = image(i + i2, j + j2);
            end
        end
        
        med = median(values(:));
    end
    display('**************************************');
    display('Problem 6: Median Filters')
    display('**************************************');
    image
    filtered
end

function stepProfile() 
% Problem 7
% Filters a step image of with both an averaging filter and a median
% filter. Median filter doesn't change the step, averaging filter does. 
    image = [4 4 4 4 8 8 8 8];
    
    filter = 1/4 * [1 2 1];
    average = conv(image, filter, 'same');
    
    medianFiltered = image;
    for i = 2:length(image) - 1
        medianFiltered(i) = median([image(i - 1), image(i), image(i + 1)]);
    end
    
    display('**************************************');
    display('Problem 7: 1D Step Profile')
    display('**************************************');
    average         % Blends the step. 
    medianFiltered  % Remains unchanged
    
end