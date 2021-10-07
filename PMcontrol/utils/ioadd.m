% ADDIO add inputs/outputs to ss system
%   
%   ADDIO(sys,Badd,Cadd,Dadd,inAddNameArr,outAddNameArr) 
%   

% REVISIONS:    2016-05-31 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%

function sys=ioadd(sys,Badd,Cadd,Dadd,inAddNameArr,outAddNameArr)

inName_arr=sys.InputName;
outName_arr=sys.OutputName;
inGroup=sys.InputGroup;
outGroup=sys.OutputGroup;
n_x=order(sys);
[n_out,n_in,n_sys]=size(sys(:,:,:));
n_inAdd=size(Badd,2);
n_outAdd=size(Cadd,1);

if n_sys>1
    error('not implemented.');
end
if ~exist('Dadd','var') || isempty(Dadd)
    Dadd=0;
end
if ~exist('inAddNameArr','var') || isempty(inAddNameArr)
    inAddNameArr=repmat({''},n_inAdd,1);
end
if ~exist('outAddNameArr','var') || isempty(outAddNameArr)
    outAddNameArr=repmat({''},n_outAdd,1);
end
if size(Cadd,2)==1
   Cadd=repmat(Cadd,1,n_x); 
end
if size(Badd,1)==1
   Badd=repmat(Badd,n_x,1); 
end

savedUserData=sys.UserData;
sys=[eye(n_out);zeros(n_outAdd,n_out)]*sys*[eye(n_in) zeros(n_in,n_inAdd)];
sys.UserData=savedUserData;
sys.c(n_out+1:end,:)=Cadd;
sys.b(:,n_in+1:end)=Badd;

if n_inAdd==0
    sys.d(n_out+1:end,:)=Dadd;
elseif n_outAdd==0
    sys.d(:,n_in+1:end)=Dadd;
elseif isequal(size(Dadd),[n_out+n_outAdd n_in+n_inAdd])
    sys.d(n_out+1:end,n_in+1:end)=Dadd(n_out+1:end,n_in+1:end);
elseif isscalar(Dadd)
    sys.d(n_out+1:end,n_in+1:end)=Dadd;
else
   error('not implemented.'); 
end

sys.InputName=[inName_arr;inAddNameArr(:)];
sys.OutputName=[outName_arr;outAddNameArr(:)];
sys.InputGroup=inGroup;
sys.OutputGroup=outGroup;







