function valArr=linspacefill(val,n)

if numel(val)~=length(val), error('wrong input dimensions.'); end
if mod(n,1)~=0 || ~isscalar(n), error('n must be a scalar integer.'); end

sortVal=unique(val(:));
if (length(sortVal)==1 && n==0) || n==length(sortVal), valArr=sortVal; return;
elseif n<length(sortVal), error('n must be bigger than length(unique(val))'); end

minVal=sortVal(1);
maxVal=sortVal(end);
deltaVal=(maxVal-minVal)/n;

diffVal=diff(sortVal);
[n_gap]=max(diffVal/deltaVal-1,0);
i_split=n-(sum(floor(n_gap))+length(val));
if i_split<0
    n_gap_sel=n_gap(n_gap>1);
    [~,i_sort]=sort(n_gap_sel-floor(n_gap_sel),'ascend');
    n_gap_sel=floor(n_gap_sel(i_sort))-[ones(abs(i_split),1);zeros(length(n_gap_sel)-abs(i_split),1)]; % subtract one
    [~,i_sort]=sort(i_sort);
    n_gap(n_gap>1)=n_gap_sel(i_sort);
else
    [~,i_sort]=sort(n_gap-floor(n_gap),'descend');
    n_gap=floor(n_gap(i_sort))+[ones(i_split,1);zeros(length(n_gap)-i_split,1)]; % add one
    [~,i_sort]=sort(i_sort);
    n_gap=n_gap(i_sort);
end

if any(n_gap<0), error('n_gap<0'); end

valArr=[];
for ii=1:length(n_gap)
    insertVal_arr=sortVal(ii)+diffVal(ii)/(n_gap(ii)+1)*(0:n_gap(ii))';
    valArr=cat(1,valArr,insertVal_arr);
end
valArr=reshape(cat(1,valArr,maxVal),size(val,1),[]);