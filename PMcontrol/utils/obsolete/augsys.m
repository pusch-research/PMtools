% AUGSYS augment ss model for Hinf controller synthesis
%   
%   [AUGSYS,N_INGROUP,N_OUTGROUP]=AUGSYS(SYS,N_MEAS,N_ACTS,INGROUPARR,OUTGROUPARR)
%   where the signal groups listed below are augmented to the
%   state-space system SYS. SYS has N_DIST+N_ACTS inputs and N_PERF+N_MEAS
%   outputs. The augmented signals are added before the measurement signals
%   (meas) and the actuator signals (acts) in the order given by the input
%   arguments INGROUPARR and OUTGROUPARR.
%
%   input groups INGROUPARR:
%       dist: disturbance signals
%   	meas_noise: noise at input(s) of controller (measurement signals)
%   	meas_dist: disturbance at output(s) of plant (measurement signals)  --- not implemented
%   	acts_noise: noise at output(s) of controller (actuator signals)     --- not implemented
%   	acts_dist: disturbance at input(s) of plant (actuator signals)
%       acts: actuator signals
%   where '_noise' is associated with the controller and '_dist' with
%   the plant. 
%
%   output groups OUTGROUPARR:
%       perf: performance signals
%   	meas_perf: measurement performance (signal output between meas_noise and meas_dist inputs)
%   	acts_effort: control effort (signal output between acts_noise and acts_dist inputs)
%       meas: measurement signals
%       
%   See also HINFSYN,SS

% REVISIONS:    2016-06-06 first implementation (MP)
%               TODO: add reference output/input,'meas_dist','acts_noise'
% 
% Contact       pusch.research@gmail.com
%
function [augSys,n_inGroup,n_outGroup]=augsys(sys,n_meas,n_acts,inGroupArr,outGroupArr)


n_perf=size(sys,1)-n_meas; % original number of performance signals
n_dist=size(sys,2)-n_acts; % original number of disturbance signals

% all inGroup/outGroup in the predefined order
inGroupAll_arr={'other_dist','meas_noise','acts_dist','acts'}; %'meas_dist','acts_noise' (not implemented yet)
outGroupAll_arr={'other_perf','meas_perf','acts_effort','meas'};
% sizes of inGroup/outGroup
n_inGroupAll=[n_dist n_meas n_acts n_acts];
n_outGroupAll=[n_perf n_meas n_acts n_meas];
% checks
if ~all(ismember(inGroupArr,inGroupAll_arr)) || ~all(ismember(outGroupArr,outGroupAll_arr)) 
    error('wrong group names for augmentation.');
end
if hasdelay(sys)
    error('not implemented.')
end




% extract matrices
[A,B,C,D]=ssdata(sys);

%##########################################################################
% augment inputs (for measurements/actuators)
%##########################################################################

% [dist---------------------meas_noise--------------acts_dist---------------------acts----------------------------]
B=[B(:           ,1:n_dist) zeros(size(B,1),n_meas) B(:           ,n_dist+1:end)  B(:           ,n_dist+1:end)    ];   % -- states
D=[D(1:n_perf    ,1:n_dist) zeros(n_perf   ,n_meas) D(1:n_perf    ,n_dist+1:end)  D(1:n_perf    ,n_dist+1:end);...     % -- perf
   D(n_perf+1:end,1:n_dist) zeros(n_meas)           D(n_perf+1:end,n_dist+1:end)  D(n_perf+1:end,n_dist+1:end)         % -- meas_perf
   D(n_perf+1:end,1:n_dist) eye(n_meas)             D(n_perf+1:end,n_dist+1:end)  D(n_perf+1:end,n_dist+1:end)    ];   % -- meas
n_inAug=sum(n_inGroupAll(2:end-1)); % number of inputs augmented



%##########################################################################
% augment outputs (for measurements/actuators)
%##########################################################################

% [dist+meas_noise+acts_noise+acts]
C=[C(1:n_perf    ,:);...        % -- perf
   C(n_perf+1:end,:)            % -- meas_perf
   zeros(n_acts,size(C,2));...  % -- acts_effort
   C(n_perf+1:end,:)      ];    % -- meas

% [dist+meas_noise+acts_dist----------acts----------------------------------]
D=[D(1:n_perf+n_meas,1:(n_dist+n_inAug))     D(1:n_perf+n_meas,(n_dist+n_inAug)+1:end);...     % -- perf+meas_perf
   zeros(n_acts,(n_dist+n_inAug))            eye(n_acts)                           ;...        % -- acts_effort
   D(n_perf+n_meas+1:end,1:(n_dist+n_inAug)) D(n_perf+n_meas+1:end,(n_dist+n_inAug)+1:end)];   % -- meas
%D(n_perf+1:n_perf+n_meas,n_dist+1:n_dist+n_meas)=0; % no feedthrough from meas_noise to meas_perf
n_outAug=sum(n_outGroupAll(2:end-1)); % number of outputs augmented


% re-assamble state space system
augSys=ss(A,B,C,D);
augSys.StateName=sys.StateName;

% add input/output name if existing
if all(cellfun(@(x) ~isempty(x),sys.InputName)) && all(cellfun(@(x) ~isempty(x),sys.OutputName))
    inName_arr=sys.InputName;
    outName_arr=sys.OutputName;
    outName_arr=[outName_arr(1:n_perf);...                                           % perf
                 cellfun(@(x) [x '_perf'],outName_arr(n_perf+1:end),'un',false);...  % meas_perf
                 cellfun(@(x) [x '_effort'],inName_arr(n_dist+1:end),'un',false);... % acts_effort
                 outName_arr(n_perf+1:end)];                                         % meas
    inName_arr=[inName_arr(1:n_dist);...                                                 % dist
                cellfun(@(x) [x '_noise'],outName_arr(end-n_meas+1:end),'un',false);...  % meas_noise
                cellfun(@(x) [x '_dist'],inName_arr(end-n_acts+1:end),'un',false);...    % acts_dist
                inName_arr(n_dist+1:end);];                                              % acts                                     
    augSys.StateName=sys.StateName;
end

% add all input/output group names (including original and augmented inputs/outputs)
for i_g=1:numel(inGroupAll_arr)
     augSys.InputGroup.(inGroupAll_arr{i_g})=sum(n_inGroupAll(1:i_g-1))+(1:n_inGroupAll(i_g));
end
for i_g=1:numel(outGroupAll_arr)
     augSys.OutputGroup.(outGroupAll_arr{i_g})=sum(n_outGroupAll(1:i_g-1))+(1:n_outGroupAll(i_g));
end
augSys.InputGroup.dist=1:sum(n_inGroupAll(1:end-1)); % all disturbance channels
augSys.OutputGroup.perf=1:sum(n_outGroupAll(1:end-1)); % all performance channels

% select desired NONEMPTY input/output groups
n_inGroup=n_inGroupAll(findselection(inGroupArr,inGroupAll_arr));
n_outGroup=n_outGroupAll(findselection(outGroupArr,outGroupAll_arr));
outSel_iArr=xname2index(augSys,outGroupArr(n_outGroup>0),1);
inSel_iArr=xname2index(augSys,inGroupArr(n_inGroup>0),2);
augSys=augSys(outSel_iArr,inSel_iArr);
augSys.OutputName=outName_arr(outSel_iArr);
augSys.InputName=inName_arr(inSel_iArr); 
