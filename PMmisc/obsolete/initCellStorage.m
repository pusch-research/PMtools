% INITCELLARR initialise cell array storage
%   
%   CELLSTORAGE=INITCELLSTORAGE(CELLSTORAGE,DELETEEXISTING) 
%   initialize cell array storage of size [STORAGELENGTH 1]. If CELLSTORAGE is a
%   a) string:  the string is directory where cell elements are 
%               stored in single '{i}.mat' files. The directory is created  
%               if not existing. All contents/subfolders of the directory 
%               are deleted if DELETEEXISTING.
%   b) struct:  with at least two of the fields
%               - windows: path if running under windows (see 'string' above)
%               - unix: path if running under linux (see 'string' above)
%               - index: optional structure array containing indexing information
%                        for fast loading. Missing fields will be loaded
%                        from the given windows/unix path.
%   c) cell-array/empty: elements will be stored in this cell array. 
%               Array is set empty if DELETEXISTING.
%   Within this CELLSTORAGE cell elements can then be saved (SAVECELL) and 
%   loaded (LOADCELL).
%       
%   See also LOADCELL,SAVECELL,ISEMPTYCELL,NUMELCELLSTORAGE,GETPATH

% REVISIONS:    2014-12-15 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function cellStorage=initCellStorage(cellStorage,deleteExisting,storageLength,indexNameArr)

if nargin<4, indexNameArr={}; end
if nargin<3, storageLength=0; end
if nargin<2, deleteExisting=false; end


if iscell(cellStorage) % cell array given
    if deleteExisting
       cellStorage=cell(storageLength,1); 
    end
    
    if ~isempty(indexNameArr)
        warning('no index possible if cell is not stored on HDD.');
    end
else
    cellStoragePath=getPath(cellStorage);
    % delete existing
    if exist(cellStoragePath,'dir') && deleteExisting
        rmdir(cellStoragePath,'s');
        % disp(['> deleted directory ''' cellStorage ''''])
    end

    % create new directory
    [status,~]=mkdir(cellStoragePath);
    if ~status
        cellStorage=[];
    end
        
    % add index
    if numel(indexNameArr)>0
        % convert to path-struct (see getPath.m)
        if ischar(cellStorage)
            if isunix
                cellStorage=struct('unix',cellStorage);
            else
                cellStorage=struct('windows',cellStorage);
            end
        end
        % add idx
        n_cell=numelCellStorage(cellStorage);
        if n_cell>0
            % load index values from existing cells
            try
                % first try '-struct' option
                cellStorage.index=cell2mat(loadCell(cellStorage,'!','-struct',indexNameArr));
            catch
                % if not working try default
                cellStorage.index=cell2mat(loadCell(cellStorage,'!','',indexNameArr));
            end
        else
            % create empty index with predefined fields
            indexNameArr=[indexNameArr(:)';repmat({{}},1,length(indexNameArr))];
            cellStorage.index=struct(indexNameArr{:});
        end
    end
end