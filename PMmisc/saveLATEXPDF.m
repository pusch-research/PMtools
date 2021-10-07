% SAVELATEXPDF saves pdf of figure for latex
%   
%   SAVELATEXPDF() 
%   SAVELATEXPDF(..)
%   FILEPATH=SAVELATEXPDF(..) with options see below
%   
%   Example: saveLATEXPDF()
%       
%   See also SAVEPNG, XMF_EXPORT

% REVISIONS:    2017-02-16 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=saveLATEXPDF(varargin)






% userdefined parameters
xmfOpt={'fontsize', 12};
matlabfragOpt={};
fileType='pdf';

hFig=varargin(find(cellfun(@(x) isequal(x,'hFig'),varargin))+1);
if isempty(hFig)
    hFig=gcf;
else
    hFig=hFig{:};
    figure(hFig); % activate (assume its only 1 fig)
end
dirName=cd;
if exist(fullfile(dirName,'img'),'dir')
    dirName=fullfile(dirName,'img');
end
fileName=get(hFig,'Name');
if notempty(hFig.UserData,'saveLATEXPDF')
    if notempty(hFig.UserData.saveLATEXPDF,'dirName')
       dirName=hFig.UserData.saveLATEXPDF.dirName;
    end
    if notempty(hFig.UserData.saveLATEXPDF,'fileName')
       fileName=hFig.UserData.saveLATEXPDF.fileName;
    end
end
fileName=strclean(fileName);
if nargout<=0
    enableDisp=true;
    enableOpen=true;
else
    enableDisp=false;
    enableOpen=false;    
end

% overwrite userdefined parameters
for ii=1:2:numel(varargin) 
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end


% check colorbar label
hAx_arr=findall(gcf,'Type','axes');
for hAx=hAx_arr(:)'
    hCB=get(hAx,'colorbar');
    if ~isempty(hCB) 
        if ~isempty(hCB.Label.String) && ~strcmpi(hCB.Label.Interpreter,'latex') 
            %hCB.Label.Interpreter='latex';
            warning('colorbar label interpreter changed to ''latex''.');
        end
        if ~strcmpi(hCB.TickLabelInterpreter,'latex') 
            hCB.TickLabelInterpreter='latex';
            warning('colorbar ticklabel interpreter changed to ''latex''.');
        end
    end
end



% set xmf options
xmf_init('reset');
xmf_init(xmfOpt{:});

% preparation
xmf_prepare()
        
% save file dialog (if necessary)
filePath=fullfile(dirName,[fileName '.' fileType]);
if isempty(fileName) || exist(filePath,'file')
    [fileName,dirName] = uiputfile(['*.' fileType],'save figure' ,fullfile(dirName,fileName));
    if ~fileName
        return;
    end
    i_ext=find(fileName=='.',1,'last');
    if isempty(i_ext)
        i_ext=length(fileName);
    else
        i_ext=i_ext-1;
    end
    if ~strcmp(strclean(fileName(1:i_ext)),fileName(1:i_ext)) % elim extension
        error('filename must not contain special/blank characters etc.');
    end
    filePath=fullfile(dirName,fileName);
    if exist(filePath,'file')
        delete(filePath);
        if exist(filePath,'file')
            disp(['> export failed. ' filePath ' can not be overwritten..']);
            return
        end
    end
end

% add toolbox xmatlabfrag
%addpath('Matlab\Toolbox Backup\xmatlabfrag');


% do export
xmf_export(filePath,'output', fileType,matlabfragOpt{:})


% display
if enableDisp
    disp(['> figure <a href="matlab: winopen(''' filePath ''')">' fileName '</a>' ' saved ..']);
end

% open file
if enableOpen
    winopen(filePath);
end

% return
if nargout>0
    varargout{1}=filePath;
end

% special function: save also fig for TICKZ (dissertation only)
[~,dirName]=fileparts(cd);
if strcmp(dirName,'DissertationCode')
    saveas(gcf,[filePath(1:end-3) 'fig']);
    if enableDisp
        disp('> figure *.fig saved for TICKZ ..');
    end
end
