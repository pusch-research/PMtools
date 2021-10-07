% STR2EDITOR inserts string in active file in editor
%
%   STR2EDITOR() adds default string (function Header) in active file
%   at beginning of file
%
%   STR2EDITOR(cellStr) adds CELLSTR in active file at current cursor position
%   
%   Example
%       add pre-formatted header to active m-file on top: str2editor(); 
%   
%   See also STR2NUM

% REVISIONS:    2014-03-07 first implementation
% 
% Contact       pusch.research@gmail.com
%
function []=str2editor(str)

% current m-file open in editor
FileObj = matlab.desktop.editor.getActive;
    
% switch input
if ~exist('str','var') || isempty(str)
    [~,funName,ext]=fileparts(FileObj.Filename);
    if ~strcmp(ext,'.m')
        error('str2editor:wrongFileActive','no m-file active');
    end
    cellStr = {
    ['% ' upper(funName) ' '];...
    '%   ';...
    ['%   ' upper(funName) '() '];...
    '%   ';...
    '%   Example:';...
    '%       ';...
    %'%   ';...
    '%   See also '
    '';...
    ['% REVISIONS:    ' datestr(now,'yyyy-mm-dd') ' first implementation (MP)'];...
    '% ';...
    '% Contact       pusch.research@gmail.com';...
    '%';...
    ''};
    idx=[1 1 1 1]; % add text at the very beginning
else
    idx=FileObj.Selection;
    if iscell(str)
        cellStr=str;
    elseif isnumeric(str)
        cellStr={num2str(str)};
    elseif ischar(str)
        cellStr={str};
    else
        error('str2editor:wrongInput','Input is not a string or number.'); 
    end
end

% add CellStr to currently open m-file
text    = matlab.desktop.editor.linesToText(cellStr);
FileObj.insertTextAtPositionInLine(text,idx(1),idx(4));
FileObj.save;