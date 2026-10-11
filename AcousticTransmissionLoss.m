function TL_dB = AcousticTransmissionLoss(d_m,f_kHz,k)
% =========================================================================
% Underwater acoustic transmission loss:
%
% TL = 10*k*log10(d) + alpha(f)*d/1000
%
% alpha(f) uses the Thorp approximation in dB/km.
% =========================================================================

d = max(d_m,1);

f = max(f_kHz,1e-6);

alpha = ...
      0.11*f.^2./(1+f.^2) ...
    + 44*f.^2./(4100+f.^2) ...
    + 2.75e-4*f.^2 ...
    + 0.003;

TL_dB = ...
    10*k*log10(d) ...
    + alpha.*d/1000;

end
