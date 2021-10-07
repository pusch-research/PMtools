function n=norm(frdSys,p)

if ~exist('p','var'), p=2; end
if prod(size(frdSys))>1, error('not implemented.'); end

switch p
    case 2
        % approximate H2 norm by integration over frequency response data
        % note that H2 norm depends on FrequencyUnit and/or TimeUnit
        % IMPORTANT: a system without feedthrough is assumed!
        if strcmp(frdSys.FrequencyUnit(1:3),'rad'), scal=1;
        else scal=2*pi; end % conversion of rounds to radians
        n=sqrt(scal/pi*trapz(frdSys.Frequency,conj(frdSys.ResponseData(:)).*frdSys.ResponseData(:)));
    case inf
        n=max(abs(frdSys.ResponseData(:)));
    otherwise
        error('not implemented');
end