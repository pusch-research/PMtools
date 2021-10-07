% XSETFIELD set field of structure(cell)(array)
%   
%   S=XSETFIELD(S,FIELDNAME,VALUE) sets the value of the field FIELDNAME of
%   struct S. If S is an struct-array or cell-array of struct, 
%   VALUE must be either scalar or a cell array of same size than S.
%       
%   See also GETFIELD,XGETFIELD

% REVISIONS:    2014-10-23 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function s=xsetfield(s,fieldname,value)

if ~iscell(value) || ~isequal(size(value),size(s))
    value=repmat(value,size(s));
end

if iscell(s)
    for ii=1:numel(s)
       s{ii}.(fieldname)=value{ii}; 
    end
elseif isstruct(s)
    for ii=1:numel(s)
       s(ii).(fieldname)=value{ii}; 
    end
else
    error('xsetfield:wrongInput','wrong input type.');
end