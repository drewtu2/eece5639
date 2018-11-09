function [row, col] = getHarrisCorners(image)
    k = .04;
    window_size = 9;
    threshold = 500000;
    g = gausswin(window_size.^2);
    
    % Convert to grayscale if RGB
    if(isRgb(image))
        gray = rgb2gray(image);
    else
        gray = image;
    end
    
    % Gradient Kernels
    dx = [-1 0 1];
    dy = [-1 0 1]';
    
    idx = conv2(gray, dx,  'same');
    idy = conv2(gray, dy,'same');
        
    % Compute the product of derivatives at each pixel
    ix2 = idx .^ 2;
    iy2 = idy .^ 2;
    ixy = idx .* idy;
    
    % Step 2: Smooth space image derivatives (gaussian filtering)
    ix2 = conv2(idx .^ 2, g, 'same');
    iy2 = conv2(idy .^ 2, g, 'same');
    ixy = conv2(idx .* idy, g, 'same');
    
    % Compute the matrix at each pixel
    % each m = [ix2 ixy; ixy iy2]
    % response = det(m) - k*trace(m).^2
    % det(m) = (ix2*iy2) - (ixy)^2
    det_terms = (ix2 .* iy2) - (ixy .^ 2);
    % trace(m) = ix2 + iy2 
    trace_terms = (ix2 + iy2);
    
    % contains all the harris terms
    harris = det_terms - k*(trace_terms.^2);
    
    % non-max suppression
    mx = ordfilt2(harris, window_size^2, ones(window_size));

    % threshold
    harris = (harris == mx) & (harris > threshold);
    
    [row, col] = ind2sub(size(harris), find(harris >= 1));
    
    %figure
    %show_image(image, idx, idy, harris)
end

function rgb = isRgb(image)
    rgb = size(size(image), 2) == 3;
end

function show_image(image, idx, idy, harris)
    subplot(2, 1, 1)
    imshowpair(idx, idy, "montage")
    title("idx and idy")
    
    subplot(2, 1, 2)
    imshowpair(image, harris, "montage")
    title("original image and detected corners")
end

