function data_arr=getGridDataFromBEM(model,WindSpeed,n_GenTq)

error('this failed because cq is not unique. It would be required to limit the TSR to get unique cq values.')

%% input handling

if ~exist('WindSpeed','var')
    WindSpeed=4:0.25:24;
elseif iscell(WindSpeed)
    WindSpeed=WindSpeed{1}:0.25:WindSpeed{2};
end

if ~exist('n_GenTq','var') || isempty(n_GenTq)
    % number of GenTq samples per velocity
    n_GenTq=20; 
end
n_wind=numel(WindSpeed);
n_BldPitch=numel(model.CpCtCq.BldPitch);
A=pi*model.R^2; % rotor swept area;
TSR=model.CpCtCq.TSR; % considered TSR values;
interpMethod='linear';



% elseif ~iscell(GenTq) || numel(GenTq)~=n_wind
%     % cell array with n_wind cells
%     error('not implemented')
% end

% % BldPitch 
% if ~exist('BldPitch','var') || isempty(BldPitch)
%     BldPitch=repmat({model.CpCtCq.BldPitch},n_wind,1); 
% elseif isscalar(BldPitch)
%     error('not implemented')
% %     BldPitch=repmat({linspace(min(model.CpCtCq.BldPitch),max(model.CpCtCq.BldPitch),BldPitch)},n_wind,1);
% elseif ~iscell(BldPitch) || numel(BldPitch)~=n_wind
%     % cell array with n_wind cells
%     error('not implemented')
% end


%% transform data
data_arr=cell(n_wind,1);


for i_wind=1:n_wind
    
    % init
    data_arr{i_wind}.BldPitch=model.CpCtCq.BldPitch;
    GenTq_tmp=0.5*model.rho*WindSpeed(i_wind)^2*A*model.CpCtCq.Cq(:); % all GenTq
    data_arr{i_wind}.GenTq=linspace(min(GenTq_tmp(GenTq_tmp~=0)),max(GenTq_tmp),n_GenTq);
    data_arr{i_wind}.isValid=nan(n_BldPitch,n_GenTq);
    data_arr{i_wind}.GenPwr=nan(n_BldPitch,n_GenTq);
    data_arr{i_wind}.RotThrust=nan(n_BldPitch,n_GenTq);
    data_arr{i_wind}.GenSpeed=nan(n_BldPitch,n_GenTq);
    
    % loop BldPitch
    for i_BldPitch=1:n_BldPitch
        GenTq_tmp=0.5*model.rho*WindSpeed(i_wind)^2*A*model.CpCtCq.Cq(:,i_BldPitch);
        TSR_act=interp1(GenTq_tmp,TSR,data_arr{i_wind}.GenTq,interpMethod);
        Ct_act=interp1(TSR,model.CpCtCq.Ct(:,i_BldPitch),TSR_act,interpMethod);
        Cp_act=interp1(TSR,model.CpCtCq.Cp(:,i_BldPitch),TSR_act,interpMethod);
        data_arr{i_wind}.RotThrust(i_BldPitch,:)=0.5*model.rho*WindSpeed(i_wind)^2*A*Ct_act;
        data_arr{i_wind}.GenPwr(i_BldPitch,:)=0.5*model.rho*WindSpeed(i_wind)^3*A*Cp_act;
        data_arr{i_wind}.GenSpeed(i_BldPitch,:)=TSR_act*WindSpeed(i_wind)/model.R*model.GBratio; % convert to rpm?
        data_arr{i_wind}.isValid(i_BldPitch,:)=~isnan(TSR_act);
    end

end





