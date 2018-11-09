function match_sub = matchCorners(obj1, corner_index, obj2)
    window_size = 15;
    cc_map = zeros(size(obj2.getGray()));
    
    % Get the location of the first image
    obj1_corner = obj1.getPoint(corner_index);
    obj1_window = getWindow(obj1.getGray(), obj1_corner(2), obj1_corner(1), window_size);
    
    
    % Calculate NCC to corner point in obj2
    for index=1:obj2.getNumPoints()
        % Extract Point and Window
        obj2_corner = obj2.getPoint(index);
        obj2_window = getWindow(obj2.getGray(), obj2_corner(2), obj2_corner(1), window_size);
        
        % Calculate normalized cross correlation value
        ncc_value = calcNcc(obj1_window, obj2_window);
        
        % Save value in map
        cc_map(obj2_corner(2), obj2_corner(1)) = ncc_value;
        
    end
    
    [row, col] = find(cc_map==max(max(cc_map)), 1); 
    match_sub = [row, col, max(max(cc_map))];
end

function ncc = calcNcc(template, search)

    % Using zero mean correlation score is higher ONLY when darker parts of 
    % the template overlap with darker parts of the image, and brighter 
    % parts of the template overlap brighter parts of the image.
    zm_template = template - mean2(template);
    zm_search = search - mean2(search);
    
    % Normalize by dividing by the standard deviation 
    norm_template = zm_template / sqrt(sum(sum(zm_template.^2)));
    norm_search = zm_search / sqrt(sum(sum(zm_search.^2)));
    
    % Perform Cross Correlation
    ncc = sum(sum(norm_template .* norm_search));
end

function display_result(cc_map)
% Display Correlation Graph
    surf(cc_map);
    title("Normalized Cross Correlation of obj1 and obj2 windows");
end
