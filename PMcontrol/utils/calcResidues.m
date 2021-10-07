function [residue_arr,pole_arr,sys]=calcResidues(sys,poleOpt,varargin)

if nargin<=1
    poleOpt=[];
end

% re-assign variables
n_x=order(sys);
[n_y,n_u]=size(sys);


% diagonalize system (with poles sorted)
[sys,pole_arr]=xcanon(sys,'diag',varargin{:});
[~,b,c,~]=ssdata(sys);


% select poles
if isempty(poleOpt)
    pole_iArr=1:n_x;
else
    pole_iArr=findPole(pole_arr,poleOpt);
end
pole_arr=pole_arr(pole_iArr);
n_pole=numel(pole_iArr);


% compute residues
residue_arr=zeros(n_y,n_u,n_pole);
for ii=1:n_pole
    residue_arr(:,:,ii)=c(:,pole_iArr(ii))*b(pole_iArr(ii),:);
end