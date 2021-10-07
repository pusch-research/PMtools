function varargout = kappa(P1, P2, varargin)
%kappa Frequency-wise v-gap between  two dynamic system.
%   [k,ksup,omega] = kappa(P1,P2) or [k,ksup] = kappa(P1,P2,omega) returns
%   the frequency-wise v-Gap between the dynamical systems P1 and P2 as
%   defined in Vinnicombe (2000, p.123).  This essentially gives a
%   frequency-wise measure of the difference between two plants and the
%   worst-case drop in closed-loop performance if a controller designed for
%   one system is used with the other.  Following the reference, ksup is
%   the supremum of k if [P2, -P1'] has the same number of open RHP poles 
%   as [P1, -P1'], otherwise it will be set to unity.
%
%   kappa(P1,P2) or kappa(P1,p2,omega) without any output arguments will
%   display the results in graphical form.
%
%   REFERENCE
%   1. Vinnicombe, G. (2000) Uncertainty and Feedback: H-Infinity 
%      Loop-Shaping and the v-Gap Metric. London: Imperial College
%
%   See also: sigma, rho.

% Check that we have access to graphsymbols.
graphsymbolsExists = exist('graphsymbols', 'file') > 0;
assert(graphsymbolsExists, 'graphsymbols:missingDependency', ...
    ['Missing dependency: "graphsymbols.m" - please download for free ' ...
    'from MATLAB File Exchange.']);

% Check the number of input arguments.
narginchk(2, 3);


% Check the input arguments.
assert(isequal(size(P1), size(P2)));
assert(isequal(P1.Ts, P2.Ts));

% Ensure scaling starts out as something sensible.  Cover up any warning
% messages we don't need to worry about.
P1 = prescale(ss(P1));
P2 = prescale(ss(P2));


% Map to the continuous domain if necessary.  We can't guarantee our
% dependencies will support discrete time functions, so it's simpler to do
% a single conversions.
sampleTime = P1.Ts;
usingDiscreteTime = ~isequal(sampleTime, 0.0);
if usingDiscreteTime    
    P1 = mapToContinuous(P1);
    P2 = mapToContinuous(P2);    
end


% Compute the normalized left and right graph symbols for P1 and P2.
[~,G1r] = graphsymbols(P1);
[G2l,G2r] = graphsymbols(P2);

% Find the frequency-wise nu-gap.
GG1 = prescale(G2l * G1r);
% We have to map back to discrete time for this calculation - if we were
% feeling a bit cleverer, we might transform omega, but there might be
% frequency-spacing issues to overcome.
if usingDiscreteTime
    GG1 = c2d(GG1, 1, 'tustin');
    GG1 = prescale(GG1);
    GG1.Ts = sampleTime;
end
[kAll, omega] = sigma(GG1, varargin{:});
k = max(kAll, [], 1);
k = reshape(k, size(omega));

% Make sure we don't get odd small errors by applying known limits.
k(k>1) = 1;
k(k<0) = 0;

% Check that the winding number condition is satisfied. If not, we need to
% increase k to 1 to indicate this.
GG2 = G2r' * G1r;
detGG2 = sysdet(GG2);
detGreaterThanZeroOnImagAxis = norm(inv(detGG2), inf) < inf;
wnoDetEqualsZero = wno(detGG2) == 0;
windingNumberConditionOK = detGreaterThanZeroOnImagAxis & wnoDetEqualsZero;

% Compute the value of k:
if windingNumberConditionOK
    % The 'default' value of ksup is the supremum (essential maximum) of k:
    ksup = norm(GG1, inf);
    ksup = max(ksup, max(abs(k(:)))); % avoid small inconsistencies    
else
    % When the winding number condition is not met, ksup = 1.
    ksup = 1;
end

% Return optional output arguments.
if nargout > 0
    varargout = {k, ksup, omega};
    return
end

% Generate a plot if required.
varargout = {};
semilogx(omega, k)
hLine = line([omega(1) omega(end)], [ksup ksup]);
set(hLine, 'LineStyle', ':', 'Color', 'k');
ylim([0 1]);
xlabel('Frequency (rad/s)');
ylabel('Frequency-Wise \nu-Gap');
title('Frequency-Wise \nu-Gap');
if usingDiscreteTime
    nyquistFreq = pi / sampleTime;
    hLine = line([nyquistFreq nyquistFreq], [0 1]);
    set(hLine, 'LineStyle', '-', 'Color', [0 0 0]);
end

end


function w = wno(sys)
%wno Winding number about the origin of a SISO dynamic system

assert(issiso(sys));
assert(isct(sys));
sys = prescale(ss(sys));

z = zero(sys);
p = pole(sys);

zOpenRHP = z(z > 0);
pOpenRHP = p(p > 0);

w = numel(zOpenRHP) - numel(pOpenRHP);

end



function detP = sysdet(P)
%sysdet Calculate the determinant of a dynamic system.

P = prescale(ss(P));
[ny,nu] = size(P);
assert(isequal(ny,nu));
if ny == 1
    detP = sminreal(P);
    detP = minreal(detP, [], false);
    return
end

detP = ss(0);
theSigns = -((-1).^(1:ny));
for iy = 1:ny
    idx = [1:iy-1, iy+1:ny];
    Psub = P(2:ny, idx);    
    Psub = sminreal(Psub);
    detP = detP + P(1, iy) * theSigns(iy) * sysdet(Psub);
end
detP = sminreal(detP);
detP = minreal(detP, [], false);
detP = prescale(detP);
    
end



function Pc = mapToContinuous(Pd)
%mapToContinuous Map a discrete system to the S-domain

Pd.Ts = 1;
Pc = d2c(Pd, 'tustin');
Pc = prescale(Pc);

end