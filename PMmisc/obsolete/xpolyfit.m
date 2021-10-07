function [p,S,mu]=xpolyfit(x,y,n,dim)


%% type differentiation
if ~isnumeric(y)
    yClass=class(y);
    switch yClass
        case 'ss'
            [~,~,ySize]=sssize(y);    
            if ~exist('dim','var') || isempty(dim)
                    dim=find(ySize>1,1,'last'); % last non-singelton dimension
            end   
            if ySize(dim)<n
                error('non unique solution. not implemented for ss.');
            end
            
            % compute coefficients
            pa=xpolyfit(x,y.a,n,dim+2);
            pb=xpolyfit(x,y.b,n,dim+2);
            pc=xpolyfit(x,y.c,n,dim+2);
            pd=xpolyfit(x,y.d,n,dim+2);
            
            % update ss (such that fields like Input/Output Names etc. are not overwritten)
            strArgEval=repmat({':'},numel(ySize)+2,1);
            strArgEval{dim+2}=['1:' num2str(n+1)];
            p=y;
            eval(['p(' strjoin(strArgEval,',') ')=ss(pa,pb,pc,pd);']); % insert pa/pb/pc/pd
            strArgEval{dim+2}=[num2str(n+2) ':end'];
            eval(['p(' strjoin(strArgEval,',') ')=[];']); % delete all other ss
            
            return
        case 'tf'
            
        otherwise 
            error('not implemented.');
    end
    
end

%% n-d array
ySize=size(y);    
if ~exist('dim','var') || isempty(dim)
        dim=find(ySize>1,1,'last'); % last non-singelton dimension
end   
x=x(:);
if numel(x)~=size(y,dim)
    error('wrong size of x and y');
end
n_elem=prod(ySize)/ySize(dim); % number of elements

% make interpol dimension last and vectorize (i.e. y=[n_elem*size(y,dim) 1])
dimPerm=[1:dim-1 dim+1:numel(ySize) dim];
y=reshape(permute(y,dimPerm),[],1); 



% for better numerical stability
if nargout > 2
    mu = [mean(x); std(x)];
    x = (x - mu(1))/mu(2);
end


% Construct the Vandermonde matrix V = [x.^n ... x.^2 x ones(size(x))]
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x.*V(:,j+1);
end
V=kron(V,eye(n_elem));

% Solve least squares problem p = V\y to get polynomial coefficients p.
[Q,R] = qr(V,0);
p = R\(Q'*y);               % Same as p = V\y

% re-sort
pSize=ySize(dimPerm);
pSize(end)=n+1;
dimPerm=[1:dim-1 numel(ySize) dim:numel(ySize)-1];
p = permute(reshape(p,pSize),dimPerm);

if size(R,2) > size(R,1)
    warning(message('MATLAB:polyfit:PolyNotUnique'))
end
if nargout > 1
    r = y - V*p;
    % S is a structure containing three elements: the triangular factor
    % from a QR decomposition of the Vandermonde matrix, the degrees of
    % freedom and the norm of the residuals.
    S.R = R;
    S.df = max(0,length(y) - (n+1));
    S.normr = norm(r);
end


