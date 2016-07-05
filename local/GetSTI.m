function [STIval1, STIval2] = GetSTI(FilPath, Lev);
%function [STIval1, STIval2] = GetSTI(FilPath, Lev);
% determines the Speech Transmission Index according to EN 60268-16:2003
% from two complete sets of STI signals
% 
% where:
%  STIval1  = STI value estimated form first set of test signals
%  STIval2  = STI value estimated form second set of test signals
%
%  FilPath  = path to directory with STI signals
%             (files should have STInoiXX.dbl names)
%  Lev      = level of STI signals                                [dB (A)]
STIsig.fs   = 44100;              % sampling rate                     [Hz]  
STIsig.fc   = 125.*2.^[0:6];      % centre frequencies of audio bands A.2.1
STIsig.bandwidth = 1;             % full octave band widths
STIsig.type = 'IEEE';             % type of noise
STIsig.sex  = 'm';                % sex of speaker
STIsig.fnam = 'STInoi%02d.dbl';   % template for filename of sti test signals
STIsig.path = FilPath;            % path to STI test signals
STIsig.fmod = 0.63.*          ...              % modulation frequencies
              2.^([0:13]./3);
%STIsig.carrier = 'nois';

Latin         = LatinSquare(14);
ModPerChan    = [Latin(:, 1:7);       ... % matrix indicating modulations 
                 Latin(:,8:14)];          %  per test signal
[noro, noco] = size(ModPerChan); 
ModMat       = -999.*ones(noro, noco);    % predefine modualtion matrix
LMat         = -999.*ones(noro, noco);    % predefine level matrix
for CurTestSig = [1:noro],              % for each test signal

FilNam  = [STIsig.path,             ... %  create file name test signal
           sprintf(STIsig.fnam, CurTestSig)];

for CurAudBand = [1:noco],              % for each audio band
 fmod = STIsig.fmod(                ... % get current modulation signal
         ModPerChan(CurTestSig,CurAudBand));
 
 [M, L] = GetMTF(FilNam,                   ... % determine modulation index
                 STIsig.fc(CurAudBand),    ...
                 fmod,                     ...
                 STIsig.fs); 
 
 ModMat(CurTestSig, CurAudBand) = M;    % fill modulation index at position in matrix
 LMat(CurTestSig, CurAudBand)   = L;    % fill level at position in matrix

end
end
STIval1 = -1;
STIval2 = -1;
switch upper(STIsig.type)
  case {'STI'};
   LMat    = LMat + 36;                   % place test signal @ 0 dB (A) (TO BE CONFIRMED for female speech) 
  case {'IEEE'};
   LMat    = LMat + 21.5;                 % place test signal @ 0 dB SPL
end
LMat    = LMat + Lev;                     % place test signal @ measured level
ModMat1 = ReOrderMat(ModMat(1:14,:), ...  % split matrix in two subsets
                     ModPerChan(1:14,:));
ModMat2 = ReOrderMat(ModMat(15:28,:),...  % split matrix in two subsets
                     ModPerChan(15:28,:));

LMat1   = ReOrderMat(LMat(1:14,:),   ...  % split matrix in two subsets
                     ModPerChan(1:14,:));
LMat2   = ReOrderMat(LMat(15:28,:),...    % split matrix in two subsets
                     ModPerChan(15:28,:));
STIval1  = CalcSTI(ModMat1', mean(LMat1), 'm'); % calculate STvalue
STIval2  = CalcSTI(ModMat2', mean(LMat2), 'm'); % calculate STvalue
% By Pete D. Best 05/19/09