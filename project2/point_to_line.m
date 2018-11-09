function d = point_to_line(pt, v1, v2)
% Calcualtes the distance from a given point to the line defined by two 
% vertices. 
% 
% the vertices/points are defined as [x y z]
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end