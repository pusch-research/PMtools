% XLOOPMARGIN compute stability margins of loop
%
%   []=XLOOPMARGIN(LM) displays computed stability margins
%   LM=XLOOPMARGIN(SYS,REG,LMOPT) returns the worst case stability 
%   margins and frequencies defined in the cell string array LMOPT:
%   a) input margins with Li=C*P (single-loop=loop-at-a-time), in-perturb.
%       'ci'    classical gain/phase/delay margin
%       'di'    disk margin with |Si+Ti| for each single input
%       'mi'    disk margin with |Si+Ti| for all inputs simultaneously
%   b) output margins with Lo=P*C (single-loop=loop-at-a-time), out-perturb.
%       'co'    classical gain/phase/delay
%       'do'    disk margin with |So+To| for each single output
%       'mo'    disk margin with |So+To| for all outputs simultaneously
%   c) input/output margins (multi-loop), in&out-perturb
%       'mm'    disk margin for all inputs and outputs simult. (multi-loop)
%       'smm'   mm for each input/output combination (single-loop)         -- not implemented
%
%   The open loop system SYS may be an ss array with n_sys elements. The 
%   loop is closed with REG using the predefined input/output names. REG is
%   for negative feedback, but the resulting REG from  HINFSYN is for 
%   positive feedback (see loopmargin.m and hinfsyn.m). 
%
%   Furthermore, REG may be an ss array with n_reg elements. n_reg and 
%   n_sys must be equal or one of them is 1. 
%
%   Additionally, all margins are computed assuming a negative feedback of 
%   the open(cut) loop (see margin.m).
%
%   The results are stored in a cell array with the fields
%       .name       name of the margin (defined by LMOPT)
%       .unit       unit of the margin (magnitude [rad], phase [deg])
%       .type       i (input),o (output),io (single input/output),aio (all inputs&outputs)
%       .values     matrix with n_loop rows with worst case margins
%       .freqs      matrix with same size as .values with frequencies [rad]
%                   of worst case margins [rad]
%       
%
%   See also LOOPMARGIN

% REVISIONS:    2016-06-08 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=xloopmargin(sys,reg,lmOpt)
% LOOPMARGINS with plant SYS and controller REG
% see C:\Program Files\Matlab\R2014bX64\toolbox\robust\robust\@DynamicSystem\loopmargin.m -> prep
% see C:\Program Files\Matlab\R2014bX64\toolbox\shared\controllib\engine\+ltipack\@ltidata\loopmargin.m -> compute
% see C:\Program Files\Matlab\R2014bX64\toolbox\robust\rctutil\+rctutil\MinMargin.m -> disk (single-loop)
% see C:\Program Files\Matlab\R2014bX64\toolbox\shared\controllib\engine\+ltipack\@frddata\frddata.m -> mimo margins


%% handle input

% define all possible options
all_lmOpt=   {'ci','di','co','do','mi','mo','mm','smm'};
all_nMargin= [ 3    2    3    2    2    2    2    2   ]; % number of margins returned by lmOpt


% default parameters
if nargin<=2
    lmOpt=all_lmOpt(~ismember(all_lmOpt,'smm'));
end


% reassign variables
sys=sys(:,:,:); % make 1-D array
reg=reg(:,:,:); % make 1-D array
n_sys=size(sys,3);
n_reg=size(reg,3);
n_acts=size(reg,1);
n_meas=size(reg,2);
n_margin=sum(all_nMargin(ismember(all_lmOpt,lmOpt)));
n_loop=max(n_sys,n_reg);

% checks
if ~all(ismember(lmOpt,all_lmOpt))
    error('wrong lmOpt.');
end
if n_reg>1 && n_sys>1 && n_sys~=n_reg
    error('not implemented.');
end



%% initialization

% margin data
lm=repmat(struct( 'name',{},...
                  'unit',{},...
                  'type',{},...
                  'values',{},...
                  'freqs',{}),...
                  n_margin,1);
          
i_margin=1;
for ii=1:numel(lmOpt)   
    switch lmOpt{ii}
        case {'ci','di'} % input margins
            size_act=[n_loop n_acts];
            type_act='i';
        case {'co','do'} % output margins
            size_act=[n_loop n_meas];
            type_act='o';
        case {'mi','mo','mm'} % mm,mi,mo
            size_act=[n_loop 1];
            type_act=['a' strrep(lmOpt{ii}(2),'m','io')]; % {'ai': all inputs; 'ao': all outputs; 'aio': all inputs and outputs}
        case {'smm'} % smm
            size_act=[n_loop n_acts n_meas];
            type_act='io';
    end        

    % gain margin
    lm(i_margin).name=['GM' lmOpt{ii}];
    lm(i_margin).values=-inf(size_act);
    lm(i_margin).freqs=nan(size_act);
    lm(i_margin).unit='abs';
    lm(i_margin).type=type_act;
    i_margin=i_margin+1;
    
    % phase margin
    lm(i_margin).name=['PM' lmOpt{ii}];
    lm(i_margin).values=-inf(size_act);
    lm(i_margin).freqs=nan(size_act);
    lm(i_margin).unit='deg';
    lm(i_margin).type=type_act;
    i_margin=i_margin+1;
    
    % delay margin
    if lmOpt{ii}(1)=='c'
        lm(i_margin).name=['DM' lmOpt{ii}];
        lm(i_margin).values=-inf(size_act);
        lm(i_margin).freqs=nan(size_act);
        lm(i_margin).unit='s';
        lm(i_margin).type=type_act;
        i_margin=i_margin+1;
    end
   
