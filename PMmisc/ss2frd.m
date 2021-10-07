function frdSys=ss2frd(ssSys,frequency)

warning('bullshit');
frdSys=frd(ssSys,frequency);

i_zero=frdSys.Frequency==0;

% overwrite frequency zero by dcgain -> bullshit as phase is missing?!
if any(i_zero)
   sys_size=[size(ssSys) 1];
   n_y=sys_size(1);
   n_u=sys_size(2);
   n_sys=prod(sys_size(3:end));
   fresp0=reshape(dcgain(ssSys),n_y,n_u,1,n_sys);
   frdSys.ResponseData(:,:,i_zero,:)=fresp0;
end