% GETPATH returns path string
%   
%   P=GETPATH(S) 
%   P=GETPATH(S,OPT) returns path string for a given S being a
%   a) string: P=S
%   b) struct: P=S.(F) with the fieldname F being determined from OPT
%      1) hostname: e.g. RMCPC0356 or RMCCS45 or RMCLAP0157
%      2) username: e.g. PUSC_MA
%      3) plattform: UNIX, WINDOWS or MAC
%      where only case insensitive word characters are considered (non-
%      exact matching). If no OPT is given, the fields of S are searched
%      recursively in the given order recursively.
%   
%   Example: getPath(struct('PUSC_MA',struct('win','C:\tmp')))
%       
%   See also STRCLEAN,STRUCT,FIELDNAMES

% REVISIONS:    2016-10-20 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function p=getPath(s,opt)

optName_arr={'hostname','username','plattform'};
n_opt=numel(optName_arr);


% check if already a string
if ischar(s)
    p=s;
    return
elseif ~isstruct(s)
    error('invalid type of input.');
end



% check options
if nargin<=1 || isempty(opt)
    i_opt=1;
elseif ischar(opt)
    i_opt=find(strncmpi(opt,optName_arr,length(opt)));
elseif isnumeric(opt)
    i_opt=opt;
else
    error('not implemented.');
end
if i_opt<0 || i_opt>n_opt
    error('path could not be found (i_opt out of range).'); 
end

% get name for option
switch optName_arr{i_opt}
    
    case 'hostname'
        fieldName=strclean(char(java.net.InetAddress.getLocalHost.getHostName));
        
    case 'username'
        fieldName=strclean(char(java.lang.System.getProperty('user.name')));
        
    case 'plattform'
        fieldName =     {  'windows' , 'unix',  'mac'};
        fieldName = fieldName{[ ispc      , isunix , ismac]};
        
    otherwise
        error('not implemented.');

end
   

% get fieldValue (=path) of fieldName
fieldName_arr=fieldnames(s);
i_fieldName=find(cellfun(@(x) strncmpi(x,fieldName,length(x)),fieldName_arr));
if isempty(i_fieldName)
    p=getPath(s,i_opt+1);
elseif numel(i_fieldName)==1
    p=getPath(s.(fieldName_arr{i_fieldName}),i_opt+1);
else
    error('various fields found. please check.');
end
    