end

if isempty(lmOpt) || isempty(reg)
    if nargout==1
        varargout{1}=lm;
    end
    return
end

%% prepare system

% get measurement outputs and actuator inputs
if isa(sys,'ss')
    if isfield(sys.OutputGroup,'meas')
        meas_iArr=sys.OutputGroup.meas;
    else
        try
            meas_iArr=findselection(reg.InputName,sys.OutputName); 
        catch
            if size(sys,1)==n_meas
                meas_iArr=1:n_meas; % all measurements (assume order is correct!)
            else
                error('no measruement outputs found');
            end
        end
    end
    if isfield(sys.InputGroup,'acts')
        acts_iArr=sys.InputGroup.acts;
    elseif size(sys,2)==n_acts
        acts_iArr=1:n_acts;
    else
        try
            acts_iArr=findselection(reg.OutputName,sys.InputName); 
        catch
            if size(sys,2)==n_acts
                meas_iArr=1:n_acts; % all actuators (assume order is correct!)
            else
                error('no actuator inputs found');
            end
        end
       
    end
end

% delete unecessary states
sys=sminreal(sys(meas_iArr,acts_iArr));



%% check stability

pole_arr=squeeze(eig(feedback(sys,reg,-1))); % compute poles (negative feedback!)
pole_arr(isnan(pole_arr))=-inf; % set not available poles (e.g. due to different number of states) to max. stable
isLoopStable_arr=max(real(pole_arr))<0;
if any(~isLoopStable_arr)
    warning('xloopmargin:unstable','One or more loops are unstable - margins are not valid/not computed!');
    n_loop=0; % do not compute any margins!
end
isLoopStableIn_arr=nan(n_loop,n_acts); % only computed for 'ci'
isLoopStableOut_arr=nan(n_loop,n_meas); % only computed for 'co'


%% compute and select worst case margins
for i_loop=1:n_loop

    % load sys
    if isa(sys,'ss')
        if n_sys>1
            sys_act=sys(:,:,i_loop);
        else
            sys_act=sys(:,:,1);
        end
    else
        error('not implemented.');
    end
    
    % load reg
    if n_reg>1
        reg_act=reg(:,:,i_loop);
    else
        reg_act=reg;
    end

    % compute margins
    [lm_act{1:numel(lmOpt)}]=loopmargin(sys_act,reg_act,strjoin(lmOpt,','));   % positive feedback
    
    % select worst case margins and corresponding frequency
    for ii=1:numel(lmOpt)
        i_GM=ismember({lm.name},['GM' lmOpt{ii}]);
        i_PM=ismember({lm.name},['PM' lmOpt{ii}]);
        
        if ismember(lmOpt{ii},{'mi','mo','mm'}) % multiloop disc margins
            lm(i_GM).values(i_loop,1)=max(lm_act{ii}.GainMargin);
            lm(i_GM).freqs(i_loop,1)=lm_act{ii}.Frequency;
            lm(i_PM).values(i_loop,1)=max(lm_act{ii}.PhaseMargin);
            lm(i_PM).freqs(i_loop,1)=lm_act{ii}.Frequency;
        elseif ismember(lmOpt{ii},{'smm'})
            error('not implemented.');
        elseif ismember(lmOpt{ii},{'di','do'}) % (multiloop) disc margins  - CAREFUL: siso stability not checked!
            for jj=1:numel(lm_act{ii})  
                lm(i_GM).values(i_loop,jj)=max(lm_act{ii}(jj).GainMargin);
                lm(i_GM).freqs(i_loop,jj)=lm_act{ii}(jj).Frequency;
                lm(i_PM).values(i_loop,jj)=max(lm_act{ii}(jj).PhaseMargin);
                lm(i_PM).freqs(i_loop,jj)=lm_act{ii}(jj).Frequency;
            end
        elseif ismember(lmOpt{ii},{'ci','co'}) % classical margins
            i_DM=ismember({lm.name},['DM' lmOpt{ii}]);
            if ~all([lm_act{ii}(:).Stable])
               warning(['i_sys=' num2str(i_loop) ' is unstable for ' lmOpt{ii}]);
            end
            if ismember(lmOpt{ii},'ci')
                isLoopStableIn_arr(i_loop,:)=lm_act{ii}(:).Stable;
            elseif ismember(lmOpt{ii},'co')
                isLoopStableOut_arr(i_loop,:)=lm_act{ii}(:).Stable;
            end  
            for jj=1:numel(lm_act{ii})
                if lm_act{ii}(jj).Stable % for a stable loop-at-a-time tf, dB(GM) must be > 0 to stay stable
                    [minGain_act,i_minGain]=min(lm_act{ii}(jj).GainMargin); 
                    [minPhase_act,i_minPhase]=min(abs(lm_act{ii}(jj).PhaseMargin)); % return min abs phase margin (loop is stable)
                else 
                    [minGain_act,i_minGain]=min(1./lm_act{ii}(jj).GainMargin); % for an unstable loop-at-a-time tf, dB(GM) must be < 0 to become stable (i.e. a gain>1 is required for stabilization)
                    [minPhase_act,i_minPhase]=min(lm_act{ii}(jj).PhaseMargin); % return negative phase margin
                    warning('test negative gain margins / unstable loop-at-a-time tf!');
                end
                [minDelay_act,i_minDelay]=min(lm_act{ii}(jj).DelayMargin); % make zero if unstable?
                if ~isempty(minGain_act)
                    lm(i_GM).values(i_loop,jj)=minGain_act;
                    lm(i_GM).freqs(i_loop,jj)=lm_act{ii}(jj).GMFrequency(i_minGain);
                end
                if ~isempty(minPhase_act)
                    lm(i_PM).values(i_loop,jj)=minPhase_act;
                    lm(i_PM).freqs(i_loop,jj)=lm_act{ii}(jj).PMFrequency(i_minPhase);
                end
                if ~isempty(minDelay_act)
                    lm(i_DM).values(i_loop,jj)=minDelay_act;
                    lm(i_DM).freqs(i_loop,jj)=lm_act{ii}(jj).DMFrequency(i_minDelay);
                end
            end
        end
    end
