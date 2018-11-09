function [ret_coeff, ret_time] = ransac(points, N, S, D, X, C)
% points - an Mx2 array containing all the points in this line
% N - max number of times to attempt to find lines
% S - Number of samples to compute initial line
% D - Degrees from initial reading to sample from
% X - Max distance a reading may be from line to get associated to line
% C - Number of points that must lie on a line for it to be taken as a line

    first_order = 1;
    unassociated_readings = points;
    num_readings = length(unassociated_readings);
    num_trials = 0;
    s = RandStream('mt19937ar','Seed',0);
    
    new_random = true;
    
    sample = zeros(S, 2);
    not_sample = zeros(num_readings - S, 2);
    
    % [m b error]
    lines = zeros(N, 3);
    tic
    while (num_trials < N)
        if new_random
            % Calculate N random indexes if we need to. We may choose to 
            % build off of indices from the last run if they were good
            % enough
            indices = randperm(s, num_readings, S);            
        end
        
        % Reset flag so we can use new random points next time 
        new_random = 1;
        good_index = [];
        bad_index = [];
        
        % Counters
        sample_counter = 0; 
        not_sample_counter = 0;
        
        % Assign every point to be a sample or not a sample
        for index=1:num_readings
            if ismember(index, indices)
                % This is a one of our random points
                sample_counter = sample_counter + 1;
                sample(sample_counter, :) = points(index, :);
            else
                % Not a random point
                not_sample_counter = not_sample_counter + 1;
                not_sample(not_sample_counter, :) = points(index, :);
            end
        end
        
        % Calculate best fit line for samples
        coeff = polyfit(sample(:, 1)', sample(:, 2)', first_order);
        
        % Get two vertices
        [v1 v2] = get_points(coeff);
        err = 0;
        
        % For each point outside of the sample
        for index=1:length(not_sample)

            % Test distance from point to line against X
            pt = [not_sample(index, :) 0];
            d = point_to_line(pt, v1, v2);
            
            err = err + d; % Assume only good points can increase error. 
            
            % If less than X, point is close
            if d < X
                good_index = [good_index; index];
            else
                bad_index = [bad_index; index];
            end
        end
        
        % Save the results from this run
        lines(num_trials + 1, :) = [coeff err]; 
        
        % If number of good fit points is greater than C
         if length(good_index) > C
            % Line is a good fit; refit using new points. 
            indices = good_index;
            new_random = 0;
        end
        
        num_trials = num_trials + 1;
    end
    % Return best set of coefficients
    [M, I] = min(lines);
    ret_coeff = lines(I(3), 1:2); % Return the coeff's with the lowest error
    ret_time = toc;
end