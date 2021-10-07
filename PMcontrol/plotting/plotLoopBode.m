function [h,loopData]=plotLoopBode(loopData,outArr,inArr,w,bodeOpt)




% reassign variables
sys=loopData.P;           % plant
peaks=loopData.peaks;     % Hinf norm of respective loops
n_sys=size(sys,3);


% checks
if n_sys~=1, error('not implented.'); end


% default values
if ~exist('w','var')
    % frequency in [rad/s]
    w={1e-2 1e2}; 
end 
if ~exist('inArr','var') || isempty(inArr)
    % default: select disturbance inputs
    inArr='dist'; 
end    
if ~exist('outArr','var') || isempty(outArr)
    % default: select performance outputs
    outArr='perf';
end    
if ~exist('bodeOpt','var') || isempty(bodeOpt)
    % default: bodeoptions from user preferences
    bodeOpt=getBodeOpt();
end
if isequal(inArr,inf)
    % select all inputs
    inArr={'dist','acts'}; 
end                     
if isequal(outArr,inf)
    % select all outputs
    outArr={'perf','meas'}; 
end                     


%% process input/output arrays

% convert in/out array to cell array
if isnumeric(inArr),  inArr=num2cell(inArr);
elseif ischar(inArr), inArr={inArr}; end                     
if isnumeric(outArr), outArr=num2cell(outArr);
elseif ischar(outArr), outArr={outArr}; end    
inName_arr=cell(size(inArr));
outName_arr=cell(size(outArr));

% get in/out names
for ii=1:numel(inArr)
    inName_arr{ii}=sys(:,inArr{ii}).InputName';
end   
for ii=1:numel(outArr)
    outName_arr{ii}=sys(outArr{ii},:).OutputName';
end
inName_arr=[inName_arr{:}]'; % remove group hierarchy
outName_arr=[outName_arr{:}]'; % remove group hierarchy
ioInfo=[xcell2str(inArr) '->' xcell2str(outArr)];

% get in/out indices
in_iArr=findselection(inName_arr,sys.InputName);
out_iArr=findselection(outName_arr,sys.OutputName);



%% plot single loops

h=figure('Name',['singleloop ' ioInfo],'NumberTitle','off');
bodeplot(sminreal(loopData.Winv(out_iArr,in_iArr))*peaks.GAM,...
         sminreal(loopData.P(out_iArr,in_iArr)),...
         sminreal(loopData.CL(out_iArr,in_iArr)),...
         w,bodeOpt); % 5*logspace(0,2,200),
hAx_arr=get(gcf,'Children');
legend(hAx_arr(end),'inv. weights * gamma','open loop','closed loop');





















% %% mark frequencies in all figures & axes
% 
% % select frequencies to mark
% freqMark_arr=nan(1,numel(freqMarkOpt)); % in radians
% for ii=1:numel(freqMarkOpt)
% switch class(freqMarkOpt{ii})
%     case 'char' % use frequency of peak of specific loop
%         freqMark_arr(ii)=peaks.(['w' freqMarkOpt{ii}]);
%     case 'double' % frequency directly given
%         freqMark_arr(ii)=freqMarkOpt{ii}; 
%     otherwise
%         error('not implemented.')
% end
% end
% 
% % delete non-visible frequencies
% if ~isempty(w)
%     if iscell(w)
%         freqMark_arr(freqMark_arr<w{1} || freqMark_arr>w{2})=[];
%     else
%         freqMark_arr(freqMark_arr<min(w) || freqMark_arr>max(w))=[];
%     end
% else
%     freqMark_arr(freqMark_arr<=0)=[];
% end
% 
% % mark frequencies with vertical line
% if strcmp(bodeOpt.FreqUnits,'Hz')
%     vline(h,freqMark_arr/(2*pi),'k');
% else
%     vline(h,freqMark_arr,'k');
% end

%%
% addDoubleClickZoom(gcf,1,1);
% maximize(1); 

