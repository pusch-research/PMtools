% XGETFIELD return field of structure(cell)(array)
%   
%   F=XGETFIELD(S,FIELDNAME) returns the value of the field FIELDNAME of
%   struct S. If S is an sturct-array or cell-array of struct, 
%   F is a cell array of same size than S. FIELDNAME may be a point
%   separated string or cellstr to directly access fields of sub-structures.
%       
%   See also GETFIELD,XSETFIELD

% REVISIONS:    2014-10-23 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function f=xgetfield(s,fieldname)

if ischar(fieldname)
    fieldname_arr=strsplit(fieldname,'.');
elseif iscell(fieldname)
    fieldname_arr=fieldname;
else
    error('invalid datatype of fieldname.'); 
end

if iscell(s)
    f=cellfun(@(c) c.(fieldname_arr{1}),s,'un',false);
elseif isstruct(s)
    if numel(s)>1
        f=arrayfun(@(se) se.(fieldname_arr{1}),s,'un',false);
    else
        f=s.(fieldname_arr{1}); % same behaviour as getfield.m
    end
else
    error('xgetfield:wrongInput','wrong input type.');
end


if numel(fieldname_arr)>1
   f=xgetfield(f,fieldname_arr(2:end)); % time consuming!!!! make it more efficient!!
end