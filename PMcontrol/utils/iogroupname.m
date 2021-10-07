function ioGroupName=iogroupname(sys,ioType,ioSel)


% ioType
if ischar(ioType)
    if strcmpi(ioType(1:2),'in')
        ioType=2;
    elseif strcmpi(ioType(1:3),'out')
        ioType=1;
    else
        error('wrong ioType.');
    end
end

% ioSel
if nargin<2 || strcmp(ioSel,':')
    ioSel=1:size(sys,ioType);
end


% get io names
if isnumeric(ioSel)
    % get names of selected io
    if ioType==1
        ioGroupName=sys.OutputName(ioSel); 
    elseif ioType==2
        ioGroupName=sys.InputName(ioSel);
    end
elseif ischar(ioSel)
    if ioSel(end)=='_'
        ioSel=ioSel(1:end-1); % delete group unifyer ('_' at the end, see createLabel.m')
    end
    ioGroupName={ioSel}; % get group name of selected io (convert char to 1x cellstr)
else
    ioGroupName={''};
end

% get group name
if numel(ioGroupName)~=1
    ioGroupName=unique(regexprep(ioGroupName,'\(\d+\)\.|\d+|\(\d+\)',''));% find unique expression for inputs (group)
end
if numel(ioGroupName)~=1
    ioGroupName='';  % no group name found
else
    ioGroupName=ioGroupName{:}; % convert 1x cellstr to char
end

% make group name short
if length(ioGroupName)>15
    ioGroupName=[ioGroupName(1:15) '..']; 
end
 