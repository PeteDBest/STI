function [M, L] = GetMTF(FilNam, faud, fmod, fs)
%function [M, L] = GetMTF(FilNam, faud, fmod, fs)
% calculates the modulation index for a specific modulation frequency and
% audio band.
%
% where:
%  M      = modulation index
%  L      = level of audioband
%
%  FilNam = name of audiofile
%  faud   = center frequency of audio band                            [Hz]
%  fmod   = modulation frequency                                      [Hz]
%  fs     = sampling rate                                             [Hz]
bandw     = 1;                          % bandwidth of audioband     [oct]
SigFrm    = 2^13;                       % length of signal frame
AudFilTyp = 'iir';
EnvFilTyp = 'iir';
switch lower(AudFilTyp)
 case {'fir'}
AudFrm    = 4096;                       % length of audio filter
ImpResp   = Bandpass(faud*2^-(bandw/2), ...
                     faud*2^(bandw/2),  ...
                     AudFrm,               ...
                     fs);               % create bandpass filter
AudOvrLp  = zeros(1,AudFrm-1);          % initialise overlapping part in audio domain
 case {'iir'}
  fNiq  = fs/2;                         % Niquist frequency
  Wp    =[faud*2^-(bandw/2), ...        % limits of pass band
          faud*2^(bandw/2)];
  Ws    =[faud*2^-bandw,     ...        % limits of stop band
          faud*2^bandw];
  Rp    = 10;                           % ripple in pass band 
  Rs    = 30;                           % attenuation in stopband

% [n, Wn] = buttord(Wp./fNiq,  ... % get order of filter
%                   Ws./fNiq,  ...
%                   Rp,        ...
%                   Rs);
% [b,a]  = butter(n, Wn);          % get filter coefficients
[n, Wn] = cheb1ord(Wp./fNiq,  ...      % get order of filter
                   Ws./fNiq,  ...
                   Rp,        ...
                   Rs);
[b,a]  = cheby1(n,Rp,Wn);          % get filter coefficients
olap   = zeros(max([length(a), length(b)])-1,1);
end

switch lower(EnvFilTyp)
  case {'fir'}
   EnvFrm    = 1024;                       % length of envelope filter
%   EnvFrm    = 32;                         % length of envelope filter
   EnvOvrLp  = zeros(1,EnvFrm -1);         % initialise overlapping part in envelope domain
   MovAvg    = ones(1,EnvFrm)./EnvFrm;     % moving average filter;
  case {'iir'}
%   fNiq  = fs/2;                         % Niquist frequency
%   Wp    = fmod*1.1;                     % pass fequency
%   Ws    = fmod*2.2;                     % stop frequency
%   Rp    = 10;                           % ripple in pass band 
%   Rs    = 5;                            % attenuation in stopband
%   [n, Wn] = cheb1ord(Wp./fNiq,  ...     % get order of filter
%                      Ws./fNiq,  ...
%                      Rp,        ...
%                      Rs);
%  [d,c]  = cheby1(n,Rp,Wn);              % get filter coefficients
EnvFilt = LowpassIIR(60.11*fmod, 1, fs);   % get filter coefficients
plap    = zeros(max([length(EnvFilt.b), length(EnvFilt.a)])-1,1);

end

CurTim    = 0;                          % initialize time at begin of slice   
SigTim    = [1:SigFrm]./fs;             % relative time in frame
NumSlice  = 0;                          % slice counter;
malfa     = 0;                          % initialize mean real AC component
mbeta     = 0;                          % initialize mean imaginary AC component
mgamma    = 0;                          % initialize mean DC component
noZero    = 0;                          % initialize info on zeropadding 
mbandene  = 0;                          % initialize mean band energy

fin  = fopen(FilNam, 'r');              % open input file

if (fin > 0),                           % only after succesful opening

while ~feof(fin),                      % as long as EOF not reached

  [signal, len] = fread(fin,       ...  % get slice of input signal
                        SigFrm,    ...
                        'double');
  signal = signal';                     % horizontal time!!!
  if len == 0;                          % slice fitted exactely in file
   break;                               % dirty trick to exit while loop
  elseif len < SigFrm,                  % if slice is shorter than expected
    noZero = SigFrm - len;              % # of zeros to pad
    signal = [signal,              ...  % zeropad to slice length
              zeros(1,noZero)]; 
  
  end

switch lower(AudFilTyp)
 case {'fir'}
  signal   = conv(signal,ImpResp);      % convolute slice with filter
  signal(1:AudFrm-1) =             ...  % add overlap to first half of signal
      signal(1:AudFrm-1) + AudOvrLp;
  AudOvrLp = signal(SigFrm+1:end);      % store second half in overlap
 case {'iir'}
  [temp, olap] =                  ...
      filter(b, a, signal', olap);
  signal = temp';                       % horizontal time
end  

%  bandsig = abs(hilbert(signal(1:SigFrm)'))'.^2; % get raw envelope
  bandsig = signal(1:SigFrm).^2;        % get raw envelope 
  bandene = mean(bandsig(1:len));       % energy in band slice
switch lower(EnvFilTyp)
  case {'fir'}
  bandsig = conv(bandsig, MovAvg);      % apply moving average filter
  bandsig(1:EnvFrm-1) = bandsig(1:EnvFrm-1) + ... % add overlap
                        EnvOvrLp;
 
  EnvOvrLp = bandsig(SigFrm+1:end);     % update overlap
  envelope = bandsig(1:SigFrm);         % smooth envelope
 case {'iir'}
  [temp, plap] =                  ...
      filter(EnvFilt.b, EnvFilt.a, bandsig', plap);
  envelope = temp';                     % horizontal time
end  

  coscomp  = cos(2.*pi.*           ...  % get cosine component of fmod
                 fmod.*            ...
                 (CurTim+SigTim));
  sincomp  = sin(2.*pi.*           ...  % get sine component of fmod
                 fmod.*            ...
                 (CurTim+SigTim));
  CurTim   = CurTim + SigFrm/fs;        % update time cursor
  alfa     = mean(envelope.*coscomp);   % real part of modulation
  beta     = mean(envelope.*sincomp);   % imaginary part of modulation
  gamma    = mean(envelope);            % get DC component
  
  w        = 1 - 1/(NumSlice+1);        % weight for averaging
  malfa    = w*malfa  + (1-w)*alfa;
  mbeta    = w*mbeta  + (1-w)*beta;
  mgamma   = w*mgamma + (1-w)*gamma;

  mbandene = w*mbandene + (1-w)*bandene;% update RMS of signal
  NumSlice = NumSlice + 1;
 end
 M        = (2*sqrt(malfa^2 + mbeta^2))/mgamma; 
%  fprintf('Slice #: %d; M = %4.2f\n', ...
%           NumSlice, M);
 if M > 1, M = 1; end;
%  if M < 0, M = 0; end;
 L = 10*log10(mbandene);                % RMS in audioband
 fclose(fin);
else
 M = -1;
 L = 999;
end;
% By Pete D. Best 05/19/09