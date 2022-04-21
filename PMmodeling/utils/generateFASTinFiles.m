% generate FAST input files
function [fstNewFileName,allNewFileNameArr]=generateFASTinFiles(FSTtmpFileName,FSTnewModelPath,FSTnewModelSuffix,varargin)

% fst template file 
[FSTtmpPath,FSTtmpName,FSTtmpExt]=fileparts(FSTtmpFileName);

% defaults
if ~exist('FSTnewModelPath','var')
    FSTnewModelPath=FSTtmpPath;
end
if ~exist('FSTnewModelSuffix','var')
    FSTnewModelSuffix='';
end
if numel(varargin)==0
    FSTparStruct=struct(); % just copy template file, don't overwrite any parameter
elseif numel(varargin)==1
    FSTparStruct=varargin{1};
elseif numel(varargin)==2
    FSTparStruct=parval2struct(varargin{1},varargin{2});  % maybe work with cell arrays instead of structs?!
else
    error('too many input arguments.')
end

% read fst file data
FSTnewFileData=FAST2Matlab(FSTtmpFileName);

% set parameters
allNewFileNameArr={};
pName_arr=fieldnames(FSTparStruct);
for ii=1:numel(pName_arr)
    
    pName=pName_arr{ii};
    pVal=FSTparStruct.(pName);
    if isstruct(pVal)

        % get sub-file
        [subNewFileData,subTmpFileName]=GetFASTPar_Subfile(FSTnewFileData, pName,FSTtmpPath);

        % new sub file name (relative path)
        [subTmpPath,subTmpName,subTmpExt]=fileparts(subTmpFileName); 
        subNewFileName_rel=fullfile(subTmpPath(length(FSTtmpPath)+1:end),[subTmpName FSTnewModelSuffix subTmpExt]); % relative to fst path

        % update sub file name in fst data
        FSTnewFileData=SetFASTPar(FSTnewFileData,pName,['"' subNewFileName_rel '"']);

        % update data in sub file
        pSubName_arr=fieldnames(pVal);
        for jj=1:numel(pSubName_arr)
            pSubName=pSubName_arr{jj};
            if pSubName(end)=='_'
                % replace escape character with paranthesis (see also line 41  in readFASTinFiles.m)
                % example: transform 'BldPitch_1_' to 'BldPitch(1)'
                pSubName(find(pSubName=='_',2,'last'))='()';
            end
            subNewFileData=SetFASTPar(subNewFileData,pSubName,pVal.(pSubName_arr{jj}));
        end

        % save sub file
        subNewFileName=fullfile(FSTnewModelPath,subNewFileName_rel);
        Matlab2FAST(subNewFileData,subTmpFileName,subNewFileName,numel(subNewFileData.HdrLines));
        allNewFileNameArr{end+1}=subNewFileName;

    else
        
        % set parameter in top-level file
        FSTnewFileData=SetFASTPar(FSTnewFileData,pName,pVal);
        
    end

end

% save fst file
fstNewFileName=fullfile(FSTnewModelPath,[FSTtmpName FSTnewModelSuffix FSTtmpExt]);
Matlab2FAST(FSTnewFileData,FSTtmpFileName,fstNewFileName,2); % ASSUME 2 HEADER LINES!!!!
allNewFileNameArr{end+1}=fstNewFileName;


