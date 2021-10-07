% PLOTPOLES plots poles of a state space model (array)
%   
%   PLOTPOLES(SYS) 
%   PLOTPOLES(SYS,'PropertyName',propertyvalue)
%   plots poles of a state space model (array). The rows of the array
%   are associated to different colors, the rows to different tints.
%   
%   Example: plotPoles(rss(3))
%       
%   See also PLOTBODE,PLOT(AE)MODES

% REVISIONS:    2017-10-27 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=plotPoles(sys,varargin)

% userdefined parameters
xlims=[-5 0.1]; % axis x limits
ylims=[-1 40]; % axis y limits
freqUnit='rad/s'; % {'Hz','rad/s'}
hFig=[]; % figure handle
fColor=[]; % function with (n_color) input returning [n_color 3] RGB color array
fTint=@tintColor; % function with (color_arr,n_tints) inputs returning [n_color*n_tint 3] RGB color array
color_arr=[]; % predefined color_arr {[]: generate using fColor/fTint,[n_color*n_tint 3] RGB color array}
colorName_arr={}; % rows from sys-arr (used for 1D also)
tintName_arr={}; % columns from sys-arr
markerSize=[]; % markersize {[]: auto, scalar: same marker size for all, array with same size as sys: individual marker sizes}
marker='x'; % marker {char: same marker size for all, char-array with same size as sys: individual marker sizes}
lineWidth=3; % lineWidth {char: same marker size for all, char-array with same size as sys: individual marker sizes}

% overwrite userdefined parameters (varargin)
for ii=1:2:numel(varargin) 
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end




%% prepare

% get/check size
[~,~,arr_size]=sssize(sys);
if numel(arr_size)>2
    error('not implemented.');
else
    n_color=arr_size(1);
    n_tint=arr_size(2);
end
if n_color==1 && n_tint>1
    sys=sys(:,:,:); % reshape 
    n_color=n_tint;
    n_tint=1;
end
n_line=n_color*n_tint;

% auto color/tint name
if isempty(colorName_arr) && n_color>1
    colorName_arr=num2cellstr(1:n_color);
end
if isempty(tintName_arr)
    tintName_arr=num2cellstr(1:n_tint);
end

% auto cmap
if isempty(fColor)
    if sum(arr_size>1)==1
        fColor=@jet; % choose jet for 1D array
    else
        fColor=@lines; % choose lines for 2D arrays and single systems
    end
end

% auto color_arr
if isempty(color_arr)
    color_arr=fTint(fColor(n_color),n_tint);
elseif isequal(size(color_arr),[1 3])
    color_arr=repmat(color_arr,n_color*n_tint,1); % single color
elseif ~isequal(size(color_arr),[n_color*n_tint 3])
    error('wrong size of color array.');
end

% auto markerSize
if isempty(markerSize)
    markerSize=150*ones(n_color,1); % same marker size for each column (assumes that poles from one column are not too close)
    markerSize=markerSize+(n_tint:-1:1)*10; % increase marker size per column 
elseif numel(markerSize)==1
    markerSize=repmat(markerSize,n_color,n_tint);
elseif numel(markerSize)~=n_line
    error('wrong size markerSize.');
end
    
    
% auto marker
if numel(marker)==1
    marker=repmat(marker,n_color,n_tint);
elseif numel(marker)~=n_line
    error('wrong size marker.');
end

% auto lineWidth
if numel(lineWidth)==1
    lineWidth=repmat(lineWidth,n_color,n_tint);
elseif numel(lineWidth)~=n_line
    error('wrong size lineWidth.');
end


% auto xlim/ylim
if isempty(xlims) || isempty(ylims)
    pole_arr=eig(sys);
    if isempty(xlims)
        xlims=minmax(real(pole_arr(:)'));
    end
    if isempty(ylims)
        ylims=minmax(imag(pole_arr(:)'));
    end
end

%% prepare

% generate figure
if isempty(hFig) || ~ishandle(hFig)
    hFig=figure('NumberTitle','off','Name','poles');
end


% genrate axes
axes
xlim(xlims);
ylim(ylims);
sgrid on
set(findobj(gca,'Type','Line'),'Color',0.5*[1 1 1]);
set(findobj(gca,'Type','Text'),'Color',0.5*[1 1 1]);
xlabel(['imaginary axis / ' freqUnit]);
ylabel(['real axis / ' freqUnit]);
title('Poles');
hold on

    

%% do plotting

% loop through
i_line=1;
hScatter_arr=gobjects(n_color,n_tint);
for i_color=1:n_color
for i_tint=1:n_tint
    pole_arr=xeig(sys(:,:,i_color,i_tint)); % sort (so poles can be colored individually afterwards)
    hScatter_arr(i_color,i_tint)=scatter(real(pole_arr),imag(pole_arr),...
        markerSize(i_color,i_tint),color_arr(i_line,:),...
        'Marker',marker(i_color,i_tint),...
        'LineWidth',lineWidth(i_color,i_tint));
    i_line=i_line+1;
end
end

if ~isempty(colorName_arr)
    legend(hScatter_arr(:,1),colorName_arr,'Location','SouthWest','FontSize',12)
end

if n_tint>1   
    colormap(fTint([0 0 0],n_tint));
    if n_tint<5
        ctickLabel_arr=[tintName_arr(:) repmat({''},n_tint,1)]';
        colorbar('Ticks',linspace(0,1,n_tint*2+1),'TickLabels',[{''};ctickLabel_arr(:)],'TickLabelInterpreter','none');
    end
end


%% return
if nargout>0
    varargout{1}=hFig;
    varargout{2}=hScatter_arr;
end




