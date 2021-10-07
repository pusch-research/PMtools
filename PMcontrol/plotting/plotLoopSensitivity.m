function varargout=plotLoopSensitivity(loopData,w)

% handle input
if ~exist('w','var'), w={1e-2 1e2}; end % frequency in [rad/s]

% default plot options
sigmaOpt=sigmaoptions('cstprefs');
sigmaOpt.XLabel.Interpreter='none';
sigmaOpt.YLabel.Interpreter='none';
sigmaOpt.Title.Interpreter='none';
sigmaOpt.InputLabels.Interpreter='none';
sigmaOpt.OutputLabels.Interpreter='none';
sigmaOpt.Grid='on';

% plot gang-of-6
h=figure('Name','sensitivity','NumberTitle','off');
YL=-40;
peaks=loopData.peaks;
subplot(3,2,1)
    sigma(loopData.So,w,sigmaOpt);
    if notempty(peaks,'So') 
        ylim([YL(1),db(2*peaks.So)]);
    end
    title('So (dy->y)') % title('S')
subplot(3,2,2)
    sigma(loopData.PSi,w,sigmaOpt);
    if notempty(peaks,'PSi') 
        ylim([YL(1),db(2*peaks.PSi)]);
    end
    title('PSi (du->y)') % title('SG')
subplot(3,2,3)
    sigma(loopData.CSo,w,sigmaOpt);
    %ylim([YL(1), db(2*peaks.CSo))]);
    title('CSo (dy->u)') % title('CS')
subplot(3,2,4)
    sigma(loopData.Ti,w,sigmaOpt);
    if notempty(peaks,'Ti')
        ylim([YL(1),db(2*peaks.Ti)]);
    end
    title('Ti (du->u)')
subplot(3,2,5)
    sigma(loopData.To,w,sigmaOpt);
    if notempty(peaks,'To')
        ylim([YL(1),db(2*peaks.To)]);
    end
    title('To (ny->y)')
subplot(3,2,6)
    sigma(loopData.Si,w,sigmaOpt);
    if notempty(peaks,'Si')
        ylim([YL(1),db(2*peaks.Si)]);
    end
    title('Si (nu->u)')
    
    
if nargout>0
    varargout{1}=h;
end