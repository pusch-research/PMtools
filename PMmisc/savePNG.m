% SAVEPNG saves PNG image of figure
%   
%   SAVEPNG()
%   SAVEPNG(..) 
%   FILEPATH=SAVEPNG(..) with options see below
%   
%   Example: savePNG()
%       
%   See also PRINT SAVELATEXPDF

% REVISIONS:    2017-02-16 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=savePNG(varargin)

% userdefined parameters
printOpt={'-r300'};
fileType='-dpng';
hFig=varargin(find(cellfun(@(x) isequal(x,'hFig'),varargin))+1);
overwriteFile=false;
if isempty(hFig)
    hFig=gcf;
else
    hFig=hFig{:};
end
dirName=cd;
if exist(fullfile(dirName,'img'),'dir')
    dirName=fullfile(dirName,'img');
end
fileName=get(hFig,'Name');
if notempty(hFig.UserData,'savePNG')
    if notempty(hFig.UserData.savePNG,'dirName')
       dirName=hFig.UserData.savePNG.dirName;
    end
    if notempty(hFig.UserData.savePNG,'fileName')
       fileName=hFig.UserData.savePNG.fileName;
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

% save file dialog (if no filename given)
filePath=fullfile(dirName,[fileName '.' fileType(3:end)]);
if isempty(fileName) || (exist(filePath,'file') && ~overwriteFile)
    [fileName,dirName] = uiputfile(['*.' fileType(3:end)],'save figure' ,fullfile(dirName,fileName));
    if ~fileName
        if nargout>0
            varargout{1}=[];
        end
        return; 
    end
    filePath=fullfile(dirName,fileName);
end


% save png
print(filePath,fileType,printOpt{:});


% display
if enableDisp
    disp(['> figure <a href="matlab: winopen(''' filePath ''')">' fileName '.' fileType(3:end) '</a>' ' saved ..']);
end

% open file
if enableOpen
    winopen(filePath);
end

% return
if nargout>0
    varargout{1}=filePath;
end