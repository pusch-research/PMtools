% STROVERLAP checks for string overlap
%   A=STROVERLAP(STRA,STRB) checks for each string in STRA it it is part of
%   any string in STRB or any string in STRB is part of the respective string
%   in STRA. STRA and STRB can be strings or cell-arrays of strings. The
%   logical array A has the same number of elements as number of
%   strings in STRA.
%
%   See also STRFIND,STROVERLAPI

% REVISIONS:    2014-04-16 first implementation
% 
% Contact       pusch.research@gmail.com
%
function a=stroverlap(strA,strB)

if ~iscell(strB), strB={strB};end
if ~iscell(strA), strA={strA};end

a=false(size(strA));
for i=1:numel(strA)
    for j=1:numel(strB)
        if strfind(strA{i},strB{j}), a(i)=true; break;
        elseif strfind(strB{j},strA{i}), a(i)=true; break;
        end
    end
end

if ~any(a)
    %warning('strcontain:notFound',['No matching element found in array.' cell2str(strB)]);
end