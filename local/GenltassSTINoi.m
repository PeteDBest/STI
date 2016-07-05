%GenltassSTINoi.m
% generates noise with the long term average spectrum of speech as proposed
% in EN 60268-16:2003
STIsig.fs     = 44100;            % sampling rate                     [Hz]  
STIsig.dur    = 90;               % duration of test signal            [s]
STIsig.fc     = 125.*2.^[0:6];    % centre frequencies of audio bands A.2.1
STIsig.bandwidth = 1;             % half octave band widths
STIsig.type   = 'STI';           % type of noise
STIsig.sex    = 'f';              % sex of speaker
STIsig.fnam   = 'STIltass.dbl';   % template for filename of ltass sti noise
STIsig.path   = '.\signals\';     % path to STI test signals
STIsig.fmod   = zeros(7,1);       % modulation frequencies     
STIsig.carrier='nois';            % noise carrier

FilNam = [STIsig.path, STIsig.fnam];
GenDblSTINoi(FilNam,STIsig);     
% By Pete D. Best 05/18/09
