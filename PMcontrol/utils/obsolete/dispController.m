function []=dispController(dataset,opt)

if nargin<=1, opt='hinf'; end
opt=lower(opt);

labels=dataset.jobOpt.label;
idx=dataset.jobOpt.idx;
reg=dataset.jobOpt.sim.reg;
switch 3
    case 1 % in/out scaling
        reg.InputName=labels.outputPlotName(idx.y.meas);
        reg.OutputName=labels.inputPlotName(idx.u.acts);
        reg=ioscale(reg,1./labels.outputPlotFactor(idx.y.meas),labels.inputPlotFactor(idx.u.acts));
    case 2 % no scaling
        reg.InputName=labels.outputName(idx.y.meas);
        reg.OutputName=labels.inputName(idx.u.acts);
    case 3 % out scaling
        reg.InputName=labels.outputName(idx.y.meas);
        reg.OutputName=labels.inputPlotName(idx.u.acts);
        reg=ioscale(reg,[],labels.inputPlotFactor(idx.u.acts));
end


poles_lim=minmax(real(eig(reg)'));
if ~isempty(poles_lim) && order(reg)>0
   disp(['controller poles of ''' dataset.jobOpt.desc '''=' var2str(round(poles_lim,3))]); 
end

meas_max=max(dataset.postRes.dy_abs_max_arr(:,idx.y.meas),[],1);
disp(['max ' opt ' gain actuator signal of ''' dataset.jobOpt.desc ''':']);
if strcmp(opt,'d') || order(reg)==0
    data=bsxfun(@times,reg.d,meas_max);
elseif strcmp(opt,'h2')
    if poles_lim(2)>0, warning('controller is not stable, h2 norm cannot be computed.'); 
    else data=bsxfun(@times,singleNorm(reg,2),meas_max); end
elseif strcmp(opt,'dc')          
    data=bsxfun(@times,dcgain(reg),meas_max);
elseif strcmp(opt,'hinf')          
    data=bsxfun(@times,singleNorm(reg,inf),meas_max);
else
    error(['opt ''' opt '''not implemented.']);
end
disptable(data,reg.InputName,reg.OutputName);




% myTuner=tuner1;
% myTuner=tuner1_arr{84};
% postRes=anaDSet1.postRes;
% reg=myTuner.alcFeedbackReg;
% 
% 
% meas_max=max(postRes.dy_abs_max_arr(:,idx.ana.y.meas))*180/pi;
% 
% scal.h2=singleNorm(reg,2);
% scal.hinf=singleNorm(reg,inf);
% scal.dc=dcgain(reg);
% scal.d=reg.d;
% 
% ioscale(myTuner.alcFeedbackReg,myTuner.yScale_syn(idx.syn.y.meas),myTuner.uScale_syn(idx.syn.u.act))
% % disp('h2'); bsxfun(@times,singleNorm(reg,2),meas_max)
% % disp('hinf'); bsxfun(@times,singleNorm(reg,inf),meas_max)
% % disp('dc'); bsxfun(@times,dcgain(reg),meas_max)
% disp('d'); bsxfun(@times,reg.d,meas_max)