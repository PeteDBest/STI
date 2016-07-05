function S=LowpassIIR(fc, pole, fs);
%function S=LowpassIIR(fc, pole, fs);
% returns the coëffcients for a recursive lowpass filter (R-C model) as 
% defined in the DSP guide Chapter 19 (Smith, 1999).
%
% where:
%  S     = structure with filter coëffcients
%  .a    = coefficients to apply on filter output
%  .b    = coeffecients to apply on filter input
%
%  fc    = cutoff frequency (-3 dB point)                      [Hz]
%  pole  = number of filter poles (only pole = 1 implemented)
%  fs    = sampling rate                                       [Hz]
x = exp(-2*pi*fc/fs);   % eq 19.5

S.b = 1 - x;            % eq 19.6
S.a = [1, -x];
% By Pete D. Best 04/04/07