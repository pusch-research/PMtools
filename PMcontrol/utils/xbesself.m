function sys=xbesself(varargin)
% see R2016b\toolbox\signal\signal\besself.m

[a,b,c,d]=besself(varargin{:});
sys=ss(a,b,c,d);