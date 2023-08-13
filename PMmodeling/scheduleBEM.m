function [schedule,rtd]=scheduleBEM(model,cnstrName,cnstrVal,WindSpeed,varargin)
% NOTE: schedule.GenTq is in [Nm]

%% input handling

% varargin
if numel(varargin)>0
    fminconOpt=varargin{1};
else
    fminconOpt=[];
end
if numel(varargin)>1
    interpOpt=varargin{2};
    if ~iscell(interpOpt)
        interpOpt={interpOpt};
    end
else
    interpOpt={'makima',nan};
end

% wind speed
if ~exist('WindSpeed','var')
    WindSpeed=unique([4.1:0.2:18]);
elseif iscell(WindSpeed)
    WindSpeed=WindSpeed{1}:0.25:WindSpeed{2};
end

% constraint
if ~exist('cnstrName','var')
    cnstrName='';
end

%% compute optima

% re-assign for easier access
c=model.CpCtCq;
A=pi*model.R^2;


% define interpolation function
fCp=@(BldPitch,TSR)  interp2(c.BldPitch, c.TSR, c.Cp, BldPitch, TSR,interpOpt{:});
fCt=@(BldPitch,TSR)  interp2(c.BldPitch, c.TSR, c.Ct, BldPitch, TSR,interpOpt{:});
fCq=@(BldPitch,TSR)  interp2(c.BldPitch, c.TSR, c.Cq, BldPitch, TSR,interpOpt{:});

function op=getOP_LOCAL(BldPitch,TSR,WindSpeed)
    op=struct();
    op.BldPitch=BldPitch;
    op.WindSpeed=WindSpeed;
    op.TSR=TSR;
    op.Cp=fCp(BldPitch,TSR);
    op.Ct=fCt(BldPitch,TSR);
    op.Cq=fCq(BldPitch,TSR);
    op.RotTorq=1/2*model.rho*A*model.R*op.Cp*WindSpeed^2/TSR/1e3; % [kNm]   % 0.5*model.rho*WindSpeed^2*A*op.Cq/1e3; % [kNm]
    op.GenTq=op.RotTorq/model.GBratio; % [kNm] - because it is output!
    op.RotSpeed=radDs2rpm(op.TSR*WindSpeed/model.R); % [rpm]
    op.GenSpeed=op.RotSpeed*model.GBratio; % [rpm]
    op.GenPwr=0.5*model.rho*WindSpeed^3*A*op.Cp/1e3; % [kW]
    op.RotThrust=0.5*model.rho*WindSpeed^2*A*op.Ct;
end



% find grid point with optimal Cp as an initial value
[i_tsrOpt, i_pitchOpt] = find(c.Cp == max(c.Cp, [], 'all'), 1); % note indices are reversed from 3d plotting functions like surf
BldPitch_opt = c.BldPitch(i_pitchOpt);
TSR_opt = c.TSR(i_tsrOpt);


% find optimal cp using optimization
[x_opt,Cp_opt]=fminsearch(@(x) -fCp(x(1),x(2)),[BldPitch_opt TSR_opt]);
Cp_opt=-Cp_opt;
BldPitch_opt=x_opt(1);
TSR_opt=x_opt(2);

% get rated values for unconstrained schedule (might be overwritten)
WindSpeed_rtd=(2*model.rGenPwr_kW*1e3/(model.rho*A*Cp_opt))^(1/3);
rtd=getOP_LOCAL(BldPitch_opt,TSR_opt,WindSpeed_rtd);

%% define constraint
if strcmp(cnstrName,'RotSpeed_rpm')
    RotSpeed_max=rpm2radDs(cnstrVal);
elseif strcmp(cnstrName,'RotThrust_rel')
    Ct_opt=rtd.Ct;
    RotThrust_max=rtd.RotThrust*cnstrVal;
else
    error('not implemented.')
end



