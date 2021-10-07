function bodeOpt=getBodeOpt(varargin)

bodeOpt=bodeoptions('cstprefs');
bodeOpt.XLabel.Interpreter='none';
bodeOpt.YLabel.Interpreter='none';
bodeOpt.Title.Interpreter='none';
bodeOpt.InputLabels.Interpreter='none';
bodeOpt.OutputLabels.Interpreter='none';
bodeOpt.PhaseVisible='off';
bodeOpt.PhaseMatching = 'on'; 
bodeOpt.PhaseMatchingFreq = 1; 
bodeOpt.PhaseMatchingValue = 0;
bodeOpt.Grid='on';


for ii=1:2:numel(varargin)
    bodeOpt.(varargin{ii})=varargin{ii+1};
end
