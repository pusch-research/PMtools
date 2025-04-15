% XPADE interval Padé approximation of dead time(s)
%   
%   XPADE(TD) make bode plot comparison of deadtimes defined in vector TD
%   Padé approximated interval-wise with order one
%   [SYS]=XPADE(TD) returns an ss object
%   [A,B,C,D]=XPADE(TD) returns statespace matrices
%   [..]=XPADE(TD,N) N defines the order of the pade approximation for each
%   interval. For a unique order N is a scalar, otherwise N must have the 
%   same size as the unique TD values without zero-delay.
%   
%   Example: XPADE([1 2 3])
%       
%   See also PADE

% REVISIONS:    2012 implementation (AK)
%               2014-05-16 add order N (MP)
% 
% Contact       manuel.pusch@dlr.de
% Copyright (C) 2014 DLR Robotics and Mechatronics              __/|__
%                                                              /_/_/_/
%                                                                |/ DLR

function varargout = xPade(Td,N)

%% Input chek
if isempty(Td)
    varargout{1}=ss;
    return
end

if prod(size(Td))~=max(size(Td)) %#ok<PSIZE>
    error('Td must be a vector!')
end

if any(Td<0)
    error('Td must be positive')
end


%% Compute time delays
[Td_sort, ~, ind_y] = unique(Td(:));
dT                  = diff([0; Td_sort(:)]);

% Remove zero delay
delZero=dT(1)==0;
if delZero
    dT(1) = [];
end

% Compute nDelays
n_delays = length(dT);

% check order
if ~exist('N','var')
   N=ones(n_delays);
elseif numel(N)==1
   N=repmat(N,size(Td));
elseif numel(N)~=n_delays
   error('wrong size of order N.');
end

%% Compute A, B C and D matrix
% example for T=T1=T2=T3:
%        | A        | B   |
%        | BC  A    | BD  |
%        | BDC DC A | BD² |
%        |----------------|
%        | C        | D   | 
%        | DC       | D²  |
%        | D²C      | D³  |
% e.g. with first order approximation: A=-2/T;B=4/T;C=1;D=-1 (outputs scaled to 1 and -1, no balancing)

if all(N==1) && ~isempty(dT)
    % Compute first order pade approximation: e^(-sT)=(1+(-sT)/2)/(1-(-sT)/2)+error (for each zone from front to back edge respectively)
    A_el = -2./dT;
    B_el =  4./dT;

    % Compute a helping matrix
    tmp                =  zeros(2*floor(n_delays/2)+1);
    tmp(1:2:numel(tmp))=  1;
    tmp(2:2:numel(tmp))= -1;
    tmp                =  tril(tmp(1:n_delays,1:n_delays));

    % Compute A, B, C, D matrix
    A = diag(A_el) + diag(B_el)*(diag(diag(tmp))-tmp);
    B = B_el.*tmp(:,1);
    C =  tmp(:, :);
    D = -tmp(:,1);
elseif ~isempty(dT) % slow!
    % compute nth order pade approximation
    [num,denum]=padecoef(dT(1),N(1));
    [A,B,C,D]=ssdata(ss(tf(num,denum))); % model is balanced/scaled automatically
    for i=2:n_delays
        [num,denum]=padecoef(dT(i),N(i));
        pade_sys=ss(tf(num,denum));
        A=[A                    zeros(length(A),length(pade_sys.a));...
           pade_sys.b*C(end,:)  pade_sys.a                          ];
        B=[B;...
           pade_sys.b*D(end,:)];
        C=[C                    zeros(size(C,1),size(pade_sys.c,2));...
           pade_sys.d*C(end,:)  pade_sys.c                         ];
        D=[D;...
           pade_sys.d*D(end,:)];
    end
else 
    A = zeros(0,0);
    B = zeros(0,1);
    C = zeros(0,0);
    D = zeros(0,1);
end

% Add zero if remove
if delZero
    C = [zeros(1,size(C,2)); C];
    D = [1;                  D];
end

% Reorder outputs
C = C(ind_y,:);
D = D(ind_y,:);

%% Create plot or outputs
if nargout==0
    bandwidthLine=125; % draw line for max bandwidth
    ref = ss(ones(size(Td(:))), 'OutputDelay', Td(:));
    figure
    subplot(121)
        bode(ss(A, B, C, D), ref,     xbodeoptions('MagVisible', 'off', 'PhaseMatching', 'on', 'YLimMode', 'manual', 'YLim', [-720 0]));
        hChildren=findobj(gcf,'Type','Axes'); hPlot=hChildren(1); % grab phase plot
        grid
        hold on
        plot(hPlot,[bandwidthLine bandwidthLine],[-1e3 1e3],'k');
        legend(hPlot,'approx','ref',['bandwidth=' num2str(bandwidthLine) 'rad/s']);
        title('Phase Diagram')
    subplot(122)
        bode(ss(A, B, C, D)-ref, 'r', xbodeoptions('PhaseVisible', 'off', 'YLimMode', 'manual', 'YLim', [-40 20]))
        hChildren=findobj(gcf,'Type','Axes'); hPlot=hChildren(3); % grab magnitude plot
        grid
        hold on
        plot(hPlot,[bandwidthLine bandwidthLine],[-1e3 1e3],'k');
        legend(hPlot,'approx-ref',['bandwidth=' num2str(bandwidthLine) 'rad/s']);
        title('Error')   
    maximize
elseif nargout==1
    varargout{1} = ss(A, B, C, D);
else
    varargout{1} = A;
    varargout{2} = B;
    varargout{3} = C;
    varargout{4} = D;
end
    
%% eof