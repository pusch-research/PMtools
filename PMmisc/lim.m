% limit data points (upper/lower)
function x=lim(x,lims)

del_iArr=real(x)<real(lims(1)) | real(x)>real(lims(2)) | ...
         imag(x)<imag(lims(1)) | imag(x)>imag(lims(2)) ;
x(del_iArr)=[];
