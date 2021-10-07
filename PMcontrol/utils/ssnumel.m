% return number of state space systems in array
function [n]=ssnumel(sys)

s=size(sys);
n=prod(s(3:end));
