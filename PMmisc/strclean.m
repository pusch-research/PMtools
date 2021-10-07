% STRCLEAN clean string
%   
%   STR=STRCLEAN(STR) the string or cell array of strings STR is cleaned
%   so only alphabetic, numeric or underscore characters are left. The 
%   function may be combined to automatically generate valid field names
%   for structures etc. 
%
%   STR=STRCLEAN(STR,EXPRESSION) the string or cell array of strings STR is 
%   cleaned so only characters defined in EXPRESSIONS are left. Details on 
%   EXPRESSION can be found in REGEXP.
%       
%   See also REGEXP

% REVISIONS:    2015-04-29 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function str=strclean(str,expression)

if nargin<2
    expression='\w';
end

if iscell(str)
    str=cellfun(@(x) x(regexp(x,expression)),str,'un',false);
else
    str=str(regexp(str,expression));
end