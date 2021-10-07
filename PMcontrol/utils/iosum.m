% IOSUM sum up individual inputs/outputs of dynamic system
%   
%   

% REVISIONS:    2016-10-18 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=iosum(sys,type,selArr,newNameArr,scalingArr)
% sum up inputs/outputs

inName_arr=sys.InputName;
outName_arr=sys.OutputName;
userData=sys.UserData;

if strcmp(type,'in')

    % selected inputs
    if ~exist('selArr','var') || isempty(selArr)
        inArr={1:size(sys,2)}; % sum up inputs
    elseif ~iscell(selArr)
        inArr={selArr};
    else
        inArr=selArr;
    end
    inArr=cellfun(@(x) xname2index(sys,x,2),inArr,'un',false);
    n_in=numel(inArr);
    
    % scaling
    if nargin<=4 || isempty(scalingArr)
        scalingArr=cellfun(@(x) ones(1,numel(x)),inArr,'un',false);
    elseif ~iscell(scalingArr)
        scalingArr={scalingArr};
    end
    
    % get trafo matrix
    Ti=zeros(size(sys,2),n_in);
    for i_in=1:n_in
        Ti(inArr{i_in},i_in)=scalingArr{i_in}; 
    end
    sys=sys*Ti;

    % names
    if exist('newNameArr','var') && ~isempty(newNameArr)
        sys.InputName=newNameArr; 
    else
        allInName_arr=inName_arr;
        sys.InputName=cellfun(@(x) strjoin(allInName_arr(x),'+'),inArr,'un',false);
    end
    
    % positions (if available)
    if notempty(sys.UserData,'InputPosition')
        inPos=userData.InputPosition;
        userData.InputPosition=[];
        for i_in=n_in:-1:1
            userData.InputPosition(:,i_in)=mean(inPos(:,Ti(:,i_in)~=0),2);
        end
    end    
        
    
    
    
elseif strcmp(type,'out')
   
    % selected outputs
    if ~exist('selArr','var') || isempty(selArr)
        outArr={1:size(sys,2)}; % sum up outputs
    elseif ~iscell(selArr)
        outArr={selArr};
    else
        outArr=selArr;
    end
    outArr=cellfun(@(x) xname2index(sys,x,1),outArr,'un',false);
    n_out=numel(outArr);
    
    % scaling
    if nargin<=4 || isempty(scalingArr)
        scalingArr=cellfun(@(x) ones(1,numel(x)),outArr,'un',false);
    elseif ~iscell(scalingArr)
        scalingArr={scalingArr};
    end
    
    % get trafo matrix
    To=zeros(n_out,size(sys,1));
    for i_out=1:n_out
        To(i_out,outArr{i_out})=scalingArr{i_out}; 
    end
    sys=To*sys;

    % names
    if exist('newNameArr','var') && ~isempty(newNameArr)
        sys.OutputName=newNameArr; 
    else
        alloutName_arr=outName_arr;
        sys.OutputName=cellfun(@(x) strjoin(alloutName_arr(x),'+'),outArr,'un',false);
    end
    
    % positions (if available)
    if notempty(userData,'OutputPosition')
        outPos=userData.OutputPosition;
        userData.OutputPosition=[];
        for i_out=n_out:-1:1
            userData.OutputPosition(:,i_out)=mean(outPos(:,Ti(:,i_out)~=0),2);
        end
    end    
    
    
else
    
    error('not implemented.');
    
end

sys.UserData=userData;