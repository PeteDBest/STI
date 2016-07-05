function out = DBLSTIMod(file, fmod, dur, attn, fs)
%function out = DBLSTIMod(file, fmod, dur, attn, fs)
% generates an sinusoidal intensity modulator signal
%
% where:
%  out  = boolean succes of operation
%
%  file = name of ouput file
%  fmod = modulation rate                                 [Hz]
%  dur  = duration of the signal                           [s]
%  attn = attenuation factor                              [dB]
%  fs   = sampling rate                                   [Hz]
Slice   = 4096;                      % size of slize
noSamp  = ceil(dur*fs);              % number of samples needed
noSlice = floor(noSamp/Slice);       % # of slices
tail    = rem(noSamp, Slice);        % samples in last slice
offTim  = 0;                         % time offset
sliTim  = Slice/fs;                  % time of slice
SliceT  = [1:Slice]./fs;             % time within slice;

fout    = fopen(file,'w');           % open output file
if (fout > 0),                       % only after succesful opening

for curSlice = 1:noSlice,            % for each slice
 Env    = sqrt(1+ cos(2.*pi   .* ... % intensity envelope
                      fmod    .* ...
                      (SliceT+offTim))); 
 if attn ~= 0,Env = dB2amp(Env, attn); end; % adjust volume
 fwrite(fout, Env,               ... % write noise slice to file 
        'double');      
 offTim = offTim + sliTim;           % update time offset
end
Env     = sqrt(1+ cos(2*pi    .* ... % intensity envelope 
                      fmod    .* ...
                      (SliceT+offTim))); 
if attn ~= 0,Env = dB2amp(Env, attn); end; % adjust volume
fwrite(fout,              ...        % write last noise slice to file
       Env(1:tail),       ...
       'double');     
fclose(fout);
out    = 1;
else
out    = 0;
end;
% By Pete D. Best 03/26/09
