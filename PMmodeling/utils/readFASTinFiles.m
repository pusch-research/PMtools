% generate FAST input files
function p=readFASTinFiles(inFileName,varargin)



% read fst file data
data=FAST2Matlab(inFileName,varargin{:});

% convert to struct - LABEL/VAL
p=struct();
for ii=1:numel(data.Label)

    name_act=strrep(strrep(data.Label{ii},'(','_'),')','_');    % repace parenthesis by underscore 
    val_act=data.Val{ii};
    if ischar(val_act)
        % eliminate " and '
        val_act=strrep(val_act,'''','');
        val_act=strrep(val_act,'"','');
    end

    if (strcmp(name_act(max(1,end-3):end),'File') || ...      % e.g. EDFile
        strcmp(name_act(max(1,end-4):end-1),'File') || ...    %
        strcmp(name_act(max(1,end-6):end-3),'File') ) && ...  % e.g. BldFile(1)
       ~any(strcmpi(val_act,{'none' 'false'})) && ischar(val_act) &&...
       strcmpi(val_act(max(end-3,1):end),'.dat')
            % parse .dat subfile if exists
            val_act=fullfile(fileparts(inFileName),val_act);
            if ~exist(val_act,'file')
                warning('readFASTinFile:noFile',[strrep(val_act,'\','\\') ' does not exist.']);
            elseif strcmp(name_act,'SubFile')
                warning('readFASTinFile:notSupported','Parsing SubDyn files is not supported.');
            elseif strcmp(name_act,'DLL_InFile')
                warning('readFASTinFile:notSupported','Parsing DLL_InFile is not supported.'); % e.g. ROSCO
            elseif strcmp(name_act,'HydroFile')
                warning('readFASTinFile:notSupported','Parsing HydroDyn files is not supported.'); 
            elseif strcmp(name_act,'MooringFile')
                warning('readFASTinFile:notSupported','Parsing MooreDyn files is not supported.'); 
            else
                p.(name_act)=readFASTinFiles(val_act,varargin{:});
            end
    else
        % regular entry
        p.(name_act)=val_act;
    end
end

% copy additional porperties (like tables, outlist, etc.)
% TODO: add identifier so its clear that this is and additonal property (for writing FST files)
name_arr=fieldnames(data);
for name_act=setdiff(name_arr,{'HdrLines' 'Label' 'Val'})'
    if isfield(data.(name_act{:}),'Table')
        % convert columns of table to sturct fields (and ignore comments)
        headerName_arr=data.(name_act{:}).Headers;
        for ii=1:numel(headerName_arr)
            p.(name_act{:}).(headerName_arr{ii})=data.(name_act{:}).Table(:,ii);
        end
    else
        % additional property is not a table
        p.(name_act{:})=data.(name_act{:});
    end
end

