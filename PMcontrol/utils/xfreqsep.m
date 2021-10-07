function [sys,n]=xfreqsep(sys,f_Hz,opt)

% freqsepoptions
if nargin<=2
    opt=freqsepOptions;
end
if numel(opt)==1
    opt=repmat(opt,2,1);
end


n_low=nan;
f_low=f_Hz(1);
n_high=nan;
f_high=f_Hz(2);
n_full=order(sys);
c=2;


% cut off low frequencies (truncate)
if ~isnan(f_low) && f_low~=0
    sys=prescale(sys,{f_low*2*pi/c f_low*2*pi*c});
    [tmp,sys]=freqsep(sys,f_low*2*pi,opt(2));
    sys.d=sys.d+tmp.d; % keep d
    n_low=n_full-order(sys);
end

% cut off high frequencies (residualize)
if ~isnan(f_high)
    sys=prescale(sys,{f_high*2*pi/c f_high*2*pi*c});
    [sys,tmp]=freqsep(sys,f_high*2*pi,opt(2));
    sys.d=sys.d-(tmp.c/tmp.a)*tmp.b; % residualize
    n_high=n_full-n_low-order(sys);
end

% return size of cut off parts
n=[n_low n_high]; 