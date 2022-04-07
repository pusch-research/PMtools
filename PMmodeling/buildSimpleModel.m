function model=buildSimpleModel(CpCtCq,RatedGenPwr,rho,R,GBratio,Jrot,WndSpeed)

% input handling
if isstruct(CpCtCq)
    c=CpCtCq;
else
    error('CpCtCq file parser not implemented.')
end

if ~exist("WndSpeed",'var')
    WndSpeed=0:0.25:25;
elseif iscell(WndSpeed)
    WndSpeed=WndSpeed{1}:0.25:WndSpeed{2};
end


%% compute values from cp surface

% Compute gradients of Cp surface for later calculations
[dCp_pitch_tbl, dCp_TSR_tbl] = gradient(c.Cp,c.BldPitch,c.RtTSR);
[dCt_pitch_tbl, dCt_TSR_tbl] = gradient(c.Ct,c.BldPitch,c.RtTSR);

% define interpolation function
fCp=@(BldPitch_deg,TSR)  interp2(c.BldPitch, c.RtTSR, c.Cp, BldPitch_deg, TSR,'spline');
fCt=@(BldPitch_deg,TSR)  interp2(c.BldPitch, c.RtTSR, c.Ct, beta_deg, TSR,'spline');


% find grid point with optimal Cp as an initial value
[i_tsrOpt, i_pitchOpt] = find(c.Cp == max(c.Cp, [], 'all'), 1); % note indices are reversed from 3d plotting functions like surf
BldPitch_opt_deg = c.BldPitch(i_pitchOpt);
TSR_opt = c.RtTSR(i_tsrOpt);


% find optimal cp using optimization
[x_opt,Cp_opt]=fminsearch(@(x) -fCp(x(1),x(2)),[BldPitch_opt_deg TSR_opt]);
Cp_opt=-Cp_opt;
BldPitch_opt_deg=x_opt(1);
TSR_opt=x_opt(2);

% get rated values
v_rated_mDs=(2*RatedGenPwr/(rho*R^2*pi*Cp_opt))^(1/3);
wr_rated_radDs=TSR_opt*v_rated_mDs/R;
wg_rated_radDs=wr_rated_radDs*GBratio;
tau_rated_Nm=RatedGenPwr/wg_rated_radDs;


%% generate data arrays

v_mDs_arr=[v_rated_mDs ceil(v_rated_mDs):0.25:25]'; 
% v_mDs_arr=[ceil(v_rated_mDs):0.25:25]'; 
TSR_arr=wr_rated_radDs.*R./v_mDs_arr;
TSR_upper_arr=wr_rated_radDs.*R./v_mDs_arr*1.2;
TSR_lower_arr=wr_rated_radDs.*R./v_mDs_arr/1.2;
Cp_arr = Cp_opt * (TSR_arr ./ TSR_opt).^3;
Cp_upper_arr = Cp_opt * (TSR_upper_arr ./ TSR_opt).^3;
Cp_lower_arr = Cp_opt * (TSR_lower_arr ./ TSR_opt).^3;
wr_radDs_arr=TSR_arr.*v_mDs_arr./R;

% compute analytical model at each op point
n_v=numel(v_mDs_arr);
BldPitch_deg_arr = zeros(n_v,1);
BldPitch_upper_deg_arr = zeros(n_v,1);
BldPitch_lower_deg_arr = zeros(n_v,1);
dCp_dbeta_arr = zeros(n_v,1);
dCp_dTSR_arr = zeros(n_v,1);
dCt_dbeta_arr = zeros(n_v,1);
dCt_dTSR_arr = zeros(n_v,1);
Ct_arr = zeros(n_v,1);

% above rated
for i_v = 1:n_v

    % compute blade pitch angle of maximum Cp at given TSR
    BldPitch_opt_act=fminsearch(@(x) -fCp(x,TSR_arr(i_v)),BldPitch_opt_deg);

    % find the UPPER blade pitch angle which matches the given Cp value
    BldPitch_deg_arr(i_v)=fminbnd(@(x) abs(fCp(x,TSR_arr(i_v))-Cp_arr(i_v)),BldPitch_opt_act,max(c.BldPitch)); 
    BldPitch_upper_deg_arr(i_v)=fminbnd(@(x) abs(fCp(x,TSR_upper_arr(i_v))-Cp_arr(i_v)),BldPitch_opt_act,max(c.BldPitch)); 
    BldPitch_lower_deg_arr(i_v)=fminbnd(@(x) abs(fCp(x,TSR_lower_arr(i_v))-Cp_arr(i_v)),BldPitch_opt_act,max(c.BldPitch)); 

    % compute gradients at current operation point
    dCp_dbeta_arr(i_v) = interp2(c.BldPitch, c.RtTSR, dCp_pitch_tbl, BldPitch_deg_arr(i_v), TSR_arr(i_v));
    dCp_dTSR_arr(i_v) = interp2(c.BldPitch, c.RtTSR, dCp_TSR_tbl, BldPitch_deg_arr(i_v), TSR_arr(i_v));
    dCt_dbeta_arr(i_v) = interp2(c.BldPitch, c.RtTSR, dCt_pitch_tbl, BldPitch_deg_arr(i_v), TSR_arr(i_v));
    dCt_dTSR_arr(i_v) = interp2(c.BldPitch, c.RtTSR, dCt_TSR_tbl, BldPitch_deg_arr(i_v), TSR_arr(i_v));

    % Ct value at current operation point
    Ct_arr(i_v) = interp2(c.BldPitch, c.RtTSR, c.Ct, BldPitch_deg_arr(i_v), TSR_arr(i_v));

end

% linearized system derivatives
dtau_dbeta      = 1 / 2 * rho * R^3 * pi .* v_mDs_arr.^2 ./ TSR_arr .* dCp_dbeta_arr ;
dtau_dlambda    = 1 / 2 * rho * R^3 * pi .* v_mDs_arr.^2 ./ TSR_arr.^2 .* (dCp_dTSR_arr.*TSR_arr - Cp_arr);
dlambda_dwg  = R ./ v_mDs_arr / GBratio;
dtau_domega     = dtau_dlambda .* dlambda_dwg;
dTSR_dv      = -TSR_arr./v_mDs_arr;
dtau_dv = (1 / 2 * rho * R^2*pi ./ wr_radDs_arr) .* (dCp_dTSR_arr .* dTSR_dv .* v_mDs_arr.^3 + Cp_arr* 3 .* v_mDs_arr.^2);

% % These are partial derivatives of thrust force
% Pi_beta         = 1/2 * rho * Ar * v_op.^2 .* dCt_dbeta;
% Pi_omega        = 1/2 * rho * Ar * R/Ng * v_op .* dCt_dTSR;
% Pi_wind         = 1/2 * rho * Ar * v_op.^2 .* dCt_dTSR .* dlambda_dv + rho * Ar * v_op .* Ct_op_arr;




%% LTI state space matrices
A = GBratio*dtau_domega/Jrot;             % system matrix
B_tau = -GBratio^2/Jrot;                  % input matrix for generator torque  
B_beta = GBratio*dtau_dbeta/Jrot;         % input matrix for blade pitch
B_v = dtau_dv/Jrot;               % input matrix for wind speed 




%% return
clear BldPitch_opt_act  % clear variables before saving them
model=ws2struct();

