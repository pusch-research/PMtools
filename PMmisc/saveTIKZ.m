% SAVETIKZ saves pdf of figure for latex
%   
%   SAVETIKZ() 
%   SAVETIKZ(..)
%   FILEPATH=SAVETIKZ(..) with options see below
%   
%   Example: saveTIKZ()
%       
%   See also SAVEPNG, SAVELATEXPDF

% REVISIONS:    2018-06-07 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=saveTIKZ(varargin)


% add toolbox (from: https://github.com/matlab2tikz/matlab2tikz )
if ~exist('matlab2tikz','file')
    TIKZpath='D:\WorkData\Software\Matlab\Toolbox Backup\matlab2tikz\src';
    if ~exist(TIKZpath,'dir')
       error('matlab2tickz toolbox not found.');
    else
        pathCell = regexp(path, pathsep, 'split');
        if ispc  % Windows is not case-sensitive
          onPath = any(strcmpi(TIKZpath, pathCell));
        else
          onPath = any(strcmp(TIKZpath, pathCell));
        end
        if ~onPath
           addpath(TIKZpath); 
        end
    end
end


% userdefined parameters
fileType='tikz';

hFig=varargin(find(ismember(varargin,'hFig'))+1);
if isempty(hFig)
    hFig=gcf;
else
    hFig=hFig{:};
    figure(hFig); % activate. assume single figure
end
dirName=cd;
if exist(fullfile(dirName,'img'),'dir')
    dirName=fullfile(dirName,'img');
end
fileName=get(hFig,'Name');
if notempty(hFig.UserData,'saveTIKZ')
    if notempty(hFig.UserData.saveTIKZ,'dirName')
       dirName=hFig.UserData.saveTIKZ.dirName;
    end
    if notempty(hFig.UserData.saveTIKZ,'fileName')
       fileName=hFig.UserData.saveTIKZ.fileName;
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

% define default color name based on filename
if ~notempty(hFig.UserData,'tikz') || ~notempty(hFig.UserData.tikz,'ColorName')
    hFig.UserData.tikz.ColorName=[strclean(strrep(fileName,'.tikz','')) 'Color'];
end
    


% check if figure is a response plot (e.g. Bode)
c_arr=get(gca,'Children');
if numel(c_arr)>0 && any(arrayfun(@(x) isa(x,'matlab.graphics.primitive.Group'),c_arr))
    hFig=copyFig(hFig); % copy figure without "groups" which cause problems in export
    copiedFig=true;
else
    copiedFig=false;
end
% make x/y/z labels black
for hAx=findall(hFig,'Type','axes')'
for axDir='XYZ'
    labelColor=get(get(hAx,[axDir 'label']),'color');
    if isequal(labelColor,[0.15 0.15 0.15])
        set(get(hAx,[axDir 'label']),'color',[0 0 0]); % set black
    end
end
end

% do export
matlab2tikz(filePath,'showInfo',false)


% post export figure processing
if copiedFig
    close(hFig); % close copied figure (original one remains)
else
    % hide legend (not exported anyways)
    hAx_arr=findall(hFig,'Type','Axes');
    for hAx=hAx_arr(:)'
       legend(hAx,'off'); 
    end
end


% display
if enableDisp
    disp(['> figure <a href="matlab: winopen(''' filePath ''')">' fileName '.' fileType '</a>' ' saved ..']);
end

% open file
if enableOpen
    %winopen(filePath);
end

% return
if nargout>0
    varargout{1}=filePath;
end

% special function: save also fig for TICKZ (dissertation only)
% [~,dirName]=fileparts(cd);
% if strcmp(dirName,'DissertationCode')
%     saveas(gcf,[filePath(1:end-length(fileType)) 'fig']);
%     if enableDisp
%         disp('> figure *.fig saved for TICKZ ..');
%     end
% end