%% derive schedule and apply constraints
schedule=rtd([]);
isAboveRtd=false;
for i_wind=1:numel(WindSpeed)


    if ~isAboveRtd
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Below Rated
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % default: use fine pitch and optimal TSR
        BldPitch_act=BldPitch_opt;
        TSR_act=TSR_opt;
        if strcmp(cnstrName,'RotSpeed_rpm')
            % check if TSR needs to be reduced
            TSR_act=min(TSR_opt,RotSpeed_max*model.R/WindSpeed(i_wind));
            if TSR_act~=TSR_opt % RotSpeed constraint is active (transition)
                % compute blade pitch angle for maximum Cp at given TSR
                BldPitch_act=fminsearch(@(x) -fCp(x,TSR_act),BldPitch_opt);
            end
        elseif strcmp(cnstrName,'RotThrust_rel')
            % check if Ct needs to be clipped
            RotThrust_act=0.5*model.rho*WindSpeed(i_wind)^2*A*Ct_opt;
            if RotThrust_act>RotThrust_max
                % compute blade pitch angle and TSR for given Ct that maximizes Cp
                Ct_act=RotThrust_max/(0.5*model.rho*WindSpeed(i_wind)^2*A);
                fObj=@(x) -fCp(x(1),x(2)); % minimize distance to given Ct
                [BldPitch_act,TSR_act]=calcOpt_1D_LOCAL('Ct',Ct_act,model,fObj);
            end
        end
        % compute operating point
        schedule(i_wind)=getOP_LOCAL(BldPitch_act,TSR_act,WindSpeed(i_wind));


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% RATED (check if just crossed from below to above rated)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        if schedule(i_wind).GenPwr>model.rGenPwr_kW % in kW (OpenFast unit)

            % check
            if i_wind==1
                error('GenPwr at lowest wind speed is already above rated GenPwr.')
            end

            % find rated wind speed using linear interpolation between 2 GenPower points 
            if ~isempty(cnstrName)
                tmpWindSpeed12=WindSpeed(i_wind-1:i_wind);
                tmpGenPwr12=[schedule(i_wind-1:i_wind).GenPwr];
                WindSpeed_rtd=interp1(tmpGenPwr12,tmpWindSpeed12,model.rGenPwr_kW);
                TSR_rtd=interp1(tmpWindSpeed12,[schedule(i_wind-1:i_wind).TSR],WindSpeed_rtd,'linear');
                BldPitch_rtd=interp1(tmpWindSpeed12,[schedule(i_wind-1:i_wind).BldPitch],WindSpeed_rtd,'linear');
                rtd=getOP_LOCAL(BldPitch_rtd,TSR_rtd,WindSpeed_rtd);
            end
            schedule(i_wind)=rtd;
            isAboveRtd=true;

        end
    end



    if isAboveRtd
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Above Rated
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        TSR_act=rpm2radDs(rtd.RotSpeed)*model.R/WindSpeed(i_wind); % default: reduce TSR
%         if strcmp(cnstrName,'RotThrust_rel')
%             Ct_act=RotThrust_max/(0.5*model.rho*WindSpeed(i_wind)^2*A);
%             fObj=@(x) (fCt(x(1),x(2))-Ct_act)^2; % minimize distance to given Ct
%         else
            fObj=@(x) (x(2)-TSR_act)^2; % minimize distance to given TSR
%         end
        
        % compute intersection
        Cp_act=rtd.GenPwr*1e3/(0.5*model.rho*WindSpeed(i_wind)^3*A);
        [BldPitch_act,TSR_act]=calcOpt_1D_LOCAL('Cp',Cp_act,model,fObj);

        % compute operating point
        schedule(i_wind+1)=getOP_LOCAL(BldPitch_act,TSR_act,WindSpeed(i_wind));

    end

end



























end



