% NUMELCELLSTORAGE Number of array elements in CellStorage
%   
%   N=NUMELCELLSTORAGE(CELLSTORAGE) 

%       
%   See also INITCELLSTORAGE,SAVECELL,LOADCELL,ISEMPTYCELL

% REVISIONS:    2015-11-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function n=numelCellStorage(cellStorage)


if iscell(cellStorage)
    n=numel(cellStorage);
else
    if isfield(cellStorage,'index')
        n=numel(cellStorage.index);
    else
        n=1;
        while exist(fullfile(getPath(cellStorage),['{' num2str(n) '}.mat']),'file')
            n=n+1;
        end
        n=n-1;
    end
end