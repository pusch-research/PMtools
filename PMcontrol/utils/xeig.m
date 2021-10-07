function varargout=xeig(a,varargin)
% compute eigenvalues in a sorted order (and apply numerical truncation for sorting)

if isa(a,'ss')
    a=a.a;
end

% number of significant digits for rounding complex numbers before sorting
i_digitsOpt=find(ismember('n_digits',varargin));
if ~isempty(i_digitsOpt)
    n_digits=varargin{i_digitsOpt+1};
    varargin(i_digitsOpt:i_digitsOpt+1)=[];
else
    n_digits=round(abs(log10(sqrt(eps))));   % default: use number accuracy of sqrt(eps)
end


if nargout<=1
    
    [Vr,d]=eig(a,varargin{:},'vector');
    d=sort_LOCAL(d,Vr,n_digits);
    varargout={d};
    
elseif nargout==2
    
    [Vr,d]=eig(a,varargin{:},'vector');
    [d,sort_iArr]=sort_LOCAL(d,Vr,n_digits);
    Vr=Vr(:,sort_iArr);
    
    varargout={Vr,d};
    
elseif nargout==3
    
    [Vr,d,Vl]=eig(a,varargin{:},'vector');

    [d,sort_iArr]=sort_LOCAL(d,Vr,n_digits);
    Vr=Vr(:,sort_iArr);
    Vl=Vl(:,sort_iArr);
    
    varargout={Vr,d,Vl};
    
else
   error('not implemented.'); 
end


function [d,sort_iArr]=sort_LOCAL(d,V,n_digits)

d=round(d,n_digits,'significant'); % eliminate numerical errors
[d,sort_iArr]=sort(d);

%% repeated eigenvalues - sort conjugate complex poles as + - + - according to eigenvector
% V=V(:,sort_iArr);
% 
% ii=1;
% while ii<=numel(d)
% 	if imag(d(ii))~=0
%         n_rep=sum(d(ii)==d(ii:end));
%         if n_rep==1
%             ii=ii+2*n_rep;
%             continue
%         end
%         
%         % re-sort according to eigenvector (assume sys is diagonalizable!)
%         c1_iArr=ii:(ii+n_rep-1);
%         c2_iArr=(ii+n_rep):(ii+2*n_rep-1);
%         c3_iArr=zeros(2*n_rep,1);
%         for jj=1:n_rep % c1
%         for kk=1:numel(c2_iArr) % c2
%             if norm(V(:,c1_iArr(jj))-conj(V(:,c2_iArr(kk))))<sqrt(eps)
%                 c3_iArr((2*jj-1))=c1_iArr(jj);
%                 c3_iArr(2*jj)=c2_iArr(kk);
%                 c2_iArr(kk)=[];
%                 break;
%             elseif kk==numel(c2_iArr)
%                 error('no conj complex eigenvector found');
%             end
%         end
%         end
%         sort_iArr(ii:ii+2*n_rep-1)=c3_iArr;
%         d(ii:ii+2*n_rep-1)=d(c3_iArr);
%         V(:,ii:ii+2*n_rep-1)=V(:,c3_iArr);
%         ii=ii+2*n_rep;
%     else
%         ii=ii+1;
% 	end
% end
                
       