% REPVAL repeated values
%   [V,K]=REPVAL(A) gets the repeated elements of a vector A
%   where V contains the values of the element and K the
%   K the multiplicity respectively. Vector V and K are of same length and 
%   have the same dimension as A.
%
%   A=REPVAL(V,K) returns a vector A with the i-th element of V
%   repeated K(i) times respectively. Vector V and K must be of same length.
%   If V and K are column vecotors A is also a column vector.
%   
%   Example: REPVAL([6 8],[1 2]) returns
%            A = [6 8 8]
%            REPVAL([6; 8; 8]) returns
%            V = [6; 8]
%            K = [1; 2]
%       
%   See also REPDIAG, REPMAX, REPMIN

% REVISIONS:    2015-04-29 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=repval(varargin)
%#ok<*AGROW>

if nargin==1 % get repeated elements of vector
    a=varargin{1};
    if ~isvector(a)
        error('repval:wrongInput','A must be a vector');
    end
    v=a(1);
    k=0;
    for i=1:numel(a)
        if v(end)~=a(i)
           v(end+1)=a(i);
           k(end+1)=1;
        else
           k(end)=k(end)+1; 
        end
    end
    
    if iscolumn(a) % convert to column vector
        v=v';
        k=k';
    end
    
    varargout{1}=v;
    varargout{2}=k;
elseif nargin==2 % create vector with repeated entries
    v=varargin{1};
    k=varargin{2};
    if numel(v)==numel(k) && min(size(v))==1
        a=[];
        for i=1:numel(k)
            a(end+1:end+k(i))=v(i);
        end   
        
        if iscolumn(v) && iscolumn(k) % convert to column vector
            a=a';
        end
            
        varargout{1}=a;
    else
       error('repval:wrongInput','input vectors v and k must be of same length.');
    end
else
   error('repval:wrongInput','Wrong number of inputs.'); 
end

