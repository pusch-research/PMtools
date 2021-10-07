% XISEQUAL checks for equality (extended)
%   
%   XISEQUAL(A,B,TOLREL) checks for equality of A and B,
%   numerical values less or equal than TOL are equal, where a 
%   TOLTYPE defines if absolute 'ABS' or relative 'REL' 
%   (default, noramlizing with A) is used.
%   
%   Example:
%       
%   See also ISEQUAL

% REVISIONS:    2014-12-10 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function b=xisequal(A,B,tol,tolType)


if nargin<=2
    tol=sqrt(eps);
end
if nargin<=3
    tolType='rel';
end


if tol==0
    
    b=isequal(A,B);

elseif ~isequal(class(A),class(B))
    
    b=false;
    
elseif ~isequal(size(A),size(B))
    
    b=false;

elseif isnumeric(A)

	b=maxErr(A(:),B(:),tolType)<=tol;
    
elseif ischar(A)
    
    b=strcmp(A,B);
    
elseif numel(A)>1
    
    for ii=1:numel(A)
        b=xisequal(A(ii),B(ii));
        if ~b
            return
        end
    end
    
elseif iscell(A) && iscell(B)
    
    b=xisequal(A{:},B{:},tol,tolType);
    
elseif isstruct(A) && isstruct(B)
    
    name_arr=fieldnames(A);
    if ~isequal(name_arr,fieldnames(B))
        b=false;
        return
    else
        for name_act=name_arr(:)'
            b=xisequal(A.(name_act{:}),B.(name_act{:}),tol,tolType);
            if ~b
                return
                if isnumeric(A.(name_act{:}))
                    disp([name_act{:} ' maxErrRel=' num2str(maxErr(A.(name_act{:}),B.(name_act{:})))]);
                end
            end
        end
        b=true;
    end
    
else
    b=isequal(A,B);
end





