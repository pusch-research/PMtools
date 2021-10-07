function varargout=xtzero(varargin)
% computes transmission zeros and directions


if nargout<=2
    [z,nrank]=tzero(varargin{:});
    varargout={z nrank};
else
    [z,nrank]=tzero(varargin{:});
    
    % get system matrices
    if nargin>3
        [A,B,C,D]=deal(varargin{1:4});
    else
        [A,B,C,D]=ssdata(varargin{1});
    end
    
    % numbers
    n_x=length(A);
    n_z=numel(z);
    n_u=size(B,2);
    
    I=eye(n_x); % identiy matrix
    
    u0=nan(n_u,n_z);
    x0=nan(n_x,n_z);
    for ii=1:n_z
         RSM=[z(ii)*I-A  B
              -C         D];
         tmp=null(RSM);
         if size(tmp,2)>1
             error('not implemented.');
         end
         x0(:,ii)=tmp(1:n_x,:);
         u0(:,ii)=tmp(n_x+1:end,:);
    end

    varargout={z nrank x0 u0};
end