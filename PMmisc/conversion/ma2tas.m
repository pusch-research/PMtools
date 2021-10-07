function tas=ma2tas(ma,h)

[~,~,~,a]=atmo_isa(h);
tas=ma.*a;