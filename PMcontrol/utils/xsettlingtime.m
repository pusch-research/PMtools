function [ts,tol]=xsettlingtime(t,y,p,yf)


if isvector(y), y=y(:); end % make column vector
n_y=size(y,2);
n_t=numel(t);
if n_t~=size(y,1), error('y and t must be of same length.'); end
if nargin<=2, p=0.01;end 
if nargin<=3, yf=y(end,:);
else yf=yf(:)'; end % make row vector
if numel(yf)==1, yf=repmat(yf,1,n_y); 
elseif numel(yf)~=n_y, error('y and yf must be of same length.'); end
if numel(p)==1, p=repmat(p,1,n_y);
elseif numel(p)==n_y, p=p(:)'; 
else error('y and p must be of same length.');end

err = abs(bsxfun(@minus,y,yf));
tol = p.*max(err);

ts=nan(1,n_y);
for i_y=1:n_y
    i_settle=find(err(:,i_y)>tol(i_y),1,'last');
    if isempty(i_settle)% pure gain
        ts(i_y)=0;
    elseif i_settle==n_t || any(isinf(err(:,i_y))) || any(isnan(err(:,i_y))) % has not settled
       %! extrapolation -> TODO!
       ts(i_y)=nan;
    elseif y(i_settle,i_y)~=y(i_settle+1,i_y) % interpolate for more accuracy
        y_settle=yf(i_y)+sign(y(i_settle,i_y)-yf(i_y)) * tol(i_y);
        ts(i_y)=t(i_settle)+(t(i_settle)-t(i_settle+1))/(y(i_settle,i_y)-y(i_settle+1,i_y)) * (y_settle-y(i_settle,i_y));
    else % discrete time or pure gain
        ts(i_y)=t(i_settle+1);
    end
end