function [BldPitch,TSR]=calcOpt_1D_LOCAL(surfaceName,surfaceValue,model,fObj)

    [BldPitch_grd,TSR_grd]=meshgrid(model.CpCtCq.BldPitch,model.CpCtCq.TSR); 
    % find contour
    cntr=contourc(BldPitch_grd(1,:),...
                  TSR_grd(:,1),...
                  model.CpCtCq.(surfaceName),...
                  [0 surfaceValue]); % note: min. 2 countours need to be evaluated (here 2 is chosen since it is for sure outside of range)
    % evaluate all contour parts
    xq_cntr={};
    while size(cntr,2)>0
        if cntr(1,1)==surfaceValue % contour==Cp line
            % IMPORTANT: contourc swaps dimensions! swap back so 1: BldPitch, 2: TSR 
            xq_cntr{end+1}(2,:)=cntr(2,2:cntr(2,1)+1); %#ok<AGROW>  TSR
            xq_cntr{end}(1,:)=cntr(1,2:cntr(2,1)+1); %#ok<AGROW>    BldPitch
        end    
        cntr(:,1:cntr(2,1)+1)=[];
    end
    if numel(xq_cntr)==2
        % select contour with smaller TSR
        if min(xq_cntr{1}(2,:))<min(xq_cntr{2}(2,:))
            xq_cntr=xq_cntr(1);
        else
            xq_cntr=xq_cntr(2);
        end
    end
    if numel(xq_cntr)~=1
        error(['number of contour segmenents is ' num2str(numel(xq_cntr))])
    end
    xq_cntr=[xq_cntr{:}]; % [2 x n_xp] with first row: BldPitch, second row: TSR
    % compute p coordinate
    n_xp=size(xq_cntr,2);
    xp_cntr=zeros(1,n_xp); % [1 x n_xp]
    for i_xp=2:n_xp
       xp_cntr(i_xp)=xp_cntr(i_xp-1)+norm(xq_cntr(:,i_xp)); % euklid norm for distance between points
    end
    % coordinate transoformation
    xp2xq=@(xp) interp1(xp_cntr,xq_cntr',xp,'linear'); % returns row vector [1 x 2]
  
    % initial value
    fObj_xp=@(xp) fObj(xp2xq(xp));
    obj_cntr=nan(n_xp,1);
    for i_xp=1:n_xp
        obj_cntr(i_xp)=fObj_xp(xp_cntr(i_xp));
    end
    [~,i_xp0]=sort(obj_cntr);
    i_xp0=max(i_xp0(1:10)); % get the minimum with larger BldPitch
    %figure; plot(xp_cntr,obj_cntr); hold on; plot(xp_cntr(i_xp0),fObj_xp(xp_cntr(i_xp0)),'x')
    
    % find optimum
    [xpOpt,objOpt,exitflag,info]=fminsearch(fObj_xp,xp_cntr(i_xp0));
    if exitflag>1
        warning(['maxInterpGridData.m: no solution found. exitflag=' num2str(exitflag)])
    elseif exitflag<1
        error('no feasible solution found.')
    end
    
    % return optimum
    xqOpt=xp2xq(xpOpt);
    BldPitch=xqOpt(1);
    TSR=xqOpt(2);




end

% % plot in case no output arguments are requested
% if numel(xDataScaled)==2 && nargout==0
%     %% plot results if applicable
%     figure;
%     xqOpt=xp2xq(xOpt);
%     contourf(xDataScaled{1},xDataScaled{2},objDataScaled',100,'LineStyle','none')
%     hold on
%     for i_cnstr=1:numel(cnstrDataScaled)
%         if ~isinf(cnstr.ub(i_cnstr))
%             contour(xDataScaled{1},xDataScaled{2},cnstrDataScaled{1}',[cnstr.ub 2],'k')
%         end
%         if ~isinf(cnstr.lb(i_cnstr))
%             contour(xDataScaled{1},xDataScaled{2},cnstrDataScaled{1}',[cnstr.lb 2],'k')
%         end
%     end
% 
%     if exist('xq_cntr','var')
%         plot(xq_cntr(1,:),xq_cntr(2,:),'k:');
%         % evaluate equality constraint at solution
%         disp(['> equality constraint (should be zero): ' ...
%             num2str(interpn(x1q(1,:),x2q(:,1),cntrDataScaled-zeroScaled,xqOpt(1),xqOpt(2),interpOpt{:}))]);
%     end
%     plot(xqOpt(1),xqOpt(2),'rx')
% end

























% 
% 
% 
% 
% 
% 
% 
% 
% function [schedule,rtd]=scheduleBEM(model,ctrl,WindSpeed,varargin)
% % NOTE: schedule.GenTq is in [Nm]
% 
% error('not implemented')
% 
% %% input handling
% 
% % varargin
% if numel(varargin)>0
%     fminconOpt=varargin{1};
% else
%     fminconOpt=[];
% end
% if numel(varargin)>1
%     interpOpt=varargin{2};
%     if ~iscell(interpOpt)
%         interpOpt={interpOpt};
%     end
% else
%     interpOpt={'makima',nan};
% end
% 
% % control
% if ~exist('ctrl','var') || isempty(ctrl)
%     ctrl=struct();
% end
% if ~notempty(ctrl,'belowRtd') 
%     ctrl.belowRtd=struct();
%     ctrl.belowRtd.GenTq='opt'; % {'TSRtracking', 'Kw2', 'opt',struct('windSpeed',[],'GenTq',[])}
%     ctrl.belowRtd.BldPitchC='finePitch'; % {'opt': to be optimized, 'finePitch': take specs.BldPitch_opt, scalar: given finePitch in [deg]}
% end
% if ~notempty(ctrl,'aboveRtd') 
%     ctrl.aboveRtd=struct();
%     ctrl.aboveRtd.GenTq='rtd'; % {'rtd': rated GenTq, scalar: given GenTq in [Nm]; 'opt': optimize using standard goal; 'optOutName': optimize output with name <OutName>}
%     ctrl.aboveRtd.BldPitchC='opt'; % {'opt': optimize using standard goal (=maintain rated GenSpeed), 'optOutName': optimize ouput with name <OutName>}
%     % NOTE: if GenTq is not 'rtd', there might be a transition phase
% end
% if strncmpi(ctrl.belowRtd.BldPitchC,'fine',4)
%     ctrl.belowRtd.BldPitchC=specs.BldPitch_opt;
% end
% % constraints (NOTE: are applied on outputs, i.e., GenTq is in [kNm])
% if ~notempty(ctrl.belowRtd,'cnstr')
%     ctrl.belowRtd.cnstr=struct('OutName',{{}},'lb',[],'ub',[]); 
% end
% if ~notempty(ctrl.aboveRtd,'cnstr')
%     ctrl.aboveRtd.cnstr=struct('OutName',{{}},'lb',[],'ub',[]); % Note: if a value is set to 'nan', the rated value is taken!
% end
% 
% % wind speed
% if ~exist('WindSpeed','var')
%     WindSpeed=0:0.25:25;
% elseif iscell(WindSpeed)
%     WindSpeed=WindSpeed{1}:0.25:WindSpeed{2};
% end
% 
% 
% %% compute optima
% 
% % re-assign for easier access
% c=model.CpCtCq;
% 
% 
% % define interpolation function
% fCp=@(BldPitch_deg,TSR)  interp2(c.BldPitch, c.TSR, c.Cp, BldPitch_deg, TSR,'spline');
% fCt=@(BldPitch_deg,TSR)  interp2(c.BldPitch, c.TSR, c.Ct, beta_deg, TSR,'spline');
% 
% 
% % find grid point with optimal Cp as an initial value
% [i_tsrOpt, i_pitchOpt] = find(c.Cp == max(c.Cp, [], 'all'), 1); % note indices are reversed from 3d plotting functions like surf
% BldPitch_opt_deg = c.BldPitch(i_pitchOpt);
% TSR_opt = c.TSR(i_tsrOpt);
% 
% 
% % find optimal cp using optimization
% [x_opt,Cp_opt]=fminsearch(@(x) -fCp(x(1),x(2)),[BldPitch_opt_deg TSR_opt]);
% Cp_opt=-Cp_opt;
% BldPitch_opt_deg=x_opt(1);
% TSR_opt=x_opt(2);
% 
% % get rated values for unconstrained schedule (might be overwritten)
% rtd=struct();
% rtd.GenPwr=model.rGenPwr_kW;
% rtd.WindSpeed=(2*rGenPwr_kW*1e3/(model.rho*model.R^2*pi*Cp_opt))^(1/3);
% rtd.RotSpeed=TSR_opt*rtd.WindSpeed/model.R;
% rtd.GenSpeed=rtd.RotSpeed*model.GBratio;
% rtd.GenTq=rtd.GenPwr*1e3/rtd.GenSpeed;
% 
% 
% 
% % find rated wind speed for constrained schedule
% if ctrl.belowRtd.cnstr.OutName
%     
% end
% 
% 
% %% derive schedule and apply constraints
% schedule=struct();
% 
% for i_wind=1:numel(WindSpeed)
%     
% end
% 
% 
% 
% 
% WindSpeed=unique([v_rated_mDs*0.999 v_rated_mDs WindSpeed(:)']); 
% n_wind=numel(v_mDs_arr);  % number of wind speeds
% n_windBelowRtd=find(v_mDs_arr==v_rated_mDs*0.999); % below rated wind speeds 
% n_windAboveRtd=n_wind-n_windBelowRtd; % above rated wind speeds
% 
% 
% 
% for i_wind=1:n_wind
%     
% 
% 
% end








