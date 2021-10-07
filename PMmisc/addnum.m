function arr=addnum(arr,offset)

if nargin<=1
    offset=1;
end
num=(1:size(arr,1))'+offset-1;

if isnumeric(arr) || islogical(arr)
    arr=[num arr];
elseif iscell(arr)
    arr=[num2cell(num) arr];
elseif isstring(arr)
    arr=[string(num2cell(num)) arr];
else
    error('wrong data type.');
end

