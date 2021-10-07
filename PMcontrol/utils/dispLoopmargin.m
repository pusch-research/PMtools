%% display loop margins function
function []=dispLoopmargin(lm,lmInfo,varargin)


% userdefined parameters
marginTypeArr={};
freqUnit='rad/s'; % {'Hz','rad/s'}
magUnit='dB'; % {'dB','abs'}
phaseUnit='deg'; % {'deg','rad'}
delayUnit='ms'; % {'s', 'ms'}
markWC=true; % {true, false}

% overwrite userdefined parameters (varargin)
for ii=1:2:numel(varargin) 
    if ~exist(varargin{ii},'var')
        warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
    end
    eval([varargin{ii} '=varargin{ii+1};']);
end



%% inits

% definitions
allMarginType_arr={'i','o','ai','ao','aio','io'};
allMarginTypeDesc_arr={...
    'single input perturbation'...
    'single output perturbation'...
    'all inputs perturbation'...
    'all outputs perturbation'...             
    'all inputs and outputs perturbation'...        
    'single input and output perturbation - not implemented'};

% input handling
if nargin<=1 || isempty(lmInfo)
    error('not implemented');
end
if isempty(marginTypeArr)
    marginTypeArr=allMarginType_arr;
end

% check stability
n_unst=sum(~lmInfo.isLoopStable_arr);
if n_unst>0
    disp(['The following loops are unstable (n=' num2str(n_unst) '):']);
    disp(lmInfo.loopName_arr(~lmInfo.isLoopStable_arr)');
    return 
end


% convert frequency units from rad->Hz
for i_col=1:numel(lm)
   lm(i_col).freqs=lm(i_col).freqs/(2*pi); 
end


n_sys=size(lm(1).values,1);


%% plot margins
for i_type=1:numel(marginTypeArr)
    
    % get margin type and margins
    marginType_act=marginTypeArr{i_type};
    margin_iArr=find(ismember({lm.type},marginType_act));
    n_col=numel(margin_iArr); % number of margins for that type
    if n_col==0
        %disp(['no values computed for marginType ''' marginType_act '''']);
        continue;
    end
    
    % define rows
    n_row=size(lm(margin_iArr(1)).values,2);
    switch marginType_act
        case 'i'
            rowName_arr=lmInfo.inName_arr;
            stableVal_arr=lmInfo.isLoopStableIn_arr;
        case 'o'
            rowName_arr=lmInfo.outName_arr;
            stableVal_arr=lmInfo.isLoopStableOut_arr;
        otherwise
            rowName_arr={};
            stableVal_arr=[];
    end
    
    % define columns
    variableName_arr={lm(margin_iArr).name};
    
    
    
    % generate strings of margin values
    marginValueStr_arr=cell(n_row,n_col);
    for i_col=1:n_col
        
        margin=lm(margin_iArr(i_col));

        % convert units
        if strcmp(margin.unit,'abs') && strcmp(magUnit,'dB')
            margin.values=mag2db(margin.values);
            margin.unit='dB';
        elseif strcmp(margin.unit,'s') && strcmp(delayUnit,'ms')
            margin.values=margin.values*1000;
            margin.unit='ms';
        elseif strcmp(margin.unit,'deg') && strcmp(phaseUnit,'rad')
            margin.values=margin.values*pi/180;
            margin.unit='rad';
        end
        if strcmp(freqUnit,'rad/s')
            margin.freqs=margin.freqs*2*pi;
        end

        % loop rows (inputs/outputs)
        valMin=inf;
        i_rowValMin=nan;
        for i_row=1:n_row
            if n_sys==1
                val=margin.values(:,i_row);
                valStr=[num2str(val,'%3.1f') margin.unit];
                freqStr=['@' num2str(margin.freqs(:,i_row),'%3.2f') freqUnit];
                loopStr='';
            else
                [val,i_loop]=min(margin.values(:,i_row));  % select minimum value (CAREFUL: if loop-at-a-time is unstable TODO!!!)
                valStr=[num2str(val,'%3.1f') margin.unit];
                freqStr=['@' num2str(margin.freqs(i_loop,i_row),'%3.2f') freqUnit];
                loopStr=['@' lmInfo.loopName_arr{i_loop}];
            end
            % stor smallest margin (to be marked)
            if val<valMin
                valMin=val;
                i_rowValMin=i_row;
            end
            marginValueStr_arr{i_row,i_col}=[valStr freqStr loopStr];
        end
        
        % mark row with smallest margin with a '*'
        if markWC && ~isempty(rowName_arr) && ~isnan(i_rowValMin) && ~strcmp(rowName_arr{i_rowValMin}(end),'*')
            rowName_arr{i_rowValMin}(end+1)='*';
        end
        
    end
    
    % stable
    if ~isempty(stableVal_arr)
        if any(isnan(stableVal_arr))
            stableVal_arr=nan(n_row,1); % stability has not been checked (only in 'ci' 'co')
        else
            stableVal_arr=all(stableVal_arr,1)'; % are all loops stable?
        end
        marginValueStr_arr=[marginValueStr_arr num2cell(stableVal_arr)]; 
        variableName_arr=[variableName_arr 'stable'];
    end
    
    disp(' ');
    % display margin type description
    disp(allMarginTypeDesc_arr{ismember(allMarginType_arr,marginType_act)});
    % display margin values
    disp(array2table(marginValueStr_arr,...
         'VariableNames',variableName_arr,...
         'RowNames',rowName_arr));
end

% new row
disp(' ');


























% %% system names
%     % system names for displaying
%     if isa(sys,'ss')
%         if n_sys==1 % single system
%            sysName_arr={sys.Name};
%         else % multiple systems
%             if isfield(sys.UserData,'name_arr') % look for a name_arr in UserData
%                sysName_arr=sys.UserData.name_arr;
%             elseif ~isempty(fieldnames(sys.SamplingGrid)) % look for SamplingGrid
%                 pName_arr=fieldnames(sys.SamplingGrid);
%                 n_p=numel(pName_arr);
%                 for i_sys=n_sys:-1:1
%                     pStr_arr=cell(1,n_p);
%                     for i_p=1:n_p
%                         pStr_arr{i_p}=[pName_arr{i_p} '=' num2str(sys.SamplingGrid.(pName_arr{i_p})(i_sys))];
%                     end
%                     sysName_arr{i_sys}=strjoin(pStr_arr,';');
%                 end
%             else % generic names
%                 sysName_arr=num2cellstr(1:n_sys);
%             end
%         end
%     end


