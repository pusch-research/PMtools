function a=xsubsref(a,varargin)


if isa(a,'ss')
    sizeSys=size(a);
    sizeSys=[sizeSys ones(1,max(0,4-length(sizeSys)))]; % add ones to at least have a vector with 4 elements
    
    y_iArr=xname2index(a,varargin{1},1);
    u_iArr=xname2index(a,varargin{2},2);
    
    if size(varargin)<=2
        varargin(3:length(sizeSys))={':'};
    end
    
    fieldName_arr=fieldnames(a.UserData);
    for ii=1:numel(fieldName_arr)
        name_act=fieldName_arr{ii};
        if strcmp(name_act,'y0')
            userData.y0=a.UserData.y0(y_iArr,varargin{3:end});
        elseif strcmp(name_act,'u0')
            userData.u0=a.UserData.u0(u_iArr,varargin{3:end});
        elseif strcmp(name_act,'x0')
            userData.x0=a.UserData.x0(:,varargin{3:end});
        elseif isequal(size(a.UserData.(name_act)),sizeSys(3:end))
            userData.(name_act)=a.UserData.(name_act)(varargin{3:end});
        else
            userData.(name_act)=a.UserData.(name_act);
        end
    end
    
    a=a(varargin{:});
    a.Userdata=userData;
else
    a=a(varargin{:});
end