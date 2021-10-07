% ADDOUTPUTDERIV add derivative of output
%   
%   SYS=ADDOUTPUTDERIV(SYS,DERIVORDER)
%   SYS=ADDOUTPUTDERIV(A,B,C,D,DERIVORDER)
%   [Cadd,Dadd]=ADDOUTPUTDERIV(..)
%   add derivative of output up to order DERIVORDER. The new outputs are 
%   added by adding the rows Cadd and Dadd to C and D. If no output 
%   derivation is possible (D~=0) an error is thrown.
%   
%   Example: sys=addOutputDeriv(mkd(1,1,1),2)
%       
%   See also SS,IOADD

% REVISIONS:    2016-12-19 first implementation (MP)
% 
function varargout=addOutputDeriv(varargin)

% input handling
if nargin<=2
    sys=varargin{1};
    if hasdelay(sys)
        warning('system has delays which might not be handeled correctly.');
    end
    [A,B,C,D]=ssdata(sys);
    if nargin<2 
        derivOrder=1;
    else
        derivOrder=varargin{2};
    end
else
    [A,B,C,D]=deal(varargin{1:4});
    if nargin<5 
        derivOrder=1;
    else
        derivOrder=varargin{5};
    end
end


% check if feedthrough is zero
if any(D(:))
    error(['feedthrough must be zero in order to add derivative of output. '...
           'Maybe try to approximate derivative.']);
end

% addiational output
if derivOrder>0
    
    Dadd=C*B;
    Cadd=C*A;

    % add derivative output iteratively
    if derivOrder>1
        [C_,D_]=addOutputDeriv(A,B,Cadd,Dadd,derivOrder-1);
        Cadd=[Cadd;C_];
        Dadd=[Dadd;D_];
    end
else
    Dadd=[];
    Cadd=[];
end



% return
if nargout==1
    if nargin<=2
        % maintain sys (e.g. names,groups,units,userdata,etc.)
        varargout{1}=ioadd(sys,[],Cadd,Dadd); 
    else
        varargout{1}=ss(A,B,[C;Cadd],[D;Dadd]);
    end
else
    varargout={Cadd Dadd};
end
