%POLYVAL Evaluate polynomial.
%   Y = POLYVAL(P,X) returns the value of a polynomial P evaluated at X. P
%   is a vector of length N+1 whose elements are the coefficients of the
%   polynomial in descending powers.
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
%   If X is a matrix or vector, the polynomial is evaluated at all
%   points in X.  See POLYVALM for evaluation in a matrix sense.
%
%   [Y,DELTA] = POLYVAL(P,X,S) uses the optional output structure S created
%   by POLYFIT to generate prediction error estimates DELTA.  DELTA is an
%   estimate of the standard deviation of the error in predicting a future
%   observation at X by P(X).
%
%   If the coefficients in P are least squares estimates computed by
%   POLYFIT, and the errors in the data input to POLYFIT are independent,
%   normal, with constant variance, then Y +/- DELTA will contain at least
%   50% of future observations at X.
%
%   Y = POLYVAL(P,X,[],MU) or [Y,DELTA] = POLYVAL(P,X,S,MU) uses XHAT =
%   (X-MU(1))/MU(2) in place of X. The centering and scaling parameters MU
%   are optional output computed by POLYFIT.
%
%   Example:
%      Evaluate the polynomial p(x) = 3x^2+2x+1 at x = 5,7, and 9:
%
%      p = [3 2 1];
%      polyval(p,[5 7 9])%
%
%   Class support for inputs P,X,S,MU:
%      float: double, single
%
%   See also POLYFIT, POLYVALM.

%   Copyright 1984-2017 The MathWorks, Inc.

%   DELTA can be used to compute a 100(1-alpha)% prediction interval
%   for future observations at X, as Y +/- DELTA*t(alpha/2,df), where
%   t(alpha/2,df) is the upper (alpha/2) quantile of the Student's t
%   distribution with df degrees of freedom.  Since t(.25,df) < 1 for any
%   degrees of freedom, Y +/- DELTA is at least a 50% prediction interval
%   in all cases.  For large degrees of freedom, the confidence level
%   approaches approximately 68%.
function [y, delta] = xpolyval(p,x,dim,S,mu)



if nargin < 5
    mu=[0 1];
end
if nargin<4
    S=[];
end
x=x(:)'; % row-vector
n_x = numel(x); % number of evaluation points

%% type differentiation
if ~isnumeric(p)
    yClass=class(p);
    switch yClass
        case 'ss'
            [~,~,pSize]=sssize(p);    
            if ~exist('dim','var') || isempty(dim)
                    dim=find(pSize>1,1,'last'); % last non-singelton dimension
            end   
            
            % compute ss matrices
            a=xpolyval(p.a,x,dim+2,S,mu);
            b=xpolyval(p.b,x,dim+2,S,mu);
            c=xpolyval(p.c,x,dim+2,S,mu);
            d=xpolyval(p.d,x,dim+2,S,mu);
            
            % update ss (such that fields like Input/Output Names etc. are not overwritten)
            strArgEval=repmat({':'},numel(pSize)+2,1);
            strArgEval{dim+2}=['1:' num2str(n_x)];
            y=p;
            eval(['y(' strjoin(strArgEval,',') ')=ss(a,b,c,d);']); % insert pa/pb/pc/pd
            strArgEval{dim+2}=[num2str(n_x+1) ':end'];
            eval(['y(' strjoin(strArgEval,',') ')=[];']); % delete all other ss
            
            return
        case 'tf'
            
        otherwise 
            error('not implemented.');
    end
    
end




%% default (numeric)
pSize=size(p);
if ~exist('dim','var') || isempty(dim)
    dim=find(pSize>1,1,'last'); % last non-singelton dimension
end
n_elem=prod(pSize)/pSize(dim); % number of elements
n = pSize(dim); % polynomial order


% make interpol dimension last and vectorize (i.e. p=[n_elem x n])
dimPerm=[1:dim-1 dim+1:numel(pSize) dim];
p=reshape(permute(p,dimPerm),n_elem,[]); 

% back-scale x (see polyfit.m)
if nargin == 4
   x = (x - mu(1))/mu(2);
end

% Use Horner's method for general case where X is an array.
y = zeros(n_elem,n_x);
if n > 0
    y = repmat(p(:,1),1,n_x);
end
for ii = 2:n
    y = bsxfun(@times,y,x)+p(:,ii);
end

% reshape
ySize=pSize(dimPerm);
ySize(end)=n_x;
dimPerm=[1:dim-1 numel(pSize) dim:numel(pSize)-1];
y=permute(reshape(y,ySize),dimPerm);


if nargout > 1
    error('not implemented.');
%     if nargin < 3 || isempty(S)
%         error(message('MATLAB:polyval:RequiresS'));
%     end
%     
%     % Extract parameters from S
%     if isstruct(S)  % Use output structure from polyfit.
%       R = S.R;
%       df = S.df;
%       normr = S.normr;
%     else             % Use output matrix from previous versions of polyfit.
%       [ms, ns] = size(S);
%       if ms ~= ns+2 || nc ~= ns
%           error(message('MATLAB:polyval:SizeS'));
%       end
%       R = S(1:nc,1:nc);
%       df = S(nc+1,1);
%       normr = S(nc+2,1);
%     end
% 
%     % Construct Vandermonde matrix for the new X.
%     x = x(:);
%     V = zeros(length(x),nc,class(x));
%     V(:,end) = 1;
%     for j = nc-1:-1:1
%         V(:,j) = x.*V(:,j+1);
%     end
% 
%     % S is a structure containing three elements: the triangular factor of
%     % the Vandermonde matrix for the original X, the degrees of freedom,
%     % and the norm of the residuals.
%     E = V/R;
%     e = sqrt(1+sum(E.*E,2));
%     if df == 0
%         warning(message('MATLAB:polyval:ZeroDOF'));
%         delta = Inf(size(e),class(e));
%     else
%         delta = normr/sqrt(df)*e;
%     end
%     delta = reshape(delta,siz_x);
end

