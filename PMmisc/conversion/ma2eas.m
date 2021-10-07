function eas_mDs=ma2eas(ma,h_m)

tas_mDs=ma2tas(ma,h_m);
eas_mDs=tas2eas(tas_mDs,h_m);
