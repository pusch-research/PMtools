function cas_mDs=eas2cas(eas_mDs,h_m)

tas_mDs=eas2tas(eas_mDs,h_m);
cas_mDs=tas2cas(tas_mDs,h_m);
