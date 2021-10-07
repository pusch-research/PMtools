% LOADCELLVAR fast loading of single variable(s) of cellStorage
%   
%   [VAL1,VAL2,..]=LOADCELLVAR(CELLSTORAGE,FIELDNAMEARR) 
%   [VAL1,VAL2,..]=LOADCELLVAR(CELLSTORAGE,FIELDNAMEARR,IDX,OPT)   
%   returns arrays VAL1,VAL2,.. corresponding to fieldnames in FIELDNAMEARR
%   with each array of the same length as IDX. If IDX is not given, all
%   cells are loaded. OPT may contain
%       '-struct'   cells have been saved on HDD using the '-struct' option
%       '-num'      return numerical array instead of cell array
%       
%   See also LOADCELL,SAVECELL,INITCELLSTORAGE

% REVISIONS:    2016-07-18 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=loadCellVar(cellStorage,fieldNameArr,idx,opt)


if ~iscell(fieldNameArr)
    fieldNameArr={fieldNameArr};
end
if nargin<=3
    opt={}; % {'-struct','-num'}
elseif ~iscell(opt)
    opt={opt};
end
structSave=ismember('-struct',opt); % loaded data has been saved using '-struct' option
returnAllIdx=~exist('idx','var') || strcmp(idx,'!'); % return all elements
returnNum=ismember('-num',opt); % return numeric arrays [myStruct.(name)]; otherwise cell array {myStruct.(name)}

% initialize
varargout=cell(1,numel(fieldNameArr));

if ~iscell(cellStorage)
    %----------------------------------------------------------------------
    % from file
    %----------------------------------------------------------------------
    
    % get selected fields if stored in storage.index (faster)
    isIndexField_arr=false(size(varargout)); % no fields available in storage.index
    if isstruct(cellStorage)
        if isfield(cellStorage,'index')
            isIndexField_arr=ismember(fieldNameArr,fieldnames(cellStorage.index));
            
            % save data
            for i_name=find(isIndexField_arr)
                if returnAllIdx
                    if returnNum
                        varargout{i_name}=[cellStorage.index.(fieldNameArr{i_name})];
                    else
                        varargout{i_name}={cellStorage.index.(fieldNameArr{i_name})};
                    end
                else
                    if returnNum
                        varargout{i_name}=[cellStorage.index(idx).(fieldNameArr{i_name})];
                    else
                        varargout{i_name}={cellStorage.index(idx).(fieldNameArr{i_name})};
                    end
                end
            end
            
            % fast return
            if all(isIndexField_arr)
                return
            end
        end
    end
    
    % idx
    if returnAllIdx
        idx=1:numelCellStorage(cellStorage);
    end
        
    % load remaining fields
    storagePath=getPath(cellStorage);
    for ii=numel(idx):-1:1
        filename_act=fullfile(storagePath,['{' num2str(idx(ii)) '}.mat']);
        if structSave
            data_act=load(filename_act,fieldNameArr{~isIndexField_arr});           
        else
            data_act=loadvar(filename_act,'data');
        end
        
        for  i_name=find(~isIndexField_arr)
            if returnNum
                varargout{i_name}(ii)=data_act.(fieldNameArr{i_name}); 
            else
                varargout{i_name}{ii}=data_act.(fieldNameArr{i_name});
            end
        end
    end
else
    %----------------------------------------------------------------------
    % from cell
    %----------------------------------------------------------------------
    if returnAllIdx
        idx=1:numel(cellStorage);
    end
    
    for i_name=numel(fieldNameArr):-1:1
        if returnNum
            for ii=numel(idx):-1:1
                varargout{i_name}(ii)=cellStorage{idx(ii)}.(fieldNameArr{i_name});
            end
        else
            for ii=numel(idx):-1:1
                varargout{i_name}{ii}=cellStorage{idx(ii)}.(fieldNameArr{i_name});
            end
        end
    end
end