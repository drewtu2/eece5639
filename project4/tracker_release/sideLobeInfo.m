function [sigma, mean] = sideLobeInfo(response, rowMaxIndex, colMaxIndex)
    edgeBuffer = (11 - 1) / 2 ;
    
    xLowerShift = 0;
    xUpperShift = 0;
    yLowerShift = 0;
    yUpperShift = 0;
    
    % Just ignore the edges for now...
    if rowMaxIndex <= edgeBuffer || rowMaxIndex >= size(response, 1) - edgeBuffer
%     	xLowerShift = edgeBuffer - rowMaxIndex + 1;
%         xUpperShift = rowMaxIndex + edgeBuffer - size(response, 1)
        sigma = 0;
        mean = 0;
    elseif colMaxIndex <= edgeBuffer || colMaxIndex  >= size(response, 2) - edgeBuffer
        sigma = 0;
        mean = 0;
    else
        % This is the 11x11 box surrounding the max response
%         maxRegion = response(...
%             (rowMaxIndex - edgeBuffer):(rowMaxIndex + edgeBuffer), ...
%             (colMaxIndex - edgeBuffer):(colMaxIndex + edgeBuffer));

        % Get rid of the max region
        lobeRegion = response;
        lobeRegion((rowMaxIndex - edgeBuffer):(rowMaxIndex + edgeBuffer), ...
                    (colMaxIndex - edgeBuffer):(colMaxIndex + edgeBuffer))...
                    = 0;
        lobeRegion = sort(lobeRegion(:));
        
        
        sigma = std2(lobeRegion(11^2 + 1: end));
        mean = mean2(lobeRegion(11^2 + 1: end));
        
%         sigma = std(response(:)) - std(ignoreRegion(:));
%         mean = mean2(response) - mean2(ignoreRegion);
    end
end

