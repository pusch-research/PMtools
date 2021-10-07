function sys=sysclean(sys,tolAbs)
% set small values to zero (imag/real separately)





if nargin<2
   tolAbs=sqrt(eps); 
end


if isa(sys,'ss')

    [a,b,c,d]=ssdata(ssbal(sys)); % perform ssbal?!

    aR_iArr=abs(real(a))<tolAbs;
    aI_iArr=abs(imag(a))<tolAbs;
    aR=real(a);
    aR(aR_iArr)=0;
    aI=imag(a);
    aI(aI_iArr)=0;
    a=aR+1i*aI;
 
    bR_iArr=abs(real(b))<tolAbs;
    bI_iArr=abs(imag(b))<tolAbs;
    bR=real(b);
    bR(bR_iArr)=0;
    bI=imag(b);
    bI(bI_iArr)=0;
    b=bR+1i*bI;
    
    cR_iArr=abs(real(c))<tolAbs;
    cI_iArr=abs(imag(c))<tolAbs;
    cR=real(c);
    cR(cR_iArr)=0;
    cI=imag(c);
    cI(cI_iArr)=0;
    c=cR+1i*cI;
    
    dR_iArr=abs(real(d))<tolAbs;
    dI_iArr=abs(imag(d))<tolAbs;
    dR=real(d);
    dR(dR_iArr)=0;
    dI=imag(d);
    dI(dI_iArr)=0;
    d=dR+1i*dI;

    sys.a=a;
    sys.b=b;
    sys.c=c;
    sys.d=d;
    
elseif isa(sys,'zpk')
    
    [z,p,k]=zpkdata(sys);
    
    for ii=1:numel(z)
        zR_iArr=abs(real(z{ii}))<tolAbs;
        zI_iArr=abs(imag(z{ii}))<tolAbs;
        zR=real(z{ii}(zR_iArr));
        zR(zR_iArr)=0;
        zI=imag(z{ii}(zR_iArr));
        zI(zI_iArr)=0;
        z{ii}=zR+1i*zI;
    end

    for ii=1:numel(p)
        pR_iArr=abs(real(p{ii}))<tolAbs;
        pI_iArr=abs(imag(p{ii}))<tolAbs;
        pR=real(p{ii}(pR_iArr));
        pR(pR_iArr)=0;
        pI=imag(p{ii}(pR_iArr));
        pI(pI_iArr)=0;
        p{ii}=pR+1i*pI;
    end

    kR_iArr=abs(real(k))<tolAbs;
    kI_iArr=abs(imag(k))<tolAbs;
    kR=real(k);
    kR(kR_iArr)=0;
    kI=imag(k);
    kI(kI_iArr)=0;
    k=kR+1i*kI;
    
    
    sys.Z=z;
    sys.P=p;
    sys.K=k;
    
    
elseif isa(sys,'tf')

    [num,den] = tfdata(sys); 
    
    for ii=1:numel(num)
        nR_iArr=abs(real(num{ii}))<tolAbs;
        nI_iArr=abs(imag(num{ii}))<tolAbs;
        nR=real(num{ii});
        nR(nR_iArr)=0;
        nI=imag(num{ii});
        nI(nI_iArr)=0;
        num{ii}=nR+1i*nI;
    end

    for ii=1:numel(den)
        dR_iArr=abs(real(den{ii}))<tolAbs;
        dI_iArr=abs(imag(den{ii}))<tolAbs;
        dR=real(den{ii});
        dR(dR_iArr)=0;
        dI=imag(den{ii});
        dI(dI_iArr)=0;
        den{ii}=dR+1i*dI;
    end
    
    sys.Numerator=num;
    sys.Denominator=den;
    
elseif isnumeric(sys)
    
    sysR_iArr=abs(real(sys))<tolAbs;
    sysI_iArr=abs(imag(sys))<tolAbs;
    sysR=real(sys);
    sysR(sysR_iArr)=0;
    sysI=imag(sys);
    sysI(sysI_iArr)=0;
    sys=sysR+1i*sysI;
    
else
    
    error('not implemented.');
    
end
    
    
    
% n=sum(aR_iArr | aI_iArr)+...
%   sum(bR_iArr | bI_iArr)+...
%   sum(cR_iArr | cI_iArr)+...
%   sum(dR_iArr | dI_iArr);
