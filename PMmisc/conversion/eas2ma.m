function ma=eas2ma(eas_mDs,h_m)

tas_mDs=eas2tas(eas_mDs,h_m);
ma=tas2ma(tas_mDs,h_m);
