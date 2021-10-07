% ISUNST check if system(s) are unstable
%   
%   ISUNST(SYS,'param',value,..) plot poles in a figure
%   [ISUNST,POLEUNST,SAMPLINGGRID]=ISUNST(SYS,'param',value,..)
%   return boolean array ISUNST indicating which system the ss array SYS
%   is unstable. The cell array POLEUNST contains the corresponding 
%   unstable poles and the SAMPLINGGRID the sampling points of the 
%   unstable systems.
%   Optional input parameters are described below.
%   
%   Example:
%       
%   See also EIG,SS

% REVISIONS:    2018-05-30 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=isUnst(sys,varargin)

%% varargin

% range where to search unstable poles 
wn_range=[0 inf]; % frequency range to search for unstable poles; default: [-1e-1 inf] (exclude origin)
real_range=[-inf inf]; % range of real part to search for unstable poles
imag_range=[-inf inf]; % range of imaginary part to search for unstable poles
opt=''; % {'first','last',''} stop after first/last index is found (faster)
% for plotting
cmap=@jet; % color map to plot poles (if no ouput arguments)
xlim_range=[]; % limit x axis
ylim_range=[];% limit y axis
markerSize=15; % marke size of poles
markerEdgeColor='auto'; % edge color
hFig=[]; % figure handle
animOpt=struct([]); % modeshape animation options
animGeom=struct([]); % modeshape animation geometry

% read varargin
for ii=1:2:numel(varargin) % overwrite userdefined parameters
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end

% check
if wn_range(1)>wn_range(2) || real_range(1)>real_range(2) || imag_range(1)>imag_range(2)
    error('range input incorrect.');
end
enableModeAnim=~isempty(animGeom);

%% loop
[~,~,sysSize]=sssize(sys);
n_sys=prod(sysSize);
if strcmpi(opt,'first') || isempty(opt)
    sys_iArr=1:n_sys;
elseif strcmpi(opt,'last')
    sys_iArr=n_sys:-1:1;
else
    error('not implemented.');
end

polesUnst=cell(sysSize);
isUnstIdx=false(sysSize);
pole_arr=cell(sysSize);
blksize_arr=cell(sysSize);
pR_range=[0 0];
pI_range=[0 0];
for i_sys=sys_iArr
    
    if enableModeAnim
        [sys(:,:,i_sys),pole_arr{i_sys},~,~,~,~,blksize_arr{i_sys}]=xcanon(sys(:,:,i_sys),'jordan','cond_max',1e11);
    else
        pole_arr{i_sys}=eig(sys(:,:,i_sys));
    end
    wn_arr=abs(pole_arr{i_sys});
    pR_arr=real(pole_arr{i_sys});
    pI_arr=imag(pole_arr{i_sys});

    sel_iArr=pR_arr>=real_range(1) & pR_arr<=real_range(2) &...
             pI_arr>=imag_range(1) & pI_arr<=imag_range(2) &...
             wn_arr>=wn_range(1) & wn_arr<=wn_range(2);
    sel_iArr=find(sel_iArr);

    pR_range=minmax([minmax(pR_arr(sel_iArr)') pR_range]);
    pI_range=minmax([minmax(pI_arr(sel_iArr)') pI_range]);
    polesUnst{i_sys}=pole_arr{i_sys}(sel_iArr(pR_arr(sel_iArr)>0));
    isUnstIdx(i_sys)=~isempty(polesUnst{i_sys});

    if ~isempty(opt) && isUnstIdx(i_sys)
        break; % stop after firt/last unstable sys is found
    end

end

grdUnst=sys(:,:,isUnstIdx).SamplingGrid;


%% return / plot

if nargout==0

    if isempty(hFig)
        hFig=figure('Name','Unstable Poles','NumberTitle','off');
        axes;
    else
        %axes(hFig);
    end
    hFig.CloseRequestFcn=@CloseRequestFcn; % ensure that animation figure is closed
    
    % sampling parameter
    pName_arr=fieldnames(sys.SamplingGrid);
    pNum_arr=cellfun(@(x) numel(unique(sys.SamplingGrid.(x))),pName_arr);
    if sum(pNum_arr>1)==1 % only one varying dimension
        pName=pName_arr{pNum_arr>1};
        pVal_arr=sys.SamplingGrid.(pName)(:)';
    else
        pName='idx';
        pVal_arr=1:n_sys;
        if isempty(pName_arr)
            sys.SamplingGrid.idx=1:n_sys;
        end
    end
    
    color_arr=xcolormap(cmap,pVal_arr);

    if ~isempty(xlim_range)
        xlim(xlim_range);
    else
        xlim(pR_range);
    end
    if ~isempty(ylim_range)
        ylim(ylim_range);
    else
        ylim(pI_range);
    end
    
    hAx=gca;
    if ~notempty(hAx.UserData,'sgrid')
        sgrid on
        set(findall(hAx,'Type','line'),'Color',[1 1 1]*0.6);
        set(findall(hAx,'Type','Text'),'Color',[1 1 1]*0.6);
        %set(findall(hAx,'Type','text'),'Color',[1 1 1]*0.3);
        hAx.UserData.sgrid='on';
    end
    hold on
    
    for i_sys=1:n_sys
        
        % plot
        h=plot(real(pole_arr{i_sys}),imag(pole_arr{i_sys}),'.',...
            'MarkerSize',markerSize,'MarkerEdgeColor',markerEdgeColor,...
            'Color',color_arr(i_sys,:));
        
        % sys string
        sysStr=['sys#' num2str(i_sys)];
        for ii=1:numel(pName_arr)
           sysStr=[sysStr ' ' pName_arr{ii} '=' num2str(sys(:,:,i_sys).SamplingGrid.(pName_arr{ii}))]; 
        end
        
        % add doubleClick eventHandler
        h.ButtonDownFcn=@(hObj,event) buttonDownFcn(hObj,event,pole_arr{i_sys},sys(:,:,i_sys),blksize_arr{i_sys},animGeom,animOpt,sysStr); 
    
    end
    xlabel('real part');
    ylabel('imaginary part');
    
    if range(pVal_arr)>0
        colormap(interp1(pVal_arr,color_arr,linspace(min(pVal_arr),max(pVal_arr),100)))
        if max(pVal_arr)-min(pVal_arr)>0
            hCbar=colorbar;
            hCbar.Label.String=pName;
            hCbar.Label.Interpreter='none';
            caxis(minmax(pVal_arr));
            if numel(pVal_arr)<10
               hCbar.Ticks=pVal_arr; 
            end
        end
    end
    
    % save data
    hAx.UserData.isUnstIdx=isUnstIdx;
    hAx.UserData.polesUnst=polesUnst;
    hAx.UserData.grdUnst=grdUnst;
    
else
    
    varargout{1}=isUnstIdx;
    varargout{2}=polesUnst;
    varargout{3}=grdUnst;

end







function buttonDownFcn(hObj,event,pole_arr,diag_sys,blksize,animGeom,animOpt,sysStr)

persistent hAxes_act;

if isempty(hAxes_act) || hAxes_act~=hObj
    % single click
    hAxes_act = hObj;
    pause(0.3);
    if hAxes_act==hObj
      hAxes_act = [];
    end
else
    % double click
    hAxes_act = [];
    
    %  find nearest (x,y) coordinate to mouse click
    pt = event.IntersectionPoint;       % The (x0,y0,z0) coordinate you just selected
    coordinates = [hObj.XData(:),hObj.YData(:)];     % matrix of your input coordinates
    dist = pdist2(pt(1:2),coordinates);      %distance between your selection and all points
    [~, minIdx] = min(dist);            % index of minimum distance to points
    
    % identify pole(s)
    pole_act = coordinates(minIdx,1)-1i*coordinates(minIdx,2); %the selected pole
    if imag(pole_act)>0
        % conjugate complex pole pair -> select NEGATIVE imaginary part (smaller idx)
        pole_act=conj(pole_act); 
    end
    i_pole=find(pole_arr==pole_act,1,'first');
    if isempty(i_pole)
        warning('pole not found.');
        return
    end
    [wn,zeta]=damp(pole_act);
   
    
    % get index of mode using blksize
    if i_pole<=blksize(1)
        i_mode=1;
    else
        i_mode=find(i_pole>cumsum(blksize),1,'last')+1;
    end

    % select pole output vectors
    c=diag_sys.c;
    b=diag_sys.b;
    if blksize(i_mode)==2
        % cojugate complex pole pair
        x_iArr=sum(blksize(1:i_mode-1))+(1:blksize(i_mode));
        if imag(pole_arr(x_iArr(1)))+imag(pole_arr(x_iArr(2)))>sqrt(eps)
            error('no conjugate complex pole pair.');
        end
        v=c(:,x_iArr(1))+1i*c(:,x_iArr(2));       
    elseif blksize(i_mode)==1
        % real-valued pole
        x_iArr=sum(blksize(1:i_mode));
        v=c(:,x_iArr);
    else
        if isfield(hObj.Parent.Parent.UserData,'hFigAnim') && ishandle(hObj.Parent.Parent.UserData.hFigAnim)
            clf(hObj.Parent.Parent.UserData.hFigAnim,'reset'); % delete figure if already given
        end
        error('blocksize > 2 not implemented.')
    end
    normC=norm(c(:,x_iArr));
    normB=norm(b(x_iArr,:));
    normCB=normB*normC;
    gainStr=['|C|*|B|=' num2str(normCB)];
    poleStr=['p#' num2str(x_iArr(1)) ' = ' num2str(pole_arr(x_iArr(1)),3) '  ( frequ. = ' num2str(wn/2/pi,3) ' Hz = ' num2str(wn,3) ' rad/s,  rel. damping = ' num2str(zeta,3) ' )'];
   
    
    % select pole(s) in plot and display mode info
    if isfield(hObj.Parent.UserData,'hMarkerSel') && ishandle(hObj.Parent.UserData.hMarkerSel)
        delete(hObj.Parent.UserData.hMarkerSel); % delete selector if already given
    end
    if imag(pole_act)~=0
        x_sel=[real(pole_act) real(pole_act)];
        y_sel=[-imag(pole_act) imag(pole_act)];
    else
        x_sel=real(pole_act);
        y_sel=0;
    end
    hObj.Parent.UserData.hMarkerSel=plot(x_sel,y_sel,'xk','MarkerSize',20);
    hObj.Parent.UserData.hMarkerSel.Annotation.LegendInformation.IconDisplayStyle = 'off';
    disp(['> [' sysStr '] ' poleStr ' with ' gainStr]);
    
    enableModeAnim=~isempty(animGeom);
    if enableModeAnim

        % animate modeshape (if data is given)
        if isfield(hObj.Parent.Parent.UserData,'hFigAnim') && ishandle(hObj.Parent.Parent.UserData.hFigAnim)
            clf(hObj.Parent.Parent.UserData.hFigAnim,'reset'); % delete figure if already given
        else
            hObj.Parent.Parent.UserData.hFigAnim=figure();
        end
        figure(hObj.Parent.Parent.UserData.hFigAnim)
        set(gcf,'Name',sysStr,'Numbertitle','off');
        title({sysStr ,['\rm ' poleStr],[' with ' gainStr]});
        if notempty(animOpt,'gif_file')
           animOpt.gif_file=[animOpt.gif_file '_pole#' num2str(i_pole) '.gif'];
        end
        animatePoleVector(v,animGeom,animOpt);
    end
    
   
    
    
    
    
    
    
end


function  []=CloseRequestFcn(hObj,varargin)

if isfield(hObj.UserData,'hFigAnim') && ishandle(hObj.UserData.hFigAnim)
    delete(hObj.UserData.hFigAnim);
end

delete(hObj)
