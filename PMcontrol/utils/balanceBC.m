function [b,c]=balanceBC(b,c,blkSizeArr)
    
n_x=size(b,1);
if n_x~=size(c,2)
    error('wrong dimension of b and c.');
end
if ~exist('blkSizeArr','var')
   blkSizeArr=ones(1,n_x);
end
    
n_blk=numel(blkSizeArr);

k_b=nan(n_x,1);
k_c=nan(n_x,1);

i_xBlk0=0;
for i_blk=1:n_blk
    xBlk_iArr=i_xBlk0+(1:blkSizeArr(i_blk));
    k_b(xBlk_iArr)=norm(b(xBlk_iArr,:));
    k_c(xBlk_iArr)=norm(c(:,xBlk_iArr));
    i_xBlk0=i_xBlk0+blkSizeArr(i_blk);
end

k=sqrt(k_c./k_b);

b=diag(k)*b;
c=c*diag(1./k);