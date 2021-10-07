% return size of state space system (array)
function [n_out,n_in,varargout]=sssize(sys)

s=size(sys);

n_out=s(1);
n_in=s(2);

if numel(s)==2
    arr_size=[1 1];
elseif numel(s)==3
    arr_size=[s(3) 1];
else
    arr_size=s(3:end);
end

if nargout<=3
    varargout{1}=arr_size;
else
    varargout=num2cell(arr_size);
end
