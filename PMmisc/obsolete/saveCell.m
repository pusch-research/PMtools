% SAVEARR save elements of buildonse array
%   
%   SAVEARR(CELLSTORAGE,CELLDATA)
%   SAVEARR(CELLSTORAGE,CELLDATA,IDX)
%   SAVEARR(CELLSTORAGE,CELLDATA,IDX,OPT)
%   SAVEARR(CELLSTORAGE,CELLDATA,IDX,OPT,FIELDNAME_ARR)
%   save element(s) of cell array CELLDATA with index IDX in CELLSTORAGE 
%   which is created by INITCELLSTORAGE. If IDX is not given or '!', it is
%   set to 1:numel(CELLDATA).
%   OPT may include the saving options from function SAVE like
%   '-v7.3','-struct' or '-append'.
%   FIELDNAME_ARR adresses the selected fields to be saved if CELLDATA is 
%   a cell array of struct.
%       
%   See also INITCELLSTORAGE,LOADCELL,ISEMPTYCELL,NUMELCELLSTORAGE

% REVISIONS:    2014-09-16 first implementation (MP)
%               2016 TODO: parallel computing?
% 
% Contact       pusch.research@gmail.com
%
function cellStorage=saveCell(cellStorage,cellData,idx,opt,fieldName_arr)

if nargin<3 || strcmp(idx,'!')
    idx=1:numel(cellData);
end
if nargin<4
    opt={};
elseif ~iscell(opt)
    opt={opt};
end
if nargin<5
   fieldName_arr={}; 
else
    if ~iscell(fieldName_arr), fieldName_arr={fieldName_arr}; end
end

i_structSave=ismember(opt,'-struct');
structSave=any(i_structSave); % use the '-struct' option for saving (convert struct field to variables)
hasSelection=~isempty(fieldName_arr);



if numel(idx)~=numel(cellData)
    error('save:wrongInput','idx and cellData must be of same length.');
end


for i_data=1:numel(cellData)
    tmpData=cellData{i_data};
    if hasSelection
        for fieldName_act=fieldName_arr(:)'
           data.(fieldName_act{:})=tmpData.(fieldName_act{:}); 
        end
    else
        data=tmpData;
    end
    
    if iscell(cellStorage)
        cellStorage{idx(i_data)}=data;
    else
        if isstruct(cellStorage)
            storagePath=getPath(cellStorage); 
            % check if there is an index field for fast access
            if isfield(cellStorage,'index')
                warning('test function');
                indexFieldName_arr=fieldnames(cellStorage.index);
                for name_act=indexFieldName_arr
                    cellStorage.index.name_act{:}=data.name_act{:};
                end
            end
        elseif ischar(cellStorage)
            storagePath=cellStorage;
        else
            error('unkown cell storage type.');
        end

        if structSave
            save(fullfile(storagePath,['{' num2str(idx(i_data)) '}.mat']),'-struct','data',opt{~i_structSave});
        else
            save(fullfile(storagePath,['{' num2str(idx(i_data)) '}.mat']),'data',opt{~i_structSave});
        end
    end
end
    
    
    
