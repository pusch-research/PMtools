function varargout=plotLoopSigma(loopData,varargin)

% default sigmaOpt
sigmaOpt=sigmaoptions('cstprefs');
sigmaOpt.XLabel.Interpreter='none';
sigmaOpt.YLabel.Interpreter='none';
sigmaOpt.Title.Interpreter='none';
sigmaOpt.InputLabels.Interpreter='none';
sigmaOpt.OutputLabels.Interpreter='none';
sigmaOpt.Grid='on';

% parse input
p=inputParser;
addParameter(p,'outArr','perf');
addParameter(p,'inArr','dist');
addParameter(p,'plotWeight','',@(x) ismember(x,{'Win','Wout',''}));
addParameter(p,'w',{1e-2*2*pi 1e2*2*pi}); % frequency in [rad/s]
addParameter(p,'sigmaOpt',sigmaOpt,@(x) isa(x,'plotopts.SigmaPlotOptions') );
parse(p,varargin{:});
outArr=p.Results.outArr;
inArr=p.Results.inArr;
w=p.Results.w;
plotWeight=p.Results.plotWeight;
sigmaOpt=p.Results.sigmaOpt;


% reassign variables
sys=loopData.P;           % plant
peaks=loopData.peaks;     % Hinf norm of respective loops
if isequal(inArr,inf)
    % select all inputs
    inArr=sys.InputName; 
end                     
if isequal(outArr,inf)
    % select all outputs
    outArr=sys.OutputName; 
end                     


%% process input/output arrays

% convert in/out array to cell array
if isnumeric(inArr),  inArr=num2cell(inArr);
elseif ischar(inArr), inArr={inArr}; end                     
if isnumeric(outArr), outArr=num2cell(outArr);
elseif ischar(outArr), outArr={outArr}; end    

% get in/out names
ioInfo=[xcell2str(inArr) '->' xcell2str(outArr)];

% get in/out indices
in_iArr=xname2index(sys,inArr,2);
out_iArr=xname2index(sys,outArr,1);








%% plot sigma
h=figure('Name',['sigma ' ioInfo],'NumberTitle','off');
switch plotWeight
    case 'Win'  % include out weights (for sigma)
        sys_act=sminreal(blkdiag(loopData.WoutArr{out_iArr})*...
                         loopData.CL(out_iArr,in_iArr));
        for ii=numel(in_iArr):-1:1
            W_act{ii}=ss(peaks.GAM/loopData.WinArr{in_iArr(ii)});
        end

    case 'Wout'  % include in weights (for sigma)
        sys_act=sminreal(loopData.CL(out_iArr,in_iArr)*...
                         blkdiag(loopData.WinArr{in_iArr}));
        for ii=numel(out_iArr):-1:1
           W_act{ii}=ss(peaks.GAM/loopData.WoutArr{out_iArr(ii)}); 
        end
    case '' % include in & out weights (for sigma)
        sys_act=sminreal(blkdiag(loopData.WoutArr{out_iArr})*...
                         loopData.CL(out_iArr,in_iArr)*...
                         blkdiag(loopData.WinArr{in_iArr}));
        W_act={ss(peaks.GAM)};
    otherwise
        error('not implemented.');
end

% do plotting
cmap=get(groot,'defaultAxesColorOrder');
set(groot,'defaultAxesColorOrder',[repmat(cmap(1,:),numel(W_act),1);cmap(2,:)]);
for ii=1:numel(W_act)
    sigmaplot(W_act{ii},w,sigmaOpt);
    hold on;
end
set(findobj(h,'type','line'),'LineWidth',1.2); % make weight lines slightly thicker
sigmaplot(sys_act,w,sigmaOpt);
set(groot,'defaultAxesColorOrder',cmap);


%% return
if nargout>0
    varargout{1}=h;
end