function out = GenDblSTINoi(FileName, STIsig)
%function out = GenDblSTINoi(FileName, STIsig)
%generates a STI test signal in double precision format
%
%where:
% out        = boolean indicating success of operation
%
% FileName   = file name of output file
% STIsig     = structure with test signal parameters
% .fs        = sampling rate                                           [Hz]
% .dur       = duration of test signal                                  [s]
% .fc        = center frequencies of audio bands                       [Hz]
% .fmod      = modulation frequencies per audio band                   [Hz]
% .bandwidth = bandwidth of audio bands                               [oct]
% .type      = LTASS noise           {'STI' : as in ISO60268-16:2003
%                                     'IEEE': IEEE sentence noise (UCL)
%                                     'SII' : ansi SII LTASS}
% .sex       = sex of noise          {'m'   : male,
%                                     'f'   : female}
% .carrier   = carrier of STI signal {'sine': sine-wave carriers
%                                     'nois': noise carriers
switch lower(STIsig.carrier)
 case {'nois'}
  frm     = 4096;                                 % filter size
  GenDBLWhite('.\signals\WhiteNoi.dbl', ...       % generate white noise
            STIsig.dur,               ...
            STIsig.fs);  

  if      sum( STIsig.fc == 125.*2.^[0:6]) ~= 7;  % prescribed octave bands
   fprintf('Error in GenDblSTINoi: standard STI requires 7 octave bands\n');
%   elseif  STIsig.bandwidth ~= .5,                 % prescribed bandwidth
%    fprintf('Error in GenDblSTINoi: standard STI requires 0.5 octave band widths\n');
  else
  BandFiles   = cell(1,length(STIsig.fc));        % allocate temp file names
  switch upper(STIsig.type)
   case {'STI'}
    Lev         = GetStiOctSpeLev(STIsig.sex);    % get band levels
    Lev         = Lev -3.*[1:length(STIsig.fc)];  % correct 3dB white noise tilt
    Lev         = Lev + 8;                        % use full <-1..1> range
   case {'IEEE'}
     bandwidth  = STIsig.bandwidth;               % levels per band
     if STIsig.bandwidth == 0.5,
      bandwidth = 1;                              % compensate band reduction
     end;
     Lev        = GetIEEEBandLev(STIsig.sex,  ... % get band levels
                                 bandwidth);
     Lev        = Lev -3.*[1:length(STIsig.fc)];  % correct 3dB white noise tilt
     Lev        = Lev + 51;
  end;
  if STIsig.bandwidth == 1,
    Lev       = Lev - 3;                          % correct 3 dB due to octave bandwidth
  end
  for CurBand = [1:7],
    if STIsig.fmod(CurBand) == 0,                 % generating steady-state noise
     Lev(CurBand) = Lev(CurBand) - 3;             % undo energy correction of DBLSTIMod
    end;
    DBLSTIMod('.\signals\Modulation.dbl', ...     % generate modulating signal
              STIsig.fmod(CurBand),       ...
              STIsig.dur,                 ...
              Lev(CurBand),               ...     % attenuation [dB]
              STIsig.fs);
    DBLAmpMod('.\signals\Modulation.dbl', ...     % modulate signal with envelope
              '.\signals\WhiteNoi.dbl',   ...
              '.\signals\Modulated.dbl');
              
    BandFiles{1,CurBand} =                 ...    % name of outfile
       sprintf('.\\signals\\band%02d.dbl', ...
               CurBand);  
    BandFilt = Bandpass(STIsig.fc(CurBand)*2^-(STIsig.bandwidth/2), ...
                        STIsig.fc(CurBand)*2^(STIsig.bandwidth/2),  ...
                        frm,                                        ...
                        STIsig.fs);               % create bandpass filter
    DBLfilter('.\signals\Modulated.dbl',  ...     % filter signal to bandwidth
              BandFiles{1,CurBand},       ...
              BandFilt);  

  end
  DBLMultiAdd(FileName,        ...                %  sum bands
              BandFiles{1,1},  ...
              BandFiles{1,2},  ...
              BandFiles{1,3},  ...
              BandFiles{1,4},  ...
              BandFiles{1,5},  ...
              BandFiles{1,6},  ...
              BandFiles{1,7});
 end
 case {'sine'}
  frm       = 4096;                           % lenght of signal slice
  out       = 1;                              % initialize boolean
  noBand    = length(STIsig.fc);              % # of audiobands in signal 
    switch upper(STIsig.type)
   case {'STI'}
    Lev         = GetStiOctSpeLev(STIsig.sex);    % get band levels
    Lev         = Lev + 8;                        % use full <-1..1> range
   case {'IEEE'}
     bandwidth  = STIsig.bandwidth;               % levels per band
     if STIsig.bandwidth == 0.5,
      bandwidth = 1;                              % compensate band reduction
     end;
     Lev        = GetIEEEBandLev(STIsig.sex,  ... % get band levels
                                 bandwidth);
     Lev        = Lev + 12.8;
  end;

  CurLen    = 0;                              % initialize sample counter
  SigLen    = ceil(STIsig.fs*STIsig.dur);     % total length of output signal
  ModPhase  = rand(1,noBand);                 % start phase modulators random
  CarPhase  = rand(1,noBand);                 % start phase carriers random
  ModDPhase = (frm/STIsig.fs).*          ...  % modulator phase shift per slice
              STIsig.fmod;          
  ModDPhase = rem(ModDPhase, 1);              % stay within [0..1> range
  CarDPhase = (frm/STIsig.fs).*          ...  % carrier phase shift per slice
              STIsig.fc;       
  CarDPhase = rem(CarDPhase, 1);              % stay within [0..1> range 

  while (CurLen < SigLen) & out,              % until required length reached

  for CurBand = [1:noBand]                    % for each channel
   carrier.freq    = STIsig.fc(CurBand);
   carrier.phase   = CarPhase(CurBand);
   modulator.freq  = STIsig.fmod(CurBand);
   modulator.phase = ModPhase(CurBand);

   BandSig   = GenSinModSinSlc(carrier,   ... % generate fragment of signal
                               modulator, ...
                               frm,       ...
                               STIsig.fs);
   CarPhase(CurBand) = CarPhase(CurBand) +... % update carrier phase
                       CarDPhase(CurBand);
   ModPhase(CurBand) = ModPhase(CurBand) +... % update modulator phase
                       ModDPhase(CurBand);

   if CurBand == 1,
     FullSig = dB2amp(BandSig,            ... % new combined slice
                      Lev(CurBand));
   else
     FullSig = FullSig              +     ... % add to combined slice
               dB2amp(BandSig,            ... 
                      Lev(CurBand));
   end
 end
 CurLen = CurLen + frm;                       % update sample counter
 if CurLen > SigLen,                          % last slice too long
  sto = frm - (CurLen -SigLen);               % length for last slice
  FullSig = FullSig(1:sto);                   % truncate last slice 
 end

 out = DBLAppend(FullSig, FileName);          % write signal to file
 end;                                         % terminate while loop
end
% By Pete D. Best 05/04/09