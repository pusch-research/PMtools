function sys=xbutter(varargin)
% see R2016b\toolbox\signal\signal\butter.m


if numel(varargin)==4 && isequal(varargin([3 4]),{'low','s'})
    sys=analogButter_low(varargin{[1 2]});
elseif isequal(varargin([3 4]),{'bathtub','s'})
    error('not implemented.')
    % butterworth bathtub filter
%     sys=zpk(xbutter(n,wc(2:3),'bandpass','s'));
%     z=sys.P(1:end/2)/
%     s=tf('s');
%     f=tf(,f.Denominator);
    
else
    % use signal processing toolbox
    [a,b,c,d]=butter(varargin{:});
    sys=ss(a,b,c,d);
end





function sys=analogButter_low(n,w)

% Poles are on the unit circle in the left-half plane.
z = [];
p = exp(1i*(pi*(1:2:n-1)/(2*n) + pi/2));
p = [p; conj(p)];
p = p(:);
if rem(n,2)==1   % n is odd
    p = [p; -1];
end
k = real(prod(-p));
% to ss
[a,b,c,d] = zp2ss(z,p,k);
sys=ss(a*w,b*w,c,d);










% function [Z, P, G] = myButter(n, W, pass,varargin)
% % from https://de.mathworks.com/matlabcentral/answers/137778-butterworth-lowpass-filtering-without-signal-processing-toolbox
% % Digital Butterworth filter, either 2 or 3 outputs
% % Jan Simon, 2014, BSD licence
% % See docs of BUTTER for input and output
% % Fast hack with limited accuracy: Handle with care!
% % Until n=15 the relative difference to Matlab's BUTTER is < 100*eps
% 
% if n>15
%     warning('butterworth filter may not be accurate.');
% end
% if ~isequal(varargin,{'s'})
%     error('not implemented.'); % DIGITAL ONLY!
% end
% 
% V = tan(W * 1.5707963267948966);
% Q = exp((1.5707963267948966i / n) * ((2 + n - 1):2:(3 * n - 1)));
% 
% nQ = length(Q);
% switch lower(pass)
%    case 'stop'
%       Sg = 1 / prod(-Q);
%       c  = -V(1) * V(2);
%       b  = (V(2) - V(1)) * 0.5 ./ Q;
%       d  = sqrt(b .* b + c);
%       Sp = [b + d, b - d];
%       Sz = sqrt(c) * (-1) .^ (0:2 * nQ - 1);
%    case 'bandpass'
%       Sg = (V(2) - V(1)) ^ nQ;
%       b  = (V(2) - V(1)) * 0.5 * Q;
%       d  = sqrt(b .* b - V(1) * V(2));
%       Sp = [b + d, b - d];
%       Sz = zeros(1, nQ);
%    case 'high'
%       Sg = 1 ./ prod(-Q);
%       Sp = V ./ Q;
%       Sz = zeros(1, nQ);
%    case 'low'
%       Sg = V ^ nQ;
%       Sp = V * Q;
%       Sz = [];
%    otherwise
%       error('user:myButter:badFilter', 'Unknown filter type: %s', pass)
% end
% 
% % Bilinear transform:
% P = (1 + Sp) ./ (1 - Sp);
% Z = repmat(-1, size(P));
% if isempty(Sz)
%    G = real(Sg / prod(1 - Sp));
% else
%    G = real(Sg * prod(1 - Sz) / prod(1 - Sp));
%    Z(1:length(Sz)) = (1 + Sz) ./ (1 - Sz);
% end
% 
% % From Zeros, Poles and Gain to B (numerator) and A (denominator):
% if nargout == 2
%    Z = G * real(poly(Z'));
%    P = real(poly(P));
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % from: https://www.dsprelated.com/showarticle/1119.php
% % butter_synth.m    12/9/17 Neil Robertson
% % Find the coefficients of an IIR butterworth lowpass filter 
% % using bilinear transform
% %
% % N= filter order
% % fc= -3 dB frequency in Hz
% % fs= sample frequency in Hz
% % b = numerator coefficients of digital filter
% % a = denominator coefficients of digital filter
% %
% function [b,a]= butter_synth(N,fc,fs);
% %
% if fc>=fs/2;
%    error('fc must be less than fs/2')
% end
% % I.  Find poles of analog filter
% k= 1:N;
% theta= (2*k -1)*pi/(2*N);
% pa= -sin(theta) + j*cos(theta);     % poles of filter with cutoff = 1 rad/s
% %
% % II.  scale poles in frequency
% Fc= fs/pi * tan(pi*fc/fs);          % continuous pre-warped frequency
% pa= pa*2*pi*Fc;                     % scale poles by 2*pi*Fc
% %
% % III.  Find coeffs of digital filter
% % poles and zeros in the z plane
% p= (1 + pa/(2*fs))./(1 - pa/(2*fs));      % poles by bilinear transform
% q= -ones(1,N);                   % zeros
% %
% % convert poles and zeros to polynomial coeffs
% a= poly(p);                   % convert poles to polynomial coeffs a
% a= real(a);
% b= poly(q);                   % convert zeros to polynomial coeffs b
% K= sum(a)/sum(b);             % amplitude scale factor
% b= K*b;