end

%! TODO:
% % FROM THEIS E:\BigWorkData\Exchange\From\16-06-07 fluttersuppression (Theis)\Part2_Analysis_AIAA16_RobustFlutterSuppression.m               
% % - the single loop disk margins at both input and output
% %   (simultaneous gain and phase perturbation)
% ny = 3;
% for yy = 1:ny
% OLtmp = feedback(fullsys_openloop,-K(1,setdiff(1:ny,yy)),'Names');
% singleMMIO = loopmargin(OLtmp(yy,1),-K(1,yy),'mm');
% fprintf('\t Single IO Disk Margin: \t\t %2.2f degrees / %2.2f dB \t at %3.1f rad/s\n',singleMMIO.PhaseMargin(2),db(singleMMIO.GainMargin(2)),singleMMIO.Frequency)
% end     



%% fast return
if nargout==1
    varargout{1}=lm;
    return;
end


%% get additional info  

% system names for displaying
if isa(sys,'ss') && n_sys>=n_reg
    if n_sys==1 % single system
       loopName_arr={sys.Name};
    else % multiple systems
        if isfield(sys.UserData,'name_arr') % look for a name_arr in UserData
           loopName_arr=sys.UserData.name_arr;
        elseif ~isempty(fieldnames(sys.SamplingGrid)) % look for SamplingGrid
            pName_arr=fieldnames(sys.SamplingGrid);
            n_p=numel(pName_arr);
            for i_loop=n_sys:-1:1
                pStr_arr=cell(1,n_p);
                for i_p=1:n_p
                    pStr_arr{i_p}=[pName_arr{i_p} '=' num2str(sys.SamplingGrid.(pName_arr{i_p})(i_loop))];
                end
                loopName_arr{i_loop}=strjoin(pStr_arr,';');
            end
        else % generic names
            loopName_arr=num2cellstr(1:n_sys);
        end
    end
else
    error('not implemented.');
end

% save info (for displaying margins)
info.loopName_arr=loopName_arr(:)';
if ~isa(reg,'DynamicSystem') || any(cellfun(@isempty,reg.InputName))
    info.inName_arr=sys.InputName(acts_iArr)';
else
    info.inName_arr=reg.OutputName(:)';
end
if ~isa(reg,'DynamicSystem') || any(cellfun(@isempty,reg.OutputName))
    info.outName_arr=sys.OutputName(meas_iArr)';
else
    info.outName_arr=reg.InputName(:)';
end

if any(cellfun(@isempty,info.inName_arr))
    info.inName_arr=arrayfun(@(ii) ['in' num2str(ii)],1:n_acts,'un',false); 
end
if any(cellfun(@isempty,info.outName_arr))
    info.outName_arr=arrayfun(@(ii) ['out' num2str(ii)],1:n_meas,'un',false); 
end

info.isLoopStable_arr=isLoopStable_arr(:)';
info.isLoopStableIn_arr=isLoopStableIn_arr;
info.isLoopStableOut_arr=isLoopStableOut_arr;

if nargout==2
    varargout{1}=lm;
    varargout{2}=info;
elseif nargout==0
    dispLoopmargin(lm,info)
end




    
    
    



