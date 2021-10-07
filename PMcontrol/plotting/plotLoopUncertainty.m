function varargout=plotLoopUncertainty(loopData,w,type)

% handle input
if ~exist('w','var'), w={1e-2 1e2}; end % frequency in [rad/s]
if ~exist('type','var') || isempty(type)
    type='out';
end

% default plot options
sigmaOpt=sigmaoptions('cstprefs');
sigmaOpt.XLabel.Interpreter='none';
sigmaOpt.YLabel.Interpreter='none';
sigmaOpt.Title.Interpreter='none';
sigmaOpt.InputLabels.Interpreter='none';
sigmaOpt.OutputLabels.Interpreter='none';
sigmaOpt.InputVisible={'off'};
sigmaOpt.OutputVisible={'off'};
sigmaOpt.Grid='on';
sigmaOpt.MagUnits='dB';
n_col=[];

% plot allowed uncertainty
hFig=figure('NumberTitle','off','Name',[type 'Uncertainty']);
switch lower(type)

    case 'out'
        
        n_y=size(loopData.So,1);
        if isempty(n_col)
            n_col=1;
        end
        n_row=ceil(n_y/n_col);
         
        for i_y=1:n_y
            subplot(n_row,n_col,i_y);
            sigma(inv(loopData.To(i_y,i_y)),w,sigmaOpt); 
            %ylim([0 10]); 
            title(['allowed multipl. uncert. @ ' loopData.C.InputName{i_y}]);
        end
    
    case 'in'

        n_u=size(loopData.So,1);
        if isempty(n_col)
            n_col=n_u;
        end
        n_row=ceil(n_u/n_col);
         
        for i_u=1:n_u
            subplot(n_row,n_col,i_u);
            sigma(inv(loopData.Ti(i_u,i_u)),w,sigmaOpt); 
            %ylim([0 10]); 
            title(['allowed multipl. uncert. @ ' loopData.C.OutputName{i_u}]);
        end

    case 'add'

        [sv,w]=sigma(loopData.CSo,w);
        sys=frd(reshape(min(1./sv,[],1),[],1,length(w)),w);
        sigma(sys,w,sigmaOpt);
        title('allowed additive uncertainty');


    otherwise
        error('not implemented.');

end
  
    
    

if nargout>1
    varargout{1}=hFig;
end
