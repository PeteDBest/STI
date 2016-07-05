function Lm = USOM(Lb)
%function Lm = USOM(Lb);
% determines noise levels in adjacent  audio bands due to upward spread of 
% masking (USOM) per bandwidth as part of STI
%
% where:
%  Lm = masking noise level due to USOM per octave band [dB SPL]
%
%  Lb = noise level per octave band                     [dB SPL]
slopes = [-100, -40,-35,-25,-20, -15, -10];

Lt         = Lb;                      % copy band levels
SelInd     = find(Lb < 36);
Lt(SelInd) = 36;                      % restrict to values above 46 dB SPL
SelInd     = find(Lb > 96);
Lt(SelInd) = 96;                      % restrict to values below 96 dB SPL
bin        = floor((Lt-36)./10) + 1;  % bin # of slopes
bslopes    = slopes(bin);             % masking slopes per bin
Lm         = Lb +                ...  % USOM masking noise per band
             [-100, bslopes(1:end-1)];
% By Pete D. Best 23/03/09