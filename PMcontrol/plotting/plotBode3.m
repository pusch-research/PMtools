function varargout=plotBode3(sys,w,outArr,inArr,varargin)

% (overwriteable) default values
allMarker_arr={'*';'o';'x';'s';'p';'+';'d';'*';'o';'x';'s';'p';'+';'d'};
bodeOpt=getBodeOpt('PhaseVisible','off','MagUnits','abs','MagScale','linear','FreqScale','linear');
zAxis='auto'; % z-axis values {'auto';'out': queue outputs (e.g. WRug1z); 'in': queue inputs (e.g. ted_cmd)}
scaling='auto'; % scale values at SINGLE frequency to allow better comparison {'auto';'normalized';''}
cmap='auto'; % color map
hFig=[]; % handle of figure
pos_dim=2; % dimension for positions to be plotted (default: 2=y-coordinate)
cval_lim=[]; % limits for colorbar/values {[]: auto=minmax vals,[min max]: given values}
lineStyle='auto'; % define line style for plotting; {'auto': auto;'none': colored markers will be plotted connected by dashed lines}
addLines='auto';
inGroupName='auto'; % name of input group (in case it is grouped); e.g. 'ted_cmd'
outGroupName='auto'; % name of output group (in case it is grouped); e.g. 'WRug1z'
if nargin<2 || isempty(w)
    w={1*2*pi 8*2*pi};
end

for ii=1:2:numel(varargin) % overwrite userdefined parameters
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
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


% figure
if isempty(hFig) || ~ishandle(hFig)
    hFig=figure('NumberTitle','off','Name','freqResp');
    if isequal(addLines,'auto')
        addLines=false;
    end
elseif isequal(addLines,'auto')
    addLines=true;
end
isSingleFreq=isnumeric(w) && numel(w)==1;






%% prepare input and output selection

% find output indices/groupNames
out_iArr=xname2index(sys,outArr,1); % get indices 
if strcmpi(outGroupName,'auto')
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
    if length(outGroupName)>15
        outGroupName=[outGroupName(1:15) '..'];
    end
end
if notempty(sys.UserData,'OutputPosition')
    outPos=sys.UserData.OutputPosition(pos_dim,:);
else
    outPos=nan(3,size(sys,1));
end


% find input indices/groupNames
in_iArr=xname2index(sys,inArr,2); % get indices 
if strcmpi(inGroupName,'auto')
    if isnumeric(inArr)
        inGroupName=sys.InputName(inArr); % get names of input indices
    elseif ischar(inArr)
        inGroupName={inArr}; % convert char to 1x cellstr
    else
        inGroupName={''};
    end
    if numel(inGroupName)~=1
        inGroupName=unique(regexprep(inGroupName,'\(\d+\)\.|\d+|\(\d+\)',''));% find unique expression for inputs (group)
    end
    if numel(inGroupName)~=1
        inGroupName=''; 
    else
        inGroupName=inGroupName{:}; % convert 1x cellstr to char
    end
    if length(inGroupName)>15
        inGroupName=[inGroupName(1:15) '..'];
    end
end
if notempty(sys.UserData,'InputPosition')
    inPos=sys.UserData.InputPosition(pos_dim,:);
else
    inPos=nan(3,size(sys,2));
end



%% update defaults
% zAxis
if strcmpi(zAxis,'auto')
    if isSingleFreq % for single frequencies, major variations are plotted on x-axis, z-axis represents minor variations
        if numel(out_iArr)>5, zAxis='in'; % assume that an output distribution (e.g. WRug1z) is to be plotted
        else zAxis='out'; end
    else % for multiple frequencies, major variations are plotted on z-axis (x-axis represents frequencies)
        if numel(out_iArr)>5, zAxis='out'; % assume that an output distribution (e.g. WRug1z) is to be plotted
        else zAxis='in'; end
    end
end

% scaling
if strcmpi(scaling,'auto')
   if (strcmp(zAxis,'in') && isempty(outGroupName)) || (strcmp(zAxis,'out') && isempty(inGroupName))
       scaling='normalized'; 
   else
       scaling='';
   end
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
if strcmpi(zAxis,'out')
    cval_arr=outPos(:,out_iArr);
