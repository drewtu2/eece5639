function dumpFigToGif(frames, filename)
% Takes a set of frames and dumps it to the given filename as a gif.
% Input: frames - the frames to dump as a cell array
% Input: filename - the filename to dump to
    for idx = 1:length(frames)
        [imind,cm] = rgb2ind(frames{idx}, 256); 
        
        % Write to the GIF File 
        if idx == 1 
          imwrite(imind, cm, filename, 'gif', 'Loopcount', inf); 
        else 
          imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append'); 
        end 
    end
    
end

