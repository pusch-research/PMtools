% ISEMPTYCELLSTORAGE 
%   
%   ISEMPTYCELLSTORAGE(CELLSTORAGE) check if cell storage is empty
%   
%   See also INITCELLSTORAGE,SAVECELL,LOADCELL

% REVISIONS:    2015-10-09 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function b=isemptyCellStorage(cellStorage)

if iscell(cellStorage)
    b=isempty(cellStorage);
elseif ischar(cellStorage)
    b=all(cell2mat(xgetfield(dir(cellStorage),'isdir')));
elseif isstruct(cellStorage)
    if exist(getPath(cellStorage),'dir')
        b=all(cell2mat(xgetfield(dir(getPath(cellStorage)),'isdir')));
    else
        b=true;
    end
else
    error('unkown cellStorage.');
end
