% REPDIAG repeated diagonal matrices and repeated elements of a matrix diagonal
%   [V,K]=REPDIAG(A) gets the repeated elements of the diagnal of matrix A
%   where V contains the values of the diagonal element and K the
%   K the multiplicity respectively. Vector V and K are of same length.
%
%   A=REPDIAG(V,K) returns a diagonal matrix A with the i-th element of V
%   repeated K(i) times respectively. Vector V and K must be of same length.
%   
%   Example: repdiag([6 8],[1 2]) returns
%            A = 6     0     0
%                0     8     0
%                0     0     8
%            repdiag([6 0 0; 0 8 0; 0 0 8]) returns
%            V = 6 8
%            K = 1 2
%       
%   See also DIAG

% REVISIONS:    2014-03-07 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=repdiag(varargin)
%#ok<*AGROW>

if nargin==1 % get repeated diagonal elements of matrix
    A=varargin{1};
    if ismatrix(A) && min(size(A))>1
        d=diag(A);
        v=d(1);
        k=0;
        for ii=1:numel(d)
            if v(end)~=d(ii)
               v(end+1)=d(ii);
               k(end+1)=1;
            else
               k(end)=k(end)+1; 
            end
        end
        varargout{1}=v;
        varargout{2}=k;
    else
        error('xdiag:wrongInput','Input value is not a 2D matrix.')
    end
elseif nargin==2 % create matrix with repeated diagonal entries
    v=varargin{1};
    k=varargin{2};
    if numel(v)==numel(k) && min(size(v))==1
        d={};
        for ii=1:numel(k)
            d(end+1:end+k(ii))={v(ii)};
        end
        varargout{1}=blkdiag(d{:});
    else
       error('xdiag:wrongInput','input vectors v and k must be of same length.');
    end
else
   error('xdiag:wrongInput','Wrong number of inputs.'); 
end

