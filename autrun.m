
PMtoolsWorkDir=fileparts(mfilename('fullpath'));


% add PMcontrol
addpath(fullfile(PMtoolsWorkDir,'PMcontrol'));
addpath(fullfile(PMtoolsWorkDir,'PMcontrol','utils'));
addpath(fullfile(PMtoolsWorkDir,'PMcontrol','plotting'));

% add PMmisc
addpath(fullfile(PMtoolsWorkDir,'PMmisc'));
addpath(fullfile(PMtoolsWorkDir,'PMmisc','conversion'));
addpath(fullfile(PMtoolsWorkDir,'PMmisc','copy_override'));% add copied matlab functions (due to license errors or small supplements)
addpath(fullfile(PMtoolsWorkDir,'PMmisc','mtimesx_v1.41')); 
addpath(fullfile(PMtoolsWorkDir,'PMmisc','matlab2tikz')); 
addpath(fullfile(PMtoolsWorkDir,'PMmisc','xmatlabfrag')); 

% add PMmodeling
addpath(fullfile(PMtoolsWorkDir,'PMmodeling'));
addpath(fullfile(PMtoolsWorkDir,'PMmodeling','utils'));

% clean up
clear PMtoolsWorkDir
disp('> PMtools added..');
