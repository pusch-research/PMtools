function simData=recoverBldPitchMoment(simData,FSTdata,I_drive)
% compute add blade inertia loads to RootMcz# channel using blade tip deflection only for inertia computation
% TODO: compute blade inertia using flexible blade deflections at different station

if nargin<3
    I_drive=0;
end

n_bld=FSTdata.EDFile.NumBl;

for i_sim=1:numel(simData)
    for i_bld=1:n_bld
    
        % params
        bldLength=FSTdata.AeroFile.(['ADBlFile_' num2str(i_bld) '_']).BldNode.BlSpn(end);
        bldProp=FSTdata.EDFile.(['BldFile_' num2str(i_bld) '_']).BldProp;
        z0Pos_seg=bldProp.BlFract*bldLength; % z position in [m]
        length_seg=[diff([0;diff(z0Pos_seg)/2+z0Pos_seg(1:end-1)]);diff(z0Pos_seg(end-1:end))/2]; % length of each segment in [m]
        Iz_seg=(bldProp.FlpIner+bldProp.EdgIner).*length_seg;
        m_seg=bldProp.BMassDen.*length_seg;
       
        % time series
        OoPDefl=simData(i_sim).(['OoPDefl' num2str(i_bld)]);
        IPDefl=simData(i_sim).(['IPDefl' num2str(i_bld)]);
        RootMzc=simData(i_sim).(['RootMzc' num2str(i_bld)]);
        BldPitch_ddot=deg2rad(simData(i_sim).(['BldPitch' num2str(i_bld) '_ddot_noSpk']));
    
        % compute inertia loads (with linear interpolation of blade deflections between tip and root)
        Iz=I_drive+sum(Iz_seg+diag(m_seg)*(bldProp.BlFract*(OoPDefl.^2+IPDefl.^2)'),1)';
        Mzc_inert=Iz.*BldPitch_ddot/1e3; % [kNm]
        
        % save results
        simData(i_sim).(['IzBld' num2str(i_bld)])=Iz;
        simData(i_sim).(['RootMzc' num2str(i_bld) '_inert'])=Mzc_inert;
        simData(i_sim).(['RootMzc' num2str(i_bld) '_new'])=RootMzc+Mzc_inert;
        
    end
end
