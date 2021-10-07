function ma=tas2ma(tas,h)

[~,~,~,a]=atmo_isa(h);
ma=tas/a;