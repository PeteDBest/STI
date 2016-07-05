function attn = dBAweights(freq);
% function attn = dBAweights(f)
% returns the frequency dependent attenuation needed to transfor a 
% dB SPL value to a dB(A) value (transformation values obtained from 
% manual of Ono Sokki CF-350/360)
%
% where:
%  attn = attenuation factor from SPL to dB(A)                        [dB]
%
%  freq = frequency                                                   [Hz]
m    = load('A weights.txt');      % get conversion table
attn = spline(m(:,1),m(:,2),freq); % spline interpolation
