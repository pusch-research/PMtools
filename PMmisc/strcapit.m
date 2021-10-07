% STRCAPIT capitalize string
%   
%   STRCAPIT(STR) capitalizes all words in a string or cell array of strings 
%   
%   Example: strcapit({'manuel','pusch'});
%       
%   See also REGEXPREP

% REVISIONS:    2014-08-13 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function str=strcapit(str)

if iscell(str)
    for i_cell=1:numel(str)
         str{i_cell}=strcapit(str{i_cell});
    end
else
    str=regexprep(str,'(\<[a-z])','${upper($1)}');
end
