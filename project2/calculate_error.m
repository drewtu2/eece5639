function err = calculate_error(points, coeff)
    [v1 v2] = get_points(coeff);
    err = 0;
    
    for index=1:length(points)

        % Test distance from point to line against X
        pt = [points(index, :) 0];
        d = point_to_line(pt, v1, v2);

        % add to err
        err = err + d;
    end
    
    err = err/length(points);
end