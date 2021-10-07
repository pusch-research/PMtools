
function varargout=multiplot(x,y,yName,lineName,xName,varargin)

%% read input
p=inputParser;
addParamValue(p,'numColumn',[],@(x) x>0); % number of columns
addParamValue(p,'figName','multiPlot',@(x) ischar(x)); % name of figure
addParamValue(p,'figLabel',''); % figure label
addParamValue(p,'legendPlotIdx',0,@(x) all(x>=0)); % indices of plots where legend should be displayed
addParamValue(p,'lineSpec',{},@(x) iscell(x) || ischar(x) || isempty(x)); % line specifications for plots 
addParamValue(p,'mode','auto',@(x) ismember(x,{'auto','cellIsLine','cellIsPlot'})); % mode how data is plotted
addParamValue(p,'plotName',[]);
parse(p,varargin{:});
n_col=p.Results.numColumn;
figName=p.Results.figName;
figLabel=p.Results.figLabel;
legendPlot_iArr=p.Results.legendPlotIdx;
mode=p.Results.mode;
plotName=p.Results.plotName;
lineSpec=p.Results.lineSpec;
if ~exist('yName','var'), yName={}; end
if ~exist('lineName','var'), lineName={}; end
if ~exist('xName','var'), xName={}; end
if ~iscell(yName), yName={yName}; end
if ~iscell(lineName), lineName={lineName}; end

% make x and y a cell array
if ~iscell(y)
    if isvector(y), y={y(:)}; % y is a [n_time] vector
    else % y is a [n_time x n_plot x n_line] matrix
        y=arrayfun(@(i_plot) reshape(y(:,i_plot,:),size(y,1),[]),1:size(y,2),'un',false);
        if strcmp(mode,'auto'), mode='cellIsPlot'; end
    end 
end
if ~iscell(x)
   if isvector(x), x={x(:)}; % x is a [n_time] vector
   else x=arrayfun(@(i_x) x(:,i_x),1:size(x,2),'un',false); end % x is a [n_time x n_plot] matrix
end

% check mode
if strcmp(mode,'auto') && isequal(size(y)>1,[true true]) % y is already formatted as cell-arry [n_plot x n_line]
    n_line=size(y,2);
    n_plot=size(y,1);
elseif strcmp(mode,'auto') && (numel(yName)==numel(lineName) || isempty(yName) || isempty(lineName)) && (~isequal(size(y),[numel(yName) numel(lineName)]))
    error('multiplot:wrongInput','please define mode when number of lines and number of plots are equal or yName/lineName is not given.');
elseif strcmp(mode,'cellIsLine')
    n_line=numel(y);
    n_plot=size(y{1},2);
elseif strcmp(mode,'cellIsPlot')
    n_line=size(y{1},2);
    n_plot=numel(y);
else
    n_line=numel(lineName);
    n_plot=numel(yName);
    if numel(y)==n_line, mode='cellIsLine'; % define mode using y
    elseif numel(y)==n_plot, mode='cellIsPlot'; % define mode using y
    elseif ~isequal(size(y),[n_plot n_line])
        error('number of plots and number of lines do not match with y');
    end
end

% default yName [n_plot] cellstr vector
if isempty(yName), yName=arrayfun(@(ii) num2str(ii),1:n_plot,'un',false); end
% default plotName [n_plot] cellstr vector
if isempty(plotName), plotName=yName;
elseif ~iscell(plotName), plotName={}; end
% default lineName [n_line] cellstr vector
if isempty(lineName), lineName=arrayfun(@(ii) num2str(ii),1:n_line,'un',false); end
% default xName [n_plot] cellstr vector
if isempty(xName), xName='time'; end
if ~iscell(xName), xName={xName}; end
if numel(xName)==1, xName=repmat(xName,n_plot,1); end
% default number of columns (n_col)
if isempty(n_col)
    n_col=min(ceil(sqrt(3/2*n_plot)),n_plot); % default aspect ratio 3:2 (width:height)
end
n_col=min(n_col,n_plot);
n_row=ceil(n_plot/n_col);

