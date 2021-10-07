% LOADCELL load cell stored in a single file
%   
%   CELLDATA=LOADARR(CELLSTORAGE)
%   CELLDATA=LOADARR(CELLSTORAGE,IDX)
%   CELLDATA=LOADARR(CELLSTORAGE,IDX,OPT)
%   CELLDATA=LOADARR(CELLSTORAGE,IDX,OPT,FIELDNAME_ARR)
%   loads elements from CELLSTORAGE into cell array CELLDATA.
%   If IDX is not given or '!', all elements will be loaded.
%   OPT may be '-struct' if this option has been enabled during saving.
%   FIELDNAME_ARR adresses the selected fields to be loaded if CELLDATA is 
%   a cell array of struct.
%       
%   See also INITCELLSTORAGE,SAVECELL,ISEMPTYCELL,NUMELCELLSTORAGE

% REVISIONS:    2014-09-16 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function cellData=loadCell(cellStorage,idx,opt,fieldName_arr)

if nargin<4
    fieldName_arr={};
else
    if ~iscell(fieldName_arr), fieldName_arr={fieldName_arr}; end
end
if nargin<3
    opt={};
elseif ~iscell(opt)
    opt={opt};
end

structSave=ismember('-struct',opt); % loaded data is saved using '-struct' option
hasSelection=~isempty(fieldName_arr); % specific fields of loaded data needed
returnAllIdx=~exist('idx','var') || strcmp(idx,'!'); % return all elements

if ~iscell(cellStorage)
    %----------------------------------------------------------------------
    % from file
    %----------------------------------------------------------------------
    
    % get selected fields if stored in storage.index (faster)
    isIndexField_arr=false; % no fields available in storage.index
    if isstruct(cellStorage)
        if hasSelection && isfield(cellStorage,'index')
            isIndexField_arr=ismember(fieldName_arr,fieldnames(cellStorage.index));
            indexCellData=xstruct2cell(cellStorage.index,fieldName_arr(isIndexField_arr));
            % fast return
            if all(isIndexField_arr)
                if returnAllIdx 
                    cellData=indexCellData;
                else
                    cellData=indexCellData(idx);
                end
                return
            end
        end
    end
    
    % idx
    if returnAllIdx
        idx=1:numelCellStorage(cellStorage);
    end
    
    % init
    if any(isIndexField_arr)
        cellData=indexCellData(idx);
    else
        cellData=cell(size(idx));
    end
    
    % load
    storagePath=getPath(cellStorage);
    for ii=numel(idx):-1:1
        filename_act=fullfile(storagePath,['{' num2str(idx(ii)) '}.mat']);
        if structSave && hasSelection
            if any(isIndexField_arr)
                cellData{ii}=combine_struct(cellData{ii},load(filename_act,fieldName_arr{~isIndexField_arr})); 
            else
                cellData{ii}=load(filename_act,fieldName_arr{:});
            end
        else
            if structSave
                tmpData=load(filename_act);
            else
                tmpData=getfield(load(filename_act,'data'),'data');
            end
            
            if hasSelection
                for fieldName_act=fieldName_arr(~isIndexField_arr)'
                    cellData{ii}.(fieldName_act{:})=tmpData.(fieldName_act{:});
                end
            else
                cellData{ii}=tmpData;
            end
        end
    end
else
    %----------------------------------------------------------------------
    % from cell
    %----------------------------------------------------------------------
    if returnAllIdx
        tmpData_arr=cellStorage;
    else
        tmpData_arr=cellStorage(idx);
    end
    
    if hasSelection
        for ii=numel(tmpData_arr):-1:1
            for fieldName_act=fieldName_arr(:)'
                cellData{ii}.(fieldName_act{:})=tmpData_arr{ii}.(fieldName_act{:});
            end
        end
    else
        cellData=tmpData_arr;
    end
end
