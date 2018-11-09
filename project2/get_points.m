function [v1 v2] = get_points(poly_coeff)
% Returns two points for a line from the given poly_coeff

    x = [0 1];
    y_fit = polyval(poly_coeff, x);
    
    v1 = [0 y_fit(1) 0];
    v2 = [1 y_fit(2) 0];
end