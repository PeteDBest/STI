function [z]=Bandpass(col,cou,frm,fs);
% [z]=Bandpass(col,cou,frm,fs)
%
%   returns a Bandpass filter kernel with 
%
% col : cut-off lower frequency
% cou : cut-off upper frequency
% frm : length of filter kernel
% fs  : sampling rate

hfm=frm/2;

% High pass filter
%  frequency of each bin
x = fs/frm*(1:hfm);
x = floor(x./col);
x = ceil( x./max(x));

% Low pass filter
% frequency of each bin
y = fs/frm*(1:hfm);
y = floor(y./cou);
y = ones(size(y))- ceil( y./max(y));

% Band pass = highpas * lowpas
z = x .* y;

% mirror before inverse fourier
z=[z(1) z rot90(z(1:hfm-1))'];

% To time domain
z=real(ifft(z)); z=[z(hfm+2:frm) z(1:hfm+1)];

% Smoothen with hamming window;
z = z.* hamming(length(z))';

% Pete D. Best 02/02/26