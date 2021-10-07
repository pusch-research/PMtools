function [varargout] = ma2cas(varargin)
% V_cas = M2cas(M,h)			
%                   gives V_cas as a function of altitude and Mach number 
%                   for the Int. Standard Atmosphere (ISA).
% Input:	
%   M               - Mach number [-]
%   h               - altitude [m], -5000 <= h <= 47000 
% Output:
%   V_cas           - Calibrated Air Speed  [m/s]
%


%---------------------------------------------------------------------------------------------------
% Initialization 
%---------------------------------------------------------------------------------------------------

  M = varargin{1};
  h = varargin{2};

  if h < -5000 | h > 47000, h, error('Altitude must be -5000 <= h <= 47000 .'); end

  R           = 287.05287;    % spec. gas constant 
  gamma       = 1.4;          % ratio of specific heats
  g0          = 9.80665;      % acceleration of gravity (sea level)

  % properties of:  troposphere  stratosphere          mesosphere  
  %                                           20km<h<32km  32km<h<47km
  href        = [      0.0        11000.0     20000.0     32000.0     ]; % reference altitude  
  Tref        = [    288.15         216.65      216.65      228.65    ]; % temperature at href
  pref        = [ 101325.0        22632.04     5474.878     868.0158  ]; % pressure at href
  lambda      = [     -0.0065         0.0         0.001       0.0028  ]; % temperature gradient
  
  % properties at sea level
  p0          = pref(1); 
  T0          = Tref(1);
  rho0        = p0/R/T0;    
  a0          = sqrt(gamma*R*T0);  


%---------------------------------------------------------------------------------------------------
% Atmospheric properties and calibrated air speed according to int. standard atmosphere  
%---------------------------------------------------------------------------------------------------
  
  % find corresponding atmospheric layer for altitude h
  hbound      = [-5001.0 11000.0 20000.0 32000.0 47000.0]; 
  i           = min(find(hbound>=h))-1;
  
  % properties at altitude h
  if lambda(i) == 0
      p = pref(i)*exp(-g0*(h-href(i))/R/Tref(i));
  else
      p = pref(i)*(1+lambda(i)*(h-href(i))/Tref(i))^(-g0/R/lambda(i));
  end
  T   = Tref(i)+lambda(i)*(h-href(i));
  rho = p/R/T;
  
  % Calibrated Air Speed.
  V_cas = sqrt(2*a0^2/(gamma-1)*...
      ((((1+(gamma-1)/2*M^2)^(gamma/(gamma-1))-1)*p/p0+1)^((gamma-1)/gamma)-1));
      
%---------------------------------------------------------------------------------------------------
% Write results 
%---------------------------------------------------------------------------------------------------
  
  varargout{1}    = V_cas;
  
  return
