function varargout=hline(varargin)


if isnumeric(varargin{1}) && ~all(ishandle(varargin{1}))
   hAx_arr=gca;
   y_arr=varargin{1};
   opt_arr=varargin(2:end);
elseif all(strcmp(get(varargin{1},'type'),'axes'))
   hAx_arr=varargin{1};
   y_arr=varargin{2};
   opt_arr=varargin(3:end);
elseif all(strcmp(get(varargin{1},'type'),'figure'))
   hFig_arr=varargin{1};
   hAx_arr=[];
   for hFig_act=hFig_arr(:)'
       hAx_act=findall(hFig_act,'type','axes');
       hAx_arr(end+1:end+numel(hAx_act))=hAx_act;
   end
   y_arr=varargin{2};
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

%%
hold on;
for ii=numel(hAx_arr):-1:1
    if strcmp(get(hAx_arr(ii),'Visible'),'on')
        hold_act=ishold(hAx_arr(ii));
        xlimmode_act=get(hAx_arr(ii),'XLimMode');
        xlim_act=xlim(hAx_arr(ii));
        
        hold(hAx_arr(ii),'on')
        
        hLine_arr(ii,1:numel(y_arr))=plot(hAx_arr(ii),repmat(xlim_act',1,numel(y_arr)),[y_arr(:)'; y_arr(:)'],opt_arr{:});
        xlim(hAx_arr(ii),xlim_act);
        if ~hold_act
            hold(hAx_arr(ii),'off'); 
        end
        if ~strcmp(xlimmode_act,'manual')
            set(hAx_arr(ii),'XLimMOde',xlimmode_act);
        end
        if ~isempty(label_arr)
            error('not implemented.');
            %hText_act=text(hAx_act,x_arr(:),repmat(yLim_act(2)',n_vline,1),label_arr(:),'HorizontalAlignment','left','VerticalAlignment','top');
        end
        if ~isempty(color_arr)
            set(hLine_arr(ii,1:numel(y_arr)),{'Color'},color_arr);
            if ~isempty(label_arr)
                set(hText_act,{'Color'},color_arr);
            end
        end
    end
end

if nargout==1
    varargout{1}=hLine_arr;
end