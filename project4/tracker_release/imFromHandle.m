function image = imFromHandle(handle)
% Get an image from a figure handle.
    frame = getframe(handle); 
    image = frame2im(frame);
end

