% This class represents a Harris Corner Object. 
classdef HarrisObj
	properties
        name                % A name for this image
        image               % The image itself 
        point_rows          % list of rows for found points
        point_cols          % list of cols for found points
	end
   
   
    methods
        function obj = HarrisObj(name, image)
        % Constructor: Takes in a name and an RGB image to build the
        % corner object
            if nargin > 0
                obj.name = name
                obj.image = image;
                [obj.point_rows, obj.point_cols] = getHarrisCorners(image);
            end
        end

        function plot(obj)
        % Overload that plot function for some sweet sweet graphs. 
            imshow(obj.image);
            hold on;
            plot(obj.point_cols, obj.point_rows, "*");
            title(strcat(obj.name, " Detected Harris Corner Points"));
        end
        
        function num = getNumPoints(obj)
        % Returns the number of points found by the corner detection
            num = length(obj.point_rows);
        end
        
        function point = getPoint(obj, index)
        % Returns the nth point in the point list as [x y]
            point = [obj.point_cols(index) obj.point_rows(index)];
        end
        
        function gray = getGray(obj)
        % Returns the gray scale of the object
            gray = rgb2gray(obj.image);
        end
        
        function rgb = getRGB(obj)
        % Returns the gray scale of the object
            rgb = obj.image;
        end
    end
end