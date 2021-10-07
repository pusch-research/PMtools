function varargout=copyFig(hFigOrig,n_dist,cutOffTolRel)

if nargin==0
    hFigOrig=gcf;
end
if nargin<=1
    n_dist=1;
end
if nargin<=2
    cutOffTolRel=0.1; % percentage of X/Y/Z data range outside of plot to be cut off
end


hAx_arr=findall(hFigOrig,'type','axes');
hFigNew=figure('Name',get(hFigOrig,'Name'),...
               'NumberTitle',get(hFigOrig,'NumberTitle'),...
               'Position',get(hFigOrig,'Position'));
for ii=1:numel(hAx_arr)
    if strcmp(hAx_arr(ii).Visible,'on')
        hAx_act=copyobj(hAx_arr(ii),hFigNew);
        
        % hacks for bode plot
        hAx_act.YTickMode='manual'; % bode grid stays as is
        hAx_act.YColor=[0 0 0];
        hAx_act.XColor=[0 0 0];
        hAx_act.XLabel.Color=[0 0 0];
        hAx_act.YLabel.Color=[0 0 0];
        hAx_act.Title.Color=[0 0 0];
        
        chil_arr=hAx_act.Children;
        for jj=1:numel(chil_arr)
            % delete existing children
            delete(chil_arr(jj)); 
        end
        hLine_arr=findall(hAx_arr(ii),'Type','line','Visible','on');
        for jj=numel(hLine_arr):-1:1
            if numel(hLine_arr(jj).XData)>0
                % copy lines
                hLine_act=copyobj(hLine_arr(jj),hAx_act);
                %numel(hLine_act.XData)
                if n_dist>1
                    % select a reduced number of data points
                    hLine_act.XData=hLine_act.XData(1:n_dist:end);
                    hLine_act.YData=hLine_act.YData(1:n_dist:end);
                    hLine_act.ZData=hLine_act.ZData(1:n_dist:end);
                end
                if ~isnan(cutOffTolRel)
                    % cut off data points outside of visible area
                    xTol=range(hLine_act.Parent.XLim)*cutOffTolRel;
                    yTol=range(hLine_act.Parent.YLim)*cutOffTolRel;
                    zTol=range(hLine_act.Parent.ZLim)*cutOffTolRel;
                    del_iArr=hLine_act.XData>max(hLine_act.Parent.XLim)+xTol;
                    del_iArr=hLine_act.XData<min(hLine_act.Parent.XLim)-xTol | del_iArr; 
                    del_iArr=hLine_act.YData>max(hLine_act.Parent.YLim)+yTol | del_iArr;
                    del_iArr=hLine_act.YData<min(hLine_act.Parent.YLim)-yTol | del_iArr; 
                    if ~isempty(hLine_act.ZData)
                        del_iArr=hLine_act.ZData>max(hLine_act.Parent.ZLim)+zTol | del_iArr;
                        del_iArr=hLine_act.ZData<min(hLine_act.Parent.ZLim)-zTol | del_iArr; 
                        if ~all(del_iArr)
                            hLine_act.ZData(del_iArr)=[];
                        end
                    end
                    if all(del_iArr)
                        delete(hLine_act);
                    else
                        hLine_act.XData(del_iArr)=[];
                        hLine_act.YData(del_iArr)=[];
                    end
                end
            end
        end
    end
end

if nargout>0
    varargout{1}=hFigNew;
end