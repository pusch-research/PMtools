% generate FAST input files
function p=readFASTinFiles(inFileName,varargin)



% read fst file data
data=FAST2Matlab(inFileName,varargin{:});

% convert to struct
p=struct();
for ii=1:numel(data.Label)

    name_act=data.Label{ii};
    val_act=data.Val{ii};
    if ischar(val_act)
        % eliminate " and '
        val_act=strrep(val_act,'''','');
        val_act=strrep(val_act,'"','');
    end

    if (strcmp(name_act(max(1,end-3):end),'File') || strcmp(name_act(max(1,end-4):end-1),'File')) && ...
       ~any(strcmpi(val_act,{'none' 'false'})) && ischar(val_act) &&...
       strcmpi(val_act(end-3:end),'.dat')
            % parse .dat subfile if exists
            val_act=fullfile(fileparts(inFileName),val_act);
            if ~exist(val_act,'file')
                warning('readFASTinFile:noFile',[strrep(val_act,'\','\\') ' does not exist.']);
            else
                p.(name_act)=readFASTinFiles(val_act,varargin{:});
            end

%     elseif strcmp(name_act(end),')')
%         % parse array (assume single digit index!)
%         if ischar(val_act)
%             p.(name_act(1:end-3)){str2double(name_act(end-1))}=val_act;
%         else
%             p.(name_act(1:end-3))(str2double(name_act(end-1)))=val_act;
%         end
    else
        % regular entry
        name_act=strrep(strrep(name_act,'(','_'),')','_'); % repace parenthesis by underscore 
        p.(name_act)=val_act;
    end
end


