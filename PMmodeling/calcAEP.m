function AEP=calcAEP(GenPwr,WindSpeed,a,b)

if ~exist('a','var')
    a=11.29; % default scale parameter for Weibull distribution
end
if ~exist('b','var')
    b=2; % default shape parameter for Weibull distribution
end

calcOpt=2;
switch calcOpt
    case 1
        AEP=trapz(WindSpeed,wblpdf(WindSpeed,a,b).*GenPwr)*8765.81278/1e6; %[GWh/year]
    case 2
        tmpWindSpeed=[WindSpeed(1) WindSpeed]+[0 diff(WindSpeed)/2 0];
        binProbs=wblcdf(tmpWindSpeed(2:end),a,b)-wblcdf(tmpWindSpeed(1:end-1),a,b);
        AEP = binProbs*GenPwr(:)*8765.81278/1e6; % in GWh/yr\
    otherwise 
        error('not implemented.')
end