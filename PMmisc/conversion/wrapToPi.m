% WRAPTOPI
%   
%   AGNLE_RAD=WRAP2PI(ANGLE_RAD) 
%   
%   Example: wrap2pi(2*pi)
%       
%   See also WRAPTO2PI,WRAPTO180,WRAPTO360

function angle_rad=wrapToPi(angle_rad)

angle_rad = angle_rad - 2*pi*floor( (angle_rad+pi)/(2*pi) ); 