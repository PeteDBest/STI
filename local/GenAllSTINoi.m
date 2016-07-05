%GenAllSTINoi.m
% generates 28 test signals for full sti measurement
STIsig.fs     = 44100;            % sampling rate                     [Hz]  
STIsig.dur    = 90;               % duration of test signal            [s]
STIsig.fc     = 125.*2.^[0:6];    % centre frequencies of audio bands A.2.1
STIsig.bandwidth = 0.5;           % half octave band widths
STIsig.type   = 'STI';            % type of noise
STIsig.sex    = 'm';              % sex of speaker
STIsig.carrier= 'nois';           % generate STI signal with noise carrier
STIsig.fnam   = 'STInoi%02d.dbl'; % template for filename of sti test signals
STIsig.path   = '.\signals\';     % path to STI test signals
if ~exist(STIsig.path,'dir'), mkdir('.\signals'); end

fmod        = 0.63.*          ... % modulation frequencies            A.2.1
              2.^([0:13]./3);
Latin       = LatinSquare(14);
ModPerChan  = [Latin(:, 1:7); ... % matrix with modulations per test signal
               Latin(:,8:14)];
STIsig.ModPerChan = ModPerChan;

[noTest,noBand] = size(ModPerChan);
for CurTest = [1:noTest],
 fprintf('Generating test signal #%d\n',CurTest); 
 STIsig.fmod = fmod(ModPerChan(CurTest,:)); % modulation frequencies in test signal
 FilNam = [STIsig.path, sprintf(STIsig.fnam, CurTest)];
 tic;GenDblSTINoi(FilNam,STIsig);toc;
end
% By Pete D. Best 09/05/18