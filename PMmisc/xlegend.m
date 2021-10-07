function []=xlegend(varargin)


if nargin==1 || iscellstr(varargin{1}) || ischar(varargin{1})
    if strcmp(get(gca,'Visible'),'off')
        axes_hArr=findobj(gcf,'Type','Axes','Visible','on');
        axes_hArr=axes_hArr(1); % or end?
    else
        axes_hArr=gca;
    end
    param=varargin;
elseif all(strcmp(get(varargin{1},'type'),'axes'))
    axes_hArr=varargin{1};
    param=varargin(2:end);
elseif all(strcmp(get(varargin{1},'type'),'figure'))
    hFig_arr=varargin{1};
    axes_hArr=[];
    for hFig_act=hFig_arr(:)'
       hAx_act=findobj(hFig_act,'type','axes'); % ,'visible','on'
       axes_hArr(end+1:end+numel(hAx_act))=hAx_act;
    end
%     legend_hArr=findobj(hFig_act,'type','legend','visible','on');
%     laxes_hArr=arrayfun(@(x) get(x,'Axes'),legend_hArr,'un',false);
%     axes_hArr=unique([axes_hArr laxes_hArr{:}]);
    param=varargin(2:end);
else
   error('not implemented.');
end
   
for i_ax=1:numel(axes_hArr)
   legend(axes_hArr(i_ax),param{:}); 
end