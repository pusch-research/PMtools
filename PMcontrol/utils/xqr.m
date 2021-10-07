% kind of a thin QR decomposition based on SVD with 
%   R not triangular!
%   size(R)=[rank(A) size(A,2)] (small singular values / directions are cut off)
function [Q,R]=xqr(A)

[U,S,V]=svd(A,'econ');
rk=rankLOCAL(A,diag(S));

Q=U(:,1:rk);
R=S(1:rk,1:rk)*V(:,1:rk)';







function r = rankLOCAL(A,s)
%RANK   Matrix rank.
%
%   RANK(A,S) is the number of singular values S of A larger than a given
%   tolerance
%
%   Class support for input A:
%      float: double, single

%   Copyright 1984-2015 The MathWorks, Inc.


tol = max(size(A)) * eps(max(s));
r = sum(s > tol);