% bring y in [n_plot x n_line] cell array
if ~isequal(size(y),[n_plot n_line])
    tmp=cell(n_plot,n_line);
    for i_plot=1:n_plot
    for i_line=1:n_line
        if strcmp(mode,'cellIsPlot')
            tmp{i_plot,i_line}=y{i_plot}(:,i_line);
        elseif strcmp(mode,'cellIsLine')
            tmp{i_plot,i_line}=y{i_line}(:,i_plot);
        end
    end
    end
    y=tmp;
end

% bring x in [n_plot x n_line] cell array
if ~isequal(size(x),[n_plot n_line])
    if numel(x)==1
        x=repmat(x,n_plot,n_line);
    elseif n_plot~=n_line
        if numel(x)==n_plot, x=repmat(x(:),1,n_line);
        elseif numel(x)==n_line, x=repmat(x(:)',n_plot,1);
        elseif size(x,2)==n_plot && size(x,1)==n_line, x=x'; 
        end
    elseif numel(x)==n_plot && numel(x)==n_line
        if strcmp(mode,'cellIsPlot'), x=repmat(x(:),1,n_line);
        elseif strcmp(mode,'cellIsLine'), x=repmat(x(:)',n_plot,1);
        else error('not implemented.');
        end
    else
        error('wrong size of x.');
    end
end

% default lineSpec
if isempty(lineSpec)
    lineSpec=cell(n_plot,n_line);
    %colors=distinguishable_colors(n_line);
    colors=linspecer(n_line,'sequential');
    colors=linspecer(n_line,'qualitative');
    for i_plot=1:n_plot
    for i_line=1:n_line
        lineSpec{i_plot,i_line}={'Color',colors(i_line,:)};
        if numel(y{i_plot,i_line})==1, lineSpec{i_plot,i_line}(end+1:end+2)={'Marker','x'};
        else lineSpec{i_plot,i_line}(end+1:end+2)={'Marker','none'}; end % 'none'        
    end
    end
elseif numel(lineSpec)==n_line
    lineSpec=repmat(lineSpec(:)',n_plot,1);
end

% check sizes
for ii=1:numel(y)
   if numel(y{ii})~=numel(x{ii}), 
       error('wrong size.'); end
end
if numel(yName)~=size(y,1) || numel(lineName)~=size(y,2) || numel(plotName)~=n_plot || ...
   numel(xName)~=n_plot || numel(yName)~=n_plot || numel(lineName)~=n_line
      error('wrong size.');
end
if any(legendPlot_iArr>n_plot), error('legendPlotIdx out of range.'); end
legendPlot_iArr(legendPlot_iArr==0)=n_plot; % overwrite zero entries with n_plot

%% plot
h=figure('Name',figName,'NumberTitle','off');
for i_plot=1:n_plot
    subplot(n_row,n_col,i_plot);
    xlabel(xName{i_plot},'Interpreter','none');
    ylabel(yName{i_plot},'Interpreter','none');
    title(plotName{i_plot},'Interpreter','none');
    grid on
    hold on
    for i_line=1:n_line
%         if numel(y{i_plot,i_line})==1, marker='x';
%         else marker='.'; end % 'none'
%        plot(x{i_plot,i_line},y{i_plot,i_line},'Color',colors(i_line,:),'Marker',marker);
        plot(x{i_plot,i_line},y{i_plot,i_line},lineSpec{i_plot,i_line}{:});
    end
    % set x limits
    xMin=min(cellfun(@(x_act) min(x_act),x(i_plot,:)));
    xMax=max(cellfun(@(x_act) max(x_act),x(i_plot,:)));
    if xMin~=xMax, xlim([xMin xMax]); end
end

% fig label
if ~isempty(figLabel), figlabel(figLabel); end

% legend
for i_plot=legendPlot_iArr
    subplot(n_row,n_col,i_plot);
    legend(lineName,'Interpreter','none','Location','SouthEast');
    %legend(regexprep(lineName(1:5),'max',''),'Interpreter','none');
end

% nargout
if nargout>0
    varargout{1}=h;
end