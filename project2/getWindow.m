function window = getWindow(image, row, col, windowSize)
    % Returns a window of size windowSize around a give point. 
    % Zero pads if necessary
    
    center = ceil(windowSize/2);
    edgeBuffer = (windowSize - 1)/2;
    
    window = zeros(windowSize);
    
    pre_col = min(col - 1, edgeBuffer);
    post_col = min(size(image, 2) - col, edgeBuffer);
    pre_row = min(row - 1, edgeBuffer);
    post_row = min(size(image, 1) - row, edgeBuffer);
    
    % Get the windows
    window((center-pre_row:center+post_row), ...
    (center-pre_col:center+post_col)) = image((row - pre_row):(row + post_row), ...
                (col - pre_col):(col + post_col));  
end