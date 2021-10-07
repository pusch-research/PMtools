function joinedStr = xstrjoin(str, delimiter)

if iscellstr(str)
    str(cellfun(@isempty,str))=[]; % delete empty cells
end

if nargin==1
    joinedStr=strjoin(str);
else
    joinedStr=strjoin(str,delimiter);
end