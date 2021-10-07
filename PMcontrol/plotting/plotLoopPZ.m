function varargout=plotLoopPZ(loopData,outArr,inArr)


if nargin<=1
    outArr='meas';
    inArr='acts';
end

if isempty(outArr)
    outArr=1:size(loopData.P,2);
end

if isempty(inArr)
    inArr=1:size(loopData.P,1);
end


%% plot zeros & poles

h=figure('Name','Pole-Zero','NumberTitle','off');

% close loop
d=tzero(loopData.CL(outArr,inArr));
scatter(real(d),imag(d),100,'o','MarkerEdgeColor',[0.1 1 0.1],'Linewidth',3); hold on
d=loopData.poles.CL;
hAx(1)=scatter(real(d),imag(d),100,'x','MarkerEdgeColor',[0.1 1 0.1]*0.8,'Linewidth',3); hold on

% plant
d=tzero(loopData.P(outArr,inArr));
scatter(real(d),imag(d),200,'o','MarkerEdgeColor',[1 0.1 0.1]); hold on
d=loopData.poles.P;
hAx(2)=scatter(real(d),imag(d),200,'x','MarkerEdgeColor',[1 0.1 0.1]*0.8); hold on


% controller
d=tzero(loopData.C);
scatter(real(d),imag(d),100,'o','MarkerEdgeColor',[0.1 0.1 1],'Linewidth',1); hold on
d=loopData.poles.C;
hAx(3)=scatter(real(d),imag(d),100,'x','MarkerEdgeColor',[0.1 0.1 1]*0.8,'Linewidth',1); hold on


%xlim([-100 10])
sgrid
set(findobj(gcf, 'LineStyle', ':'), 'LineStyle', '-', 'Color', .8*[1,1,1])
legend(hAx,'CL','P','C');


%% return
if nargout>0
    varargout{1}=h;
end