elseif strcmpi(zAxis,'in')
    cval_arr=inPos(:,in_iArr);
end


% legend_arr
if strcmpi(zAxis,'out')
    legend_arr=sys.OutputName(out_iArr);
    for ii=1:numel(out_iArr)
       if ~isnan(outPos(out_iArr(ii)))
          legend_arr{ii}=[legend_arr{ii} '@' num2str(outPos(out_iArr(ii)),'%.2f') 'm'];
       end
    end
elseif strcmpi(zAxis,'in')
    legend_arr=sys.InputName(in_iArr);
    for ii=1:numel(in_iArr)
       if ~isnan(inPos(in_iArr(ii)))
          legend_arr{ii}=[legend_arr{ii} '@' num2str(inPos(in_iArr(ii)),'%.2f') 'm'];
       end
    end
end

if strcmp(lineStyle,'auto')
    lineStyle='-'; % default: draw line
    if isSingleFreq
       if  strcmpi(zAxis,'out') && numel(out_iArr)<5
           lineStyle='none'; % plot markers only
       elseif strcmpi(zAxis,'in') && numel(in_iArr)<5
           lineStyle='none'; % plot markers only
       end
    end
end



%% ------------------------------------------------------------------------
%  one single frequency (cut) for single outputs / output group
%  ------------------------------------------------------------------------
if isSingleFreq
    
    % get frequency response
    if isa(sys,'frd')
        H=sys.ResponseData(:,:,abs(sys.Frequency-w)<sqrt(eps),:);
    else
        H=freqresp(sys,w);
    end
    if size(H,3)~=numel(w)
       error('frequency not found.');
    end
    
    
    % initialization
    if strcmpi(zAxis,'out')
        % input(s) are plotted along x-axis, output(s) are plotted as different lines
        x=inPos(in_iArr);
        if any(isnan(x))
            x=1:numel(in_iArr); % positions not for all inputs given -> use indices
            x_label=[inGroupName ' (idx)']; % no unit
        else
            x_label=[inGroupName ' / m']; % unit in meters
        end
        y=abs(H(out_iArr,in_iArr));% [n_line x n_x]=[n_out(i_plot) x n_in]
    elseif strcmpi(zAxis,'in')
        % input(s) are plotted as different lines, output(s) are plotted along x-axis
        x=outPos(out_iArr);
        if any(isnan(x))
            x=1:numel(out_iArr); % positions not for all outputs given -> use indices
            x_label=[outGroupName ' (idx)']; % no unit
        else
            x_label=[outGroupName ' / m']; % unit in meters
        end
        y=abs(H(out_iArr,in_iArr))'; % transposed! [n_line x n_x]=[n_in x n_out(i_plot)]
    end
    
    % convert to dB if required
    if strcmp(bodeOpt.MagUnits,'dB')
        y=mag2db(y);
    end
    % normalize if required
    if strcmp(scaling,'normalized')
       y=bsxfun(@rdivide,y,max(y,[],2));
    end

    % plot
    if strcmp(lineStyle,'none')
        % init
        [n_line,n_point]=size(y);
        marker_arr=repmat(allMarker_arr(1:n_line),1,n_point)';
        x_marker=repmat(x,2,size(y,1));
        y_marker=y';
        y_marker=[-ones(1,numel(y_marker))*1000;y_marker(:)'];
        color_arr=repmat(cmap(n_point),n_line,1);
        
        % plot invisible lines with markers (for legend)
        hLine_arr=plot(x,y,'k','LineStyle','none','MarkerSize',6);
        hold on;
        plot(x,y,'k','LineStyle','--')
        set(hLine_arr,{'Marker'},allMarker_arr(1:n_line)); 
        
        % plot markers in different colors (invisible part below zero)
        marker_hArr=plot(x_marker,y_marker,'LineStyle','none','LineWidth',2,'MarkerSize',6);
        set(marker_hArr,{'Marker'},marker_arr(:));
        set(marker_hArr,{'Color'},num2cell(color_arr,2));
    else
        hLine_arr=plot(x,y);
        hold on;% in case other lines will be added from a top level function
        set(hLine_arr,'LineStyle',lineStyle);
        if ~isempty(cmap) % set color only if colormap is given
            set(hLine_arr,{'Color'},num2cell(cmap(size(y,1)),2));
        end
    end
    
    % label 
    if ~addLines % label axis only if desired
        xlabel(x_label,'Interpreter','none');
        xlim(minmax(x));
        y_lim=minmax(y(:)');
        y_lim=y_lim-[diff(y_lim) -diff(y_lim)]*0.05;
        ylim(y_lim);
        ylabel([scaling ' magnitude ' outGroupName ' / ' bodeOpt.MagUnits],'Interpreter','none');
        title([scaling ' magnitude ' outGroupName '@f=' num2str(w/(2*pi)) 'Hz / ' bodeOpt.MagUnits ],'Interpreter','none');
        grid on
        legend(hLine_arr,legend_arr,'Location','Best','Interpreter','none');
    end

    
    
%% ------------------------------------------------------------------------
%  standard bode plot for single outputs
%  ------------------------------------------------------------------------
else

    % initialization
    if iscell(w)
        w=linspace(w{1},w{2},400); % get relevant frequencies!
    end
    [H,w]=freqresp(sys(out_iArr,in_iArr),w);
    
    if strcmp(zAxis,'in')
        n_line=numel(in_iArr);
        H=reshape(permute(H,[1 3 2]),numel(out_iArr),1,numel(w),[]);
        sysfrd=frd(H,w);
        sysfrd.OutputName=sys.OutputName(out_iArr);
        sysfrd.InputName=inGroupName;
    elseif strcmp(zAxis,'out')
        n_line=numel(out_iArr);
        H=reshape(permute(H,[2 3 1]),1,numel(in_iArr),numel(w),[]);
        sysfrd=frd(H,w);
        sysfrd.InputName=sys.InputName(in_iArr);
        sysfrd.OutputName=outGroupName;
    end
    sysfrd.Name=sys.Name;
    
    % plot
    bode(sysfrd,w,bodeOpt);
    hold on
    hLine_arr=getResponsePlotLine(n_line);
    if ~isempty(cmap)
        if any(isnan(cval_arr(:))) || numel(cval_arr)~=n_line
            cval_arr=n_line; % assume equidistant I/O (as no values are given)
        elseif ~isempty(cval_lim)
           cval_arr=[cval_lim(1) cval_arr cval_lim(2)];  % add limits to increase color span
        end

        color_arr=xcolormap(cmap,cval_arr);
        
        if ~isempty(cval_lim) && ~isscalar(cval_arr)
           color_arr=color_arr(2:end-1,:); % delete limiting colors
        end
        
        set(hLine_arr,{'Color'},num2cell(repmat(color_arr,size(hLine_arr,2),1),2));
        
        if ~iscell(lineStyle)
            lineStyle={lineStyle};
        end
        if numel(lineStyle)~=numel(hLine_arr)
            lineStyle=repmat(lineStyle(:),numel(hLine_arr)/numel(lineStyle),1); % repeat linestyle pattern (error if not exact repetition is possible)
        end
        set(hLine_arr,{'LineStyle'},lineStyle);
        
    end
    if ~addLines
        legend(hLine_arr(:,1),legend_arr,'Interpreter','none');
    end

    x=w;
    y=H;
end


% format figure
makeLineHighlightable


% return
if nargout>0
    varargout{1}=hFig;
    varargout{2}=hLine_arr;
    varargout{3}=y;
    varargout{4}=x;
end





























%% OLD
%     % set default colormap
%     if ~isempty(cmap)
%         set(groot,'defaultAxesColorOrder',cmap(numel(in_iArr)));
%     end
%     
%     % plotting
%     for ii=1:numel(in_iArr)
%         bode(sys(out_iArr,in_iArr(ii)),w,bodeOpt); 
%         hold on
%     end
%         
%     % reset default colormap
%     if ~isempty(cmap)
%         set(groot,'defaultAxesColorOrder',linspecer(7,'qua'));
%     end 


