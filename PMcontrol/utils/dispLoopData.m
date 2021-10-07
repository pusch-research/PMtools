% with looppeaks LP from getLoopData.m
function []=dispLoopData(loopData)

% display poles
disp(['> plant pole range (real): [' num2str(minmax(real(eig(loopData.P))'),'%.2e') ']']);
disp(['> reg pole range (real)  : [' num2str(minmax(real(eig(loopData.C))'),'%.2e') ']']);
disp(['> cl pole range (real)   : [' num2str(minmax(real(eig(loopData.CL))'),'%.2e') ']']);

% display peaks
disp('> peaks of loop transfer functions (Hinf norm):')
peaks=loopData.peaks;
disp_arr={'Li'  'Lo'  'PSi' 'C';...
          'Si'  'So'  'CSo' 'P';...
          'Ti'  'To'  'GAM' 'CL'};
disp_arr(~ismember(disp_arr,fieldnames(peaks)))=[];
for ii=1:numel(disp_arr)
    s=disp_arr{ii};
    disp_arr{ii}=[s ': ' num2str(peaks.(s),'%.3g') ...
                  '@' num2str(peaks.(['w' s])/(2*pi),'%.2g') 'Hz'];
end
disp(disp_arr);


           