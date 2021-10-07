% XINTERSECT multiple set intersection
%   
%   XINTERSECT(e1,e2,..,en) intersects elements e1,e2,..,en
%       
%   See also INTERSECT

% REVISIONS:    2015-11-02 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function s=xintersect(varargin)


s=varargin{1};
for ii=2:nargin
   s=intersect(s,varargin{ii}); 
end