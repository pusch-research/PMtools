function q=ma2q(ma,h)

[~,rho,~,a] = atmo_isa(h);
q     = 1/2*rho.*(ma.*a).^2;       % dynamic pressure