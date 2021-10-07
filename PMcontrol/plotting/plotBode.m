% PLOTBODE plot bode for sys array
%   
%   PLOTBODE(SYS,...) 
%   variaton of color and tint
%   
%   Example:
%       
%   See also BODE

% REVISIONS:    2017-10-27 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=plotBode(sys,varargin)




% userdefined parameters
bodeOpt=getBodeOpt('FreqUnits','rad/s','MagUnits','abs');
w={};
hFig=[]; % figure handle
fColor=[]; % function with (n_color) input returning [n_color 3] RGB color array
fTint=@tintColor; % function with (color_arr,n_tints) inputs returning [n_color*n_tint 3] RGB color array
color_arr=[]; % predefined color_arr {[]: generate using fColor/fTint,[n_color*n_tint 3] RGB color array}
colorName_arr={}; % rows from sys-arr (used for 1D also)
tintName_arr={}; % columns from sys-arr
plotLegend_iArr=1; % plot# where legend should be plotted
plotColorBar_iArr=1; % plot# where colorbar should be plotted

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
n_line=n_color*n_tint;

% auto color/tint name
if isempty(colorName_arr) && n_color>1
    colorName_arr=num2cellstr(1:n_color);
end
if isempty(tintName_arr) && n_tint>1
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


%% prepare

% generate figure
if isempty(hFig) || ~ishandle(hFig)
    hFig=figure('NumberTitle','off','Name','bode');
end


   

%% do plotting

for i_color=1:n_color    
    for i_tint=1:n_tint
        bode(sys(:,:,i_color,i_tint),w,bodeOpt);
        hold on
    end
    
end

% set color
hLine_arr=getResponsePlotLine(n_line);
set(hLine_arr,{'Color'},num2cell(repmat(color_arr,size(hLine_arr,2),1),2))

% legend
if ~isempty(colorName_arr)
    for i_plot=plotLegend_iArr
        legend(hLine_arr(1:n_tint:end,i_plot),colorName_arr)
    end
end

% colorbar
if ~isempty(tintName_arr)
    for i_plot=plotColorBar_iArr
        axes(hLine_arr(1,i_plot).Parent.Parent); %#ok<LAXES>
        colormap(fTint([0 0 0],n_tint));
        if n_tint<5
            ctickLabel_arr=[tintName_arr(:) repmat({''},n_tint,1)]';
            colorbar('Ticks',linspace(0,1,n_tint*2+1),'TickLabels',[{''};ctickLabel_arr(:)],'TickLabelInterpreter','none');
        end
    end
end


%% return
if nargout>0
    varargout{1}=hFig;
end
