% ONELINE convert multi-line string to one-line string
%   
%   ONESTR=ONELINE(MULTISTR) convert multi-line string to one-line string
%   
%   Example: oneline(var2str(struct('a',1,'b',2)))
%       
%   See also REGEXP, REGEXPREP

% REVISIONS:    2014-12-12 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function str=oneline(str)

str=regexp(str,'\.\.\.\n\ +','split'); % remove '...\n' and split simCaseStr
str=regexprep([str{:}],',\ +{',',{'); % remove blanks (before cell array) and join simCaseStr