function sys=xmodred(sys,elim,varargin)

n_sys=size(sys(:,:,:),3);

% loop (multimodel)
for ii=1:n_sys
    sys(:,:,ii)=modred(sys(:,:,ii),elim,varargin{:});  
end