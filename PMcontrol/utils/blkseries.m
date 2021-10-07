% BLKSERIES Series connection of two input/output models with 
%   
%   M=BLKSERIES(SYS1,SYS2)
%   M=BLKSERIES(SYS1,SYS2,OUTPUTS1,INPUTS2)
%   connect input/output models, where the system with the corresponding 
%   indices (OUTPUTS1/INPUTS2) being empty needs to be quadratic/blkdiagonl.
%   From this system, all inputs/outputs are connected with the other one.
%   
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        |  M2  |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  |  M1  |
%                  |      |---> z1
%                  +------+
%       
%   See also SERIES

% REVISIONS:    2018-02-06 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function m=blkseries(sys1,sys2,outputs1,inputs2)



% input handling
if nargin<4
    inputs2=[];
end
if nargin<3
    outputs1=[];
end
n_yz1=size(sys1,1);
n_uv2=size(sys2,2);     


if isempty(outputs1) && isempty(inputs2) 
    
    m=series(sys1,sys2);
    
elseif isempty(outputs1) 
    
    % take all outputs from sys1 which is assumed to be quadratic/blkdiagonal
    if size(sys1,1)~=size(sys1,2)
        error('sys1 is not quadratic.');
    end
    
    % u is u2=sys1*u1 and v2 (n_z1=0)
    in_iArr=xname2index(sys2,inputs2,2);
    uv2_blk_iArr=1:n_uv2;
    uv2_blk_iArr(in_iArr)=[];
    uv2_blk_iArr=[in_iArr uv2_blk_iArr];
    [~,blk_uv2_iArr]=sort(uv2_blk_iArr);
    
    sys1_arr=blkdiag(sys1,eye(size(sys2,2)-numel(in_iArr)));
    m=sys2(:,uv2_blk_iArr)*sys1_arr;
    m=m(:,blk_uv2_iArr);
    m.InputName=sys2.InputName; % default: use input names from sys2
    
    hasInName_arr=~cellfun(@isempty,sys1.InputName);
    m.InputName(in_iArr(hasInName_arr))=sys1.InputName(hasInName_arr); % overwrite input names if given
    m.InputGroup=sys2.InputGroup; % conserve input group
    
elseif isempty(inputs2)
    
    % take all inputs from sys2 which is assumed to be quadratic/blkdiagonal
    if size(sys2,1)~=size(sys2,2)
        error('sys2 is not quadratic.');
    end
    
    % y is y2=sys2*y1 and z1 (n_v2=0)
    out_iArr=xname2index(sys1,outputs1,1);
    yz1_blk_iArr=1:n_yz1;
    yz1_blk_iArr(out_iArr)=[];
    yz1_blk_iArr=[out_iArr yz1_blk_iArr];
    [~,blk_yz1_iArr]=sort(yz1_blk_iArr);
    
    sys2_arr=blkdiag(sys2,eye(size(sys1,1)-numel(out_iArr)));
    m=sys2_arr*sys1(yz1_blk_iArr,:);
    m=m(blk_yz1_iArr,:);
    m.OutputName=sys1.OutputName;
    
    hasOutName_arr=~cellfun(@isempty,sys2.OutputName);
    m.OutputName(out_iArr(hasOutName_arr))=sys2.OutputName; % overwrite input names if given
    m.OutputGroup=sys1.OutputGroup; % conserve output group
    
else
    
    in_iArr=xname2index(sys2,inputs2,2);
    out_iArr=xname2index(sys1,outputs1,1);
    

    n_u2=numel(in_iArr);
    n_y1=numel(out_iArr);
    n_v2=n_uv2-n_u2;
    n_z1=n_yz1-n_y1;
    
    if n_v2==0
        % y is y2=sys2*y1 and z1 (n_v2=0)
        warning('inputs2 is ignored.');
        m=blkseries(sys1,sys2,out_iArr,[]);
    elseif n_z1==0
        % u is u2=sys1*u1 and v2 (n_z1=0)
        warning('outputs1 is ignored.');
        m=blkseries(sys1,sys2,[],in_iArr);
    else
        error('not implemented.');
    end
        
        
    
end
    
