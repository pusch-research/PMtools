function varargout=plotPZ3(sys,type,varargin)


% (overwriteable) default values
zAxis='in';
hFig=[];
cmap='auto';
inputGroup='ted_cmd';
addLines='auto';
x_lim=[];
y_lim=[];

for ii=1:2:numel(varargin) % overwrite userdefined parameters
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end



% figure
if isempty(hFig) || ~ishandle(hFig)
    hFig=figure('NumberTitle','off','Name','pzMap');
    if isequal(addLines,'auto')
        addLines=false;
    end
elseif isequal(addLines,'auto')
    addLines=true;
end

%% defaults
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


%% computation

[n_out,n_in]=size(sys);

% zeros
switch type
    case 'tzero'
        zero_arr=tzero(sys);
        n_zero=repmat(numel(zero_arr),n_out,n_in);
        zero_arr=repmat({zero_arr},n_out,n_in);
    case 'iozero'
        [~,zero_arr]=xiopzmap(sys,@sminreal);
        n_zero=cellfun(@numel,zero_arr);
    otherwise
        error('not implemented.')
end

%% plotting
switch zAxis
    case 'in'
        for i_out=1:n_out
            subplot(n_out,1,i_out);
            
            if sum(n_zero(i_out,:))==0
                continue;
            end
            
            zero_act=cell2mat(zero_arr(i_out,:)');
            x=real(zero_act);
            y=imag(zero_act);
            z=diag(repdiag(1:n_in,n_zero(i_out,:)));
            colormap(cmap(n_in));
            scatter3(x,y,z,28,z,'filled')
            
            
            view(2)

            if ~isempty(x_lim)
                xlim(x_lim);
            end
            if ~isempty(y_lim)
                ylim(y_lim);
            else
                ylim([0 max(ylim)])
            end

            xlabel(['real(' type ')']);
            ylabel(['imag(' type ')']);
            title([type 's ' inputGroup '->' sys.OutputName{i_out}],'interpreter','none')
            
            box on
            grid off
            hold on
            sgrid
            
        end
    otherwise
        error('not implemented.');
end





%% return
if nargout>0
    varargout{1}=hFig;
end









