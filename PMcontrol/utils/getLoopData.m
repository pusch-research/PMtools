% GETLOOPDATA 
%   
%   GETLOOPDATA() with C for positive feedback (from hinfsyn.m)
%   
%   Example:
%       
%   See also 

% REVISIONS:    2016-06-09 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=getLoopData(P,C,WinArr,WoutArr,varargin)

% parse inputs
gamma=[];
calcPeak='gam'; % {'gam','all','none'}
calcLoopSens=false; % {true,false}
for ii=1:2:numel(varargin) % overwrite userdefined parameters
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end


% reassign variables
if isfield(P.InputGroup,'acts')
    actsName_arr=P.InputName(P.InputGroup.acts);
elseif isfield(P.InputGroup,'acts_')
    actsName_arr=P.InputName(P.InputGroup.acts_);
else
    actsName_arr=C.OutputName; % user controller outputs
end
if isfield(P.OutputGroup,'meas')
    measName_arr=P.OutputName(P.OutputGroup.meas);
elseif isfield(P.OutputGroup,'meas_')
    measName_arr=P.OutputName(P.OutputGroup.meas_);
else
    measName_arr=C.InputName; % use controller inputs
end
if isfield(P.InputGroup,'dist')
    distName_arr=P.InputName(P.InputGroup.dist);
elseif isfield(P.InputGroup,'dist_')
    distName_arr=P.InputName(P.InputGroup.dist_);
else
    distName_arr=P.InputName(~ismember(P.InputName,actsName_arr)); % all inputs except 'acts' are 'dist'
end
if isfield(P.OutputGroup,'perf')
    perfName_arr=P.OutputName(P.OutputGroup.perf);
elseif isfield(P.OutputGroup,'perf_')
    perfName_arr=P.OutputName(P.OutputGroup.perf_);
else
    perfName_arr=P.OutputName(~ismember(P.OutputName,measName_arr)); % all outputs except 'meas' are 'perf'
end
n_dist=numel(distName_arr);
n_acts=numel(actsName_arr);
n_perf=numel(perfName_arr);
n_meas=numel(measName_arr);
n_out=n_perf+n_meas;
n_in=n_dist+n_acts;


% input handling
if nargin<=4, gamma=[]; end
if nargin<=3, WoutArr={}; end
if nargin<=2, WinArr={}; end
if isempty(WoutArr), WoutArr=1; end
if isempty(WinArr), WinArr=1; end
if isscalar(WoutArr), WoutArr=repmat({WoutArr},n_perf+n_meas,1); end
if isscalar(WinArr), WinArr=repmat({WinArr},n_dist+n_acts,1); end

% checks
if numel(WoutArr)~=n_out
    error('wrong size of output weights');
end
if numel(WinArr)~=n_in
    error('wrong size of input weights');
end


%% compute weighted plant and inv/weights for single loops


% compute inv/weights for single loops
W=ss; Winv=ss;
for i_in=1:n_dist
for i_out=1:n_perf
    W(i_out,i_in)=WoutArr{i_out}*WinArr{i_in};
    if isequal(WoutArr{i_out},0) || isequal(WinArr{i_in},0)
        Winv(i_out,i_in)=0;  
    else
        Winv(i_out,i_in)=inv(W(i_out,i_in)); %!TODO: super SLOW!!! rethink!!
    end
end
end
W(n_perf+n_meas,n_dist+n_acts)=0; % add acts/meas channels
Winv(n_perf+n_meas,n_dist+n_acts)=0; % add acts/meas channels

% set weight names
W.InputName=P.InputName;
Winv.InputName=P.InputName; 
W.OutputName=P.OutputName;
Winv.OutputName=P.OutputName;


% store weights
loopData.WoutArr=WoutArr;
loopData.WinArr=WinArr;
loopData.W=W;
loopData.Winv=Winv;

%% loops and peaks

% compute transfer matrices ('Si','So','Ti','To','CSo','PSi','C','P','CL')
if calcLoopSens
    loopTF=loopsens(sminreal(P(measName_arr,actsName_arr)),-C); % loop transfer matrices for plant & controller (loopsens.m requries negative feedback)
    loopTF=rmfield(loopTF,{'Stable','Poles'});
end
loopTF.C=C; % controller
loopTF.P=P; % plant
loopTF.CL=feedback(P,C,'Names',+1); % closed loop
loopData=combine_struct(loopData,loopTF);

% add weighted plant and weighted closed loop
Pweighted=blkdiag(WoutArr{:})*loopTF.P*blkdiag(WinArr{:});
Pweighted.InputName=P.InputName;
Pweighted.OutputName=P.OutputName;
loopData.Pweighted=Pweighted;
loopData.CLweighted=feedback(Pweighted,C,'Names',+1); % closed loop

% poles
loopData.poles.P=eig(P); % open loop
loopData.poles.C=eig(C);    % controller
loopData.poles.CL=eig(loopTF.CL);  % closed loop

% compute peaks (Hinf norm) of loops and corresponding frequency; store loops
if strcmpi(calcPeak,'all')
    loopData.peaks=struct();
    for loopName_act=fieldnames(loopTF)'
        str=loopName_act{:};
        % compute Hinf norm of current loop and corresponding frequency
        [peak,freq]=norm(loopTF.(str),'inf');
        % store loop data
        loopData.peaks.(str)=peak;
        loopData.peaks.(['w' str])=freq;
    end
end

% re-compute gamma (from hinfsyn.m) and corresponding frequency
if ismember(lower(calcPeak),{'all','gam'})
    [peak,freq]=norm(loopData.CLweighted(perfName_arr,distName_arr),'inf'); 
    if ~isempty(gamma) && any(abs(peak-gamma)/gamma>0.02)
        warning(['gamma value not equal: abs(' num2str(peak) '-' num2str(gamma) ')/' num2str(gamma) '=' num2str(abs(peak-gamma)/gamma)]);
    end
    loopData.peaks.GAM=peak;
    loopData.peaks.wGAM=freq;
end





%% return
if nargout>=1
    varargout{1}=loopData;
else
    dispLoopData(loopData);
end
