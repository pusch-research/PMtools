function [sys,inIdx,outIdx]=ioselect(sys,varargin)


% find indices
inIdx=xname2index(sys,varargin{1},2);
outIdx=xname2index(sys,varargin{2},1);


% backup userdata
userData=sys.UserData;

% select subsystem
s.type='()';
s.subs=[outIdx,inIdx,varargin(3:end)];
sys=subsref(sys,s);

% select io position
if notempty(userData,'InputPosition')
    userData.InputPosition=userData.InputPosition(:,inIdx);
end
if notempty(userData,'OutputPosition')
    userData.OutputPosition=userData.OutputPosition(:,outIdx);
end

% store userdata
sys.UserData=userData;


































%##########################################################################
% OLD
%##########################################################################

% 
% if nargout>1
%     
% 
%     
%     % find input group name
%     inSel=varargin{2};
%     if isempty(inSel)
%         inGroupName={''};
%     elseif isnumeric(inSel)
%         inGroupName=sys.InputName(inSel); % get names of selected io
%     elseif ischar(inSel)
%         if inSel(end)=='_'
%             inSel=inSel(1:end-1); % delete group unifyer ('_' at the end, see createLabel.m')
%         end
%         inGroupName={inSel}; % get group name of selected io (convert char to 1x cellstr)
%     else
%         inGroupName={''};
%     end
%     if numel(inGroupName)~=1
%         inGroupName=unique(regexprep(inGroupName,'\(\d+\)\.|\d+|\(\d+\)',''));% find unique expression for inputs (group)
%     end
%     if numel(inGroupName)~=1
%         inGroupName='';  % no group name found
%     else
%         inGroupName=inGroupName{:}; % convert 1x cellstr to char
%     end
%     if length(inGroupName)>15
%         inGroupName=[inGroupName(1:15) '..']; % make group name short
%     end
%     
%     % find output group name
%     outSel=varargin{2};
%     if isempty(outSel)
%         outGroupName={''};
%     elseif isnumeric(outSel)
%         outGroupName=sys.OutputName(outSel); % get names of selected io
%     elseif ischar(outSel)
%         if outSel(end)=='_'
%             outSel=outSel(1:end-1); % delete group unifyer ('_' at the end, see createLabel.m')
%         end
%         outGroupName={outSel}; % get group name of selected io (convert char to 1x cellstr)
%     else
%         outGroupName={''};
%     end
%     if numel(outGroupName)~=1
%         outGroupName=unique(regexprep(outGroupName,'\(\d+\)\.|\d+|\(\d+\)',''));% find unique expression for outputs (group)
%     end
%     if numel(outGroupName)~=1
%         outGroupName='';  % no group name found
%     else
%         outGroupName=outGroupName{:}; % convert 1x cellstr to char
%     end
%     if length(outGroupName)>15
%         outGroupName=[outGroupName(1:15) '..']; % make group name short
%     end
%     
%     
%     % save info
%     info.in_iArr=inIdx; 
%     info.out_iArr=outIdx;
%     info.inGroupName=inGroupName;
%     info.outGroupName=outGroupName;
%   
% end












% 
% 
% 
% 
% if ischar(varargin{1})
%     ioType=varargin{1};
%     ioSel=varargin{2};
% else
%     
%     
% end
%     
% 
% 
% 
% 
% 
% 
% 
% if ischar(ioType)
%     if strcmpi(ioType(1:2),'in')
%         ioType=2;
%     elseif strcmpi(ioType(1:2),'out')
%         ioType=1;
%     else
%         error('wrong ioType.');
%     end
% end
% 
% 
% % return indices
% sel_iArr=xname2index(sys,ioSel,ioType); 
% varargout{1}=sel_iArr;
% 
% 
% % return group name
% if nargout>1
% 
%     % get io names
%     if isnumeric(ioSel)
%         % get names of selected io
%         if ioType==1
%             inGroupName=sys.OutputName(ioSel); 
%         elseif ioType==2
%             inGroupName=sys.InputName(ioSel);
%         end
%     elseif ischar(ioSel)
%         if ioSel(end)=='_'
%             ioSel=ioSel(1:end-1); % delete group unifyer ('_' at the end, see createLabel.m')
%         end
%         inGroupName={ioSel}; % get group name of selected io (convert char to 1x cellstr)
%     else
%         inGroupName={''};
%     end
%     
%     % get group name
%     if numel(inGroupName)~=1
%         inGroupName=unique(regexprep(inGroupName,'\(\d+\)\.|\d+|\(\d+\)',''));% find unique expression for inputs (group)
%     end
%     if numel(inGroupName)~=1
%         inGroupName='';  % no group name found
%     else
%         inGroupName=inGroupName{:}; % convert 1x cellstr to char
%     end
%     
%     % make group name short
%     if length(inGroupName)>15
%         inGroupName=[inGroupName(1:15) '..']; 
%     end
%     
%     varargout{2}=inGroupName;
% end
% 
% 
% % return sys
% if nargout>2
%     if ioType==1
%        sel_sys=sys(sel_iArr,:); % select outputs 
%     elseif ioType==2
%        sel_sys=sys(:,sel_iArr); % select inputs
%        
%        
%     end
%     
%     
%     varargout{3}=sel_sys;
%     
%     % userdata selection
%         % positions (if available)
%     if notempty(sys.UserData,'InputPosition')
%         inPos=sys.UserData.InputPosition;
%         sys.UserData.InputPosition=[];
%         for i_in=n_in:-1:1
%             sys.UserData.InputPosition(:,i_in)=mean(inPos(:,Ti(:,i_in)~=0),2);
%         end
%     end    
%     
%     
%     
% end