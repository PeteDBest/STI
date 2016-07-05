function [Lev, freq] = GetStiOctSpeLev(sex);
%function [Lev, freq] = GetStiOctSpeLev(sex);
% returns the speech levels per octave band as defined in the STI-standard 
% (IEC 60268) but expressed in dB SPL values
%
% where:
%  Lev  = level in octave band                                     [dB SPL]
%  freq = center frequency of octave band                              [Hz]
%
%  sex  = sex of speaker                           {'m': male; 'f': female}
freq    = 125.*2.^[0:6];                       % octave band frequencies
% dBA2SPL = -dBAweights(freq')';                 % dBa to SPL conversion
switch lower(sex),
 case {'m'}                                    % table A.3
  attn = [  2.9, 2.9, -0.8, -8.6, -12.8, -18.8, -24.8];
 case {'f'}
  attn = [ -inf, 5.3, -1.9, -9.1, -15.8, -16.7, -18.0]; 
end;
Lev = attn; % + dBA2SPL;                          % express in SPL value
% By Pete D. Best 04/29/09
% 06/01/09: removed dB(A) conversion since values in Table a.3 appear 
% to be expressed in [dB SPL/ oct]