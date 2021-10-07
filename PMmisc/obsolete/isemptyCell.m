% ISEMPTYCELL returns if cell is empty or file exists on harddrive
%   
%   B=ISEMPTYCELL(STORAGE,IDX) where B has the same number of elements than
%   IDX.
%       
%   See also LOADCELL,SAVECELL,ISEMPTYCELL,NUMELCELLSTORAGE,INITCELLSTORAGE

% REVISIONS:    2015-11-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function b=isemptyCell(cellStorage,idx)

if iscell(cellStorage)
    b=cellfun(@isempty,cellStorage(idx));
else
    for ii=numel(idx):-1:1
        cellPath_act=fullfile(getPath(cellStorage),['{' num2str(idx(ii)) '}.mat']);
        b(ii)=exist(cellPath_act,'file')==0;
    end
end
