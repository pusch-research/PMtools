function varargout=plotReg(reg,varargin)

% parse input
p=inputParser;
addOptional(p,'combine','',@(x) ismember(x,{'in','out',''}));
addOptional(p,'w',{5e-2*2*pi 5e2*2*pi}); % frequency in [rad/s]
addOptional(p,'bodeOpt',getBodeOpt,@(x) isa(x,'plotopts.BodePlotOptions') );
parse(p,varargin{:});
w=p.Results.w;
combine=p.Results.combine;
bodeOpt=p.Results.bodeOpt;

%% do plotting
h=figure('Name',['reg' reg.Name],'NumberTitle','off');

% prepare for plotting
switch combine
    case 'in'
        for i_in=size(reg,2):-1:1
            regPlot{i_in}=reg(:,i_in);
            regPlot{i_in}.Name=regPlot{i_in}.InputName{:};
            regPlot{i_in}.InputName='meas';
        end
    case 'out'
        for i_out=size(reg,1):-1:1
            regPlot{i_out}=reg(i_out,:);
            regPlot{i_out}.Name=regPlot{i_out}.OutputName{:};
            regPlot{i_out}.OutputName='acts';
        end
    case ''
        regPlot={reg};
    otherwise
        error('not implemented.');
end

% plot
bodeplot(regPlot{:},w,bodeOpt)    
hArr=get(gcf,'Children');

addDoubleClickZoom(gcf,1,1);

hLine_arr=getResponsePlotLine();
if any(stroverlap(xgetfield(regPlot,'Name'),'ted'))
    set(hLine_arr,{'Color'},repmat(num2cell(jet(size(hLine_arr,1)),2),size(hLine_arr,2),1)); 
end
legend(hLine_arr(:,1),xgetfield(regPlot,'Name'),'Interpreter','none');


%% return
if nargout>0
    varargout{1}=h;
end