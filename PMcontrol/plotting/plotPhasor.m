function varargout=plotPhasor(sys,w,outArr,inArr,varargin)

% (overwriteable) default values
allMarker_arr={'.';'*';'x';'o';'s';'p';'+';'d';'.';'*';'x';'o';'s';'p';'+';'d'};
scaling='auto'; % scale values at SINGLE frequency to allow better comparison {'auto';'normalized';''}
cmap='auto'; % color map
hFig=[]; % handle of figure
phaseOffset=0; % phase offset {numeric: offset in [deg]; 'auto': largest magnitude points right; cell: magnitude of ref idx {output input} points right}
zAxis='auto'; % z-axis values {'auto';'out': queue outputs (e.g. WRug1z); 'in': queue inputs (e.g. ted_cmd),'': no zAxis}
allinone=false; % {'true': show all phasors in one plot,'false': one plot for each phasor) 
pos_dim=2; % dimension for positions to be plotted (default: 2=y-coordinate)
magUnit='abs'; % unit of magnitude {'abs','dB'}
lineOrder='auto'; % order how lines are plotted {'auto';'ascending';'descending'}; may be an array with n_plot elements
orientation='portrait'; % orientation of subplots {'portrait','landscape'}
lineName_arr={};
plotName_arr={};
legendLocation='best';
labelMag=false; % lable magnitude in grid
lineWidth=2;
markerSize=[];

for ii=1:2:numel(varargin) % overwrite userdefined parameters
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end

% prepare sys
if isnumeric(sys)
    if nargin>=2 && isempty(w)
        w=0;
    end
    sys=frd(sys,w); 
elseif nargin<2 || isempty(w)
    w=1*2*pi; % default: 1.7Hz
end

% default outputs
if nargin<3 || isempty(outArr)
    outArr=1:size(sys,1); % all outputs
end

% default inputs
if nargin<4 || isempty(inArr) || isequal(inArr,'ted')
    inArr=find(stroverlap(sys.InputName,'ted')); % default: ted input
    if numel(inArr)>10
        inArr=inArr(1:2:end); % select every second ted for faster plotting
    elseif numel(inArr)==0
        inArr=1:size(sys,2); % all inputs
    end
end

% default marker size
if isempty(markerSize)
    markerSize=5*lineWidth;
end

% figure
if isempty(hFig) || ~ishandle(hFig)
    hFig=figure('NumberTitle','off','Name',['phasor@' var2str(round(w/2/pi,3)) 'Hz']);
    addLines=false;
else
    addLines=true;
end


%% prepare input and output selection

% find output indices/groupNames
out_iArr=xname2index(sys,outArr,1); % get indices 
if isnumeric(outArr)
    outGroupName=sys.OutputName(outArr); % get names of output indices
elseif ischar(outArr)
    outGroupName={outArr}; % convert char to 1x cellstr
else
    outGroupName={''};
end
if numel(outGroupName)~=1
    outGroupName=unique(regexprep(outGroupName,'\(\d+\).|\d+',''));% find unique expression for outputs (group)
end
if numel(outGroupName)~=1
    outGroupName='';
else
    outGroupName=outGroupName{:}; % convert 1x cellstr to char
end
if length(outGroupName)>16
    outGroupName=[outGroupName(1:14) '..'];
end
if notempty(sys.UserData,'OutputPosition')
    outPos=sys.UserData.OutputPosition(pos_dim,:);
else
    outPos=nan(3,size(sys,1));
end


% find input indices/groupNames
in_iArr=xname2index(sys,inArr,2); % get indices 
if isnumeric(inArr)
    inGroupName=sys.InputName(inArr); % get names of input indices
elseif ischar(inArr)
    inGroupName={inArr}; % convert char to 1x cellstr
else
    inGroupName={''};
end
if numel(inGroupName)~=1
    inGroupName=unique(regexprep(inGroupName,'\(\d+\).|\d+',''));% find unique expression for inputs (group)
end
if numel(inGroupName)~=1
    inGroupName=''; 
else
    inGroupName=inGroupName{:}; % convert 1x cellstr to char
end
if length(inGroupName)>16
    inGroupName=[inGroupName(1:14) '..'];
end
if notempty(sys.UserData,'InputPosition')
    inPos=sys.UserData.InputPosition(pos_dim,:);
else
    inPos=nan(3,size(sys,2));
end


%% update defaults


% zAxis
if strcmpi(zAxis,'auto')
    if numel(out_iArr)>5 || numel(in_iArr)==1
        zAxis='out'; % assume that an output distribution (e.g. WRug1z) is to be plotted
    else
        zAxis='in';
    end
end


% phase offset
if ~isnumeric(phaseOffset)
   error('not implemented'); 
end
   
% colormap
if strcmpi(cmap,'auto')
    if addLines
        cmap=[]; % when lines are added use default colormap
    else
        cmap=@jet;
    end
end
if ~isempty(cmap)
    if ischar(cmap)
        cmap=str2func(cmap);
    elseif isnumeric(cmap)
        if size(cmap,1)==1
            cmap=@(n) repmat(cmap,n,1);
        else
            cmap=@(n) cmap(1:n,:);
        end
    elseif ~isa(cmap,'function_handle')
        error('wrong datatype for cmap.');
    end
end  


%% initialization

% compute response
if isa(sys,'frd')
    H=sys.ResponseData(out_iArr,in_iArr,abs(sys.Frequency-w)<sqrt(eps),:);
elseif isnumeric(sys)
    H=sys(out_iArr,in_iArr);
else
    H=freqresp(sys(out_iArr,in_iArr),w);
end
if size(H,3)~=numel(w)
   error('frequency not found.');
end
if size(H,3)>1
    error('not implemented.');
end


% prepare response [n_row n_col n_line]
if strcmp(zAxis,'in')
    H=permute(H,[1 3 2]);
    % lines: inputs
    if isempty(lineName_arr)
        lineName_arr=sys.InputName(in_iArr);
        for ii=1:numel(in_iArr)
           if ~isnan(inPos(in_iArr(ii)))
              lineName_arr{ii}=[lineName_arr{ii} '@' num2str(inPos(in_iArr(ii)),'%.2f') 'm'];
           end
        end
    end
    % (sub)plots: outputs
    if isempty(plotName_arr)
        for ii=numel(out_iArr):-1:1
            if ~isnan(outPos(out_iArr(ii)))
                posStr=['@' num2str(outPos(out_iArr(ii)),'%.2f') 'm'];
            else
                posStr='';
            end
            if isempty(sys.OutputName{out_iArr(ii)}) && isempty(posStr)
                plotName_arr{ii,1}='';
            else
                plotName_arr{ii,1}=[inGroupName '->' sys.OutputName{out_iArr(ii)} posStr];
            end
        end
        plotName_arr=cellfun(@(x) [scaling ' ' x ' / ' magUnit],plotName_arr,'un',false);
    end
elseif strcmp(zAxis,'out')
    H=permute(H,[2 3 1]);
    % lines: outputs
    if isempty(lineName_arr)
        lineName_arr=sys.OutputName(out_iArr);
        for ii=1:numel(out_iArr)
           if ~isnan(outPos(out_iArr(ii)))
              lineName_arr{ii}=[lineName_arr{ii} '@' num2str(outPos(out_iArr(ii)),'%.2f') 'm'];
           end
        end
    end
    % (sub)plots: inputs
    if isempty(plotName_arr)
        for ii=numel(in_iArr):-1:1
            if ~isnan(inPos(in_iArr(ii)))
                posStr=['@' num2str(inPos(in_iArr(ii)),'%.2f') 'm'];
            else
                posStr='';
            end
            if isempty(sys.InputName{in_iArr(ii)}) && isempty(posStr)
                plotName_arr{1,ii}='';
            else
                plotName_arr{1,ii}=[sys.InputName{in_iArr(ii)} posStr '->' outGroupName];
            end
        end
        plotName_arr=cellfun(@(x) [scaling ' ' x ' / ' magUnit],plotName_arr,'un',false);
    end
    
elseif strcmp(zAxis,'')
    %lineName_arr={''};
    if isempty(plotName_arr)
        plotName_arr=cell(size(H,1),size(H,2));
        for i_out=1:size(H,1)
        for i_in=1:size(H,2)
            if isempty(sys.InputName(in_iArr(i_in)))
                plotName_arr{i_out,i_in}=sys.OutputName(out_iArr(i_out));
            elseif isempty(sys.OutputName(out_iArr(i_out)))
                plotName_arr{i_out,i_in}=sys.InputName(in_iArr(i_in));
            else
                plotName_arr{i_out,i_in}=[sys.InputName(in_iArr(i_in)) '->' sys.OutputName(out_iArr(i_out))];
            end
        end
        end
        plotName_arr=cellfun(@(x) [scaling ' ' x ' / ' magUnit],plotName_arr,'un',false);
    end
else
    error('not implemented.')
end
[n_row,n_col,n_line]=size(H);
n_plot=numel(plotName_arr);


% scaling
if strcmp(scaling,'auto')
    if allinone && n_plot>1
        scaling='normalized';
    else
        scaling='';
    end
end

% colored
isColored=~isempty(cmap) && size(unique(cmap(n_line),'rows'),1)>1;

%% compute magnitude/phase

% magnitude
mag_arr=abs(H);
if strcmp(magUnit,'dB')
    mag_arr=mag2db(mag_arr);
end
if strcmp(scaling,'normalized')
    mag_arr=bsxfun(@rdivide,mag_arr,max(mag_arr,[],3)); 
end

% phase
phase_arr=angle(H);
% add phase offset
phase_arr=phase_arr-phaseOffset;
% make all values to be within [-pi pi]
phase_arr(phase_arr>pi)=phase_arr(phase_arr>pi)-2*pi;
phase_arr(phase_arr<-pi)=phase_arr(phase_arr<-pi)+2*pi;

% compute tips of arrows
x_arr=mag_arr.*cos(phase_arr);
y_arr=mag_arr.*sin(phase_arr);


%% line order
if ~iscell(lineOrder)
    lineOrder={lineOrder};
end
if numel(lineOrder)==1
    lineOrder=repmat(lineOrder,n_plot,1);
elseif numel(lineOrder)~=n_plot
    error('wrong number of elements.');
end

for i_row=n_row:-1:1
for i_col=n_col:-1:1
    i_plot=(i_row-1)*n_col+i_col;
    if strcmpi(lineOrder{i_plot},'auto')
        if abs(H(i_row,i_col,1))>abs(mean(H(i_row,i_col,:)))
            lineOrder{i_plot}='ascending'; 
        else
            lineOrder{i_plot}='descending'; 
        end
    end
end
end

if ~all(ismember(lower(lineOrder),{'ascending','descending'}))
    error('wrong line order.');
end


%% plot phasor diagram

if allinone

    marker_arr=reshape(repmat(allMarker_arr(1:n_plot)',n_line,1),[],1);

    hLine_arr=plot([zeros(1,numel(x_arr));x_arr(:)'],...
                   [zeros(1,numel(y_arr));y_arr(:)']);
    hLine_arr=reshape(hLine_arr,n_plot,[])'; % [n_line n_plot]
    
    hold on;
    
%         hMarker_arr=plot([zeros(1,numel(x_arr));x_arr(:)'],...
%                        [zeros(1,numel(y_arr));y_arr(:)'],...
%                        'k','LineWidth',2,'MarkerSize',10,'LineStyle','none');
%         hMarker_arr=reshape(hMarker_arr,n_plot,[])'; % [n_line n_plot]

    if imag(w)~=0
       title([scaling ' phasor@s=' num2str(w,'%.2f') ' / ' magUnit],'Interpreter','none') 
    else
       title([scaling ' phasor@f=' num2str(w/(2*pi)) 'Hz / ' magUnit],'Interpreter','none') 
    end
    
      
else
    
    marker_arr=allMarker_arr(1);
    
    for i_row=n_row:-1:1
    for i_col=n_col:-1:1

        i_plot=(i_row-1)*n_col+i_col;
        if n_row*n_plot~=1
            if strcmpi(orientation,'portrait')
                subplot(n_row,n_col,i_plot);
            elseif strcmpi(orientation,'landscape')
                subplot(n_col,n_row,i_plot);
            else
                error('not implemented.');
            end
        end
        hold on;

        hLine_arr(:,i_plot)=plot(...                                       % [n_line n_plot]
            [zeros(1,n_line);reshape(x_arr(i_row,i_col,:),1,[])],...
            [zeros(1,n_line);reshape(y_arr(i_row,i_col,:),1,[])]); 
        
%             hMarker_arr(:,i_plot)=plot(...                                     % [n_line n_plot]
%                 [zeros(1,n_line);reshape(x_arr(i_row,i_col,:),1,[])],...
%                 [zeros(1,n_line);reshape(y_arr(i_row,i_col,:),1,[])],...
%                 'k','LineWidth',2,'MarkerSize',10,'LineStyle','none'); 

        if imag(w)~=0
            title([scaling ' phasor@s=' num2str(w,'%.2f') ' / ' magUnit],'Interpreter','none') 
        else
            if ~isempty(plotName_arr{i_row+(i_col-1)*n_row})
                title(plotName_arr{i_row+(i_col-1)*n_row},'Interpreter','none')
            end
        end
        
    end
    end 
    

    
end

% set reverse direction if necessary
for i_plot=1:n_plot
    if strcmpi(lineOrder{i_plot},'descending')
        hParent=get(hLine_arr(1,i_plot),'Parent');
        children_hArr=get(hParent,'Children');
        line_iArr=findselection(double(hLine_arr(:,i_plot)),double(children_hArr));
        children_hArr(line_iArr)=children_hArr(flip(line_iArr));
        set(hParent,'Children',children_hArr);
    end
end

% set linestyle
if ~isempty(cmap)
    set(hLine_arr,{'Color'},num2cell(repmat(cmap(n_line),n_plot,1),2));
end
set(hLine_arr,{'Marker'},marker_arr);
set(hLine_arr,'LineWidth',lineWidth);
set(hLine_arr,'MarkerSize',markerSize);
%set(hLine_arr,'MarkerEdgeColor','k');

% legend
if allinone && n_plot>1
    
    if isColored % colorbar only if more than 5 colors
        colormap(cmap(n_line));
        colorbar('Ticks',linspace(0,1,n_line),'TickLabels',lineName_arr,'TickLabelInterpreter','none');
        legendMarkerColor='k';
    else
        legendMarkerColor=cmap(1);
    end
    
    % label fake 'marker' 
    hold on
    tmp_hArr=plot(zeros(2,n_plot),zeros(2,n_plot),'Color',legendMarkerColor,'LineStyle','none','LineWidth',2,'MarkerSize',10); % fake marker in origin which are all black
    set(tmp_hArr,{'Marker'},marker_arr(1:n_line:end));
    
    if ~all(cellfun(@isempty,plotName_arr))
        legend(tmp_hArr,plotName_arr,'Interpreter','none','Location',legendLocation);
    end

else
    % label 'lines' (only in one plot)
    if ~all(cellfun(@isempty,lineName_arr))
        legend(hLine_arr(:,1),lineName_arr,'Interpreter','none','Location',legendLocation);
    end
end



%% plot gridlines
% copy from \\rm-samba01\Matlab\Win32\R2015bX64\toolbox\matlab\graph2d\polar.m

hAxes_arr=unique(xcell2mat(get(hLine_arr,'Parent'))); %findobj(gcf,'Type','Axes');
for ii=1:numel(hAxes_arr)
    cax=hAxes_arr(ii);
    axes(cax);
    children_act=get(cax,'Children');
    
    % get x-axis text color so grid is in same color
    % get the axis gridColor
    axColor = get(cax, 'Color');
    gridAlpha = get(cax, 'GridAlpha');
    axGridColor = get(cax,'GridColor').*gridAlpha + axColor.*(1-gridAlpha);
    tc = axGridColor;
    ls = get(cax, 'GridLineStyle');
    
    
    
    % make a radial grid
    hold(cax, 'on');
    % ensure that Inf values don't enter into the limit calculation.
    set(cax, 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatioMode', 'auto');
    v = [get(cax, 'XLim') get(cax, 'YLim')];
    ticks = sum(get(cax, 'YTick') >= 0);
    % check radial limits and ticks
    rmin = 0;
    rmax = max(abs(v)); %v(4);
    rticks = max(ticks - 1, 2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks, 2) == 0
            rticks = rticks / 2;
        elseif rem(rticks, 3) == 0
            rticks = rticks / 3;
        end
    end
    
    
    % define a circle
    th = 0 : pi / 50 : 2 * pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1 : (length(th) - 1) / 4 : length(th);
    xunit(inds(2 : 2 : 4)) = zeros(2, 1);
    yunit(inds(1 : 2 : 5)) = zeros(3, 1);
    % plot background if necessary
    if ~ischar(get(cax, 'Color'))
        patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
            'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
            'HandleVisibility', 'off', 'Parent', cax);
    end

    % plot spokes
    th = (1 : 6) * 2 * pi / 12;
    cst = cos(th);
    snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
        'HandleVisibility', 'off', 'Parent', cax);
    
    % draw radial circles
    c82 = cos(82 * pi / 180);
    s82 = sin(82 * pi / 180);
    rinc = (rmax - rmin) / rticks;
    for i = (rmin + rinc) : rinc : rmax        
        hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
    end
    if labelMag
        for i = (rmin + rinc) : rinc : rmax   
            text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ...
                 ['  ' num2str(i,2)], 'VerticalAlignment', 'bottom', ...
                 'HandleVisibility', 'off', 'Parent', cax);
        end
    end
    set(hhh, 'LineStyle', '-'); % Make outer circle solid

    % annotate spokes in degrees
    rt = 1.1 * rmax;
    for i = 1 : length(th)
        text(rt * cst(i), rt * snt(i), int2str(i * 30),...
            'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
        if i == length(th)
            loc = int2str(0);
        else
            loc = int2str(180 + i * 30);
        end
        text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
    end

    
    % set view to 2-D
    view(cax, 2);
    % set axis limits
    axis(cax, rmax * [-1, 1, -1.15, 1.15]);
    
    set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
    
    uistack(children_act,'top');
    
    % grey dot in the middle
    if all(ismember(marker_arr,'.'))
        hDot=plot(gca,0,0,'.','Color',tc,'MarkerSize',10);
    else
        hDot=plot(gca,0,0,'.','Color',tc,'MarkerSize',45); % big circle
    end
    set(get(get(hDot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

%% return
if nargout>0
    varargout{1}=hFig;
    varargout{2}=hLine_arr;
    varargout{3}=mag_arr;
    varargout{4}=phase_arr;
end