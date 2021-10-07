function varargout=vline(varargin)


%% get inputs
if isnumeric(varargin{1}) && ~all(ishandle(varargin{1})) % no handle
   hAx_arr=gca;
   x_arr=varargin{1};
   opt_arr=varargin(2:end);
elseif all(strcmp(get(varargin{1},'type'),'axes')) % axis handle
   hAx_arr=varargin{1};
   x_arr=varargin{2};
   opt_arr=varargin(3:end);
elseif all(strcmp(get(varargin{1},'type'),'figure')) % figure handle
   hFig_arr=varargin{1};
   hAx_arr=gobjects(0);
   for hFig_act=hFig_arr(:)'
       hAx_act=findobj(hFig_act,'type','axes'); % findobj instead of findall (for bode diagrams)
       hAx_arr(end+1:end+numel(hAx_act))=hAx_act;
   end
   x_arr=varargin{2};
   opt_arr=varargin(3:end);
else
   error('not implemented.');
end


%% userdefined parameters
color_arr=[];
label_arr=[];

% overwrite userdefined parameters (varargin) and delete them from varargin to pass on varargin 
ii=1;
while ii<numel(opt_arr)
    if ischar(opt_arr{ii}) && exist(opt_arr{ii},'var')
        eval([opt_arr{ii} '=opt_arr{ii+1};']);
        opt_arr(ii:ii+1)=[];
    else
        ii=ii+1;
    end
end

% make cell
if ~isempty(color_arr) && ~iscell(color_arr)
   color_arr=num2cell(color_arr,2);
end


%% plot
n_ax=numel(hAx_arr);
n_vline=numel(x_arr);
hText_act=[];
isAxVisible=true(n_ax,1);
for ii=n_ax:-1:1
    
    hAx_act=hAx_arr(ii);
%     isAxVisible(ii)=strcmp(get(hAx_act,'Visible'),'on');
%     if isAxVisible(ii)
        
        hold_act=ishold(hAx_act);
        hold(hAx_act,'on')
        yLim_act=ylim(hAx_act);
        
        hLine_arr(ii,1:n_vline)=plot(hAx_act,[x_arr(:)'; x_arr(:)'],repmat(yLim_act',1,n_vline),opt_arr{:});
        
        if ~isempty(label_arr)
            hText_act=text(hAx_act,x_arr(:),repmat(yLim_act(2)',n_vline,1),label_arr(:),'HorizontalAlignment','left','VerticalAlignment','top');
        end
        if ~isempty(color_arr)
            set(hLine_arr(ii,1:n_vline),{'Color'},color_arr);
            set(hText_act,{'Color'},color_arr);
        end
        
        
        if ~hold_act
            hold(hAx_act,'off'); 
        end
        ylim(hAx_act,yLim_act);
%     end
end

hLine_arr(~isAxVisible,:)=[];

%% return
if nargout==1
    varargout{1}=hLine_arr;
end