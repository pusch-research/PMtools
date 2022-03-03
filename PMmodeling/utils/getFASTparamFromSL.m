function [OutList,DT]=getFASTparamFromSL(FASTinputFile,SLmodelWithFASTsfunction)

% this is a hack to obtain OutList and DT of a FAST model which is
% implemented as a s-function in Simulink

if nargin<=1
    SLmodelWithFASTsfunction='model_FASTsfunctionOnly';
end


% check if OutList variable exists in base workspace
restoreOutList=evalin('base','exist(''OutList'',''var'')');
restoreDT=evalin('base','exist(''DT'',''var'')');
restoreFASTinputFile=evalin('base','exist(''FASTinputFile'',''var'')');
if restoreOutList
    tmpOutList=evalin('base', 'OutList');
end
if restoreDT
    tmpDT=evalin('base', 'DT');
end
if restoreFASTinputFile
    tmpFASTinputFile=evalin('base', 'FASTinputFile');
end

% initialize SL model (FAST sfunction writes OutList into base workspace)
% try
    assignin('base','FASTinputFile',FASTinputFile)
%     sim(SLmodelWithFASTsfunction)
try
    clear mex % to avoid total crash which happens sometimes
    evalc([SLmodelWithFASTsfunction '([],[],[],''sizes'')']);
    stop()
catch ex
    if strcmp(ex.identifier,'Simulink:SFunctions:SFcnParamCountErr')
        error('FAST sfunction is currently running. Stop other simulations first.')
    end
    stop()
    rethrow(ex)
end
% catch
% end
OutList=evalin("base",'OutList');
DT=evalin("base",'DT');
% evalc([SLmodelWithFASTsfunction '([],[],[],''term'')'])

% restore or delete OutList in base workspace
if restoreOutList
    assignin('base','OutList',tmpOutList)
else
    evalin('base','clear OutList')
end
if restoreDT
    assignin('base','DT',tmpDT)
else
    evalin('base','clear DT')
end
if restoreFASTinputFile
    assignin('base','FASTinputFile',tmpFASTinputFile)
else
    evalin('base','clear FASTinputFile')
end


function stop()
    clear mex % to avoid total crash which happens sometimes
    w=warning('query','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:FileNotFound')
    delete([FASTinputFile(1:end-4) '.SFunc.SD.ech']) 
    delete([FASTinputFile(1:end-4) '.SFunc.SD.sum']) 
    delete([FASTinputFile(1:end-4) '.SFunc.ED.sum']) 
    delete([FASTinputFile(1:end-4) '.SFunc.outb'])
    delete([FASTinputFile(1:end-4) '.SFunc.out'])
    delete([FASTinputFile(1:end-4) '.SFunc.SrvD.Sum'])
    warning(w.state,'MATLAB:DELETE:FileNotFound')

end
end