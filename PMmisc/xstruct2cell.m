% XSTRUCT2CELL Convert structure array to cell array.
%   
%   C=XSTRUCT2Cell(S)
%   C=XSTRUCT2CELL(S,FIELDNAMES) converts struct array to cell array
%   where size(S)=size(C)
%   Optionally, FIELDNAMES can be given to be selected.
%       
%   See also 

% REVISIONS:    2015-11-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function c=xstruct2cell(s,fieldNames)

if nargin>1
    if isempty(fieldNames)
        c=cell(size(s));
        return;
    elseif ~iscell(fieldNames)
        fieldNames={fieldNames};
    end
    fieldNames_act=fieldnames(s);
    s=rmfield(s,fieldNames_act(~ismember(fieldNames_act,fieldNames)));
end

for ii=numel(s):-1:1
   c{ii}=s(ii); 
end
