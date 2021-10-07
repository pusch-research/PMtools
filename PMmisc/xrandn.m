function m=xrandn(p,q,rc,isReal)
% rc=singular values

if nargin<1
    p=1;
end
if nargin<2
    q=p;
end
if nargin<3
    rc=rand(min(p,q),1);
end
if nargin<4
    isReal=false;
end

if any(rc<0) || numel(rc)>min(p,q)
    error('wrong rc.');
end


% input directions
v=randn(numel(rc),q);
if ~isReal
    v=v+1i*randn(numel(rc),q);
end
v=orth(v')';

% output directions
u=randn(p,numel(rc));
if ~isReal
    u=u+1i*randn(p,numel(rc));
end
u=orth(u);

% compute matrix
m=u*diag(rc)*v;