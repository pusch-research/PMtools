function [varargout] = cas2tas(varargin)
% [V_tas] = cas2tas(V_cas,h)
%
% Calibrated air speed (V_cas) to true air speed (V_tas) conversion.
%
% INPUT:         V_cas - calibrated air speed [m/s]
%                h     - altitude [m]
%
% OUTPUT:        V_tas - true air speed [m/s]
%
% Dependencies:  atmo_isa
%
% Reference:     LTH Belastungsmechanik, BM 14 300-03
%

%--------------------------------------------------------------------------
% Input
%--------------------------------------------------------------------------
V_cas = varargin{1}(:);
h     = varargin{2}(:);

%--------------------------------------------------------------------------
% Main
%--------------------------------------------------------------------------

% atmosphere
dT = 0;
[p0,rho0,T0,a0,mu0,g0] = atmo_isa(0,dT);
[p,rho,T,a,mu,g]       = atmo_isa(h,dT);

% TAS: true air speed
V_tas = sqrt(5*a.^2.*(((rho0*a0^2./rho./a.^2).*(1 + 0.2.*(V_cas./a0).^2).^3.5 - rho0*a0^2./rho./a.^2 + 1).^(1/3.5) - 1));

%--------------------------------------------------------------------------
% Output
%--------------------------------------------------------------------------
varargout{1} = V_tas(:);

end %function cas2tas
