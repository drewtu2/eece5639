function [estX, estY] = estimatePosConstantA(positions, dt)
%Calculates the estimated positions in dT frames given the position
%history.
% input: Positions is an Nx2 matrix of the [X Y] positions where row N is 
% the most recent position.
% input: dt = number of frames out to estimate for

    numPos = length(positions);
    dt = 1;
    constantA = [eye(2) dt* eye(2) .5 * dt^2 * eye(2); ...
            zeros(2) eye(2) dt * eye(2); ...
            zeros(2) zeros(2) eye(2)];
    
    % Use the last 3 positions to find A and V. 
    mostRecentPos = positions(numPos - 2:end, :);
    
    estV = diff(mostRecentPos);
    estA = diff(estV);
    
    r = constantA * [positions(numPos, :)'; estV(length(estV), :)'; estA'];
    
    estX = r(1);
    estY = r(2);       
end

