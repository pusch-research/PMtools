function string = implode(glue,pieces)
% IMPLODE Joins strings in a cell array using a glue string
%
%   IMPLODE(GLUE,PIECES) treats each cell in the cell array PIECES as a
%   string and joins these strings by the GLUE character sequence. You can
%   also interchange the two arguments.
%
%   IMPLODE(PIECES) uses an empty GLUE string.
%
%   This function mimics the behaviour of the PHP function with the same
%   name.
%
%   See also: EXPLODE, STRCAT

% Check inputs
if nargin <= 1
    pieces = glue;
    glue = '';
end

% Check for inversed call
if nargin == 2 && iscell(glue)
    tmp = glue;
    glue = pieces;
    pieces = tmp;
    clear tmp
end

% Check for string only input
if ~iscell(pieces)
    string = pieces;
    
% Treat cell arrays
else
    % Transpose, if isvector
    if isvector(pieces)
        pieces = {pieces{:}};
    end
    
    % Account for matrix input
    if numel(pieces) > 0
        string = pieces(:,1);
        for i=2:size(pieces,2)
            string = strcat(string, {glue}, pieces(:,i)); %#ok<AGROW>
        end
    else
        string = '';
    end
    
    % If return is one element, do it as string
    if numel(string) == 1
        string = string{1};
    end
end
