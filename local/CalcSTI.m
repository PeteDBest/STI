function STI = CalcSTI(ModSpec, Lband, sex)
%function STI = CalcSTI(ModSpec, Lband, sex)
% calculates the Speech Transmission Index (as in ISO 60268-16;2003) based
% on a measured modulation spectogram and octave band levels
%
% where:
%  STI     = speech transmission index                               [0..1]
%
%  ModSpec = matrix with modulation indices with                     [0..1]
%            7 rows representing octave audio bands
%            14 columns representing 1/3-octave modulation bands
%  Lband   = RMS noise levels per octave band                      [dB SPL]
%  Sex     = sex of LTASS                          {'m': male, 'f': female}
fc   = 125.*2.^[0:6];      % centre frequencies of audio bands A.2.1
fmod = 0.63.*2.^[0:13];    % modulation frequencies            A.2.1

NumAudBand = length(fc);              % # of audio bands
NumModBand = length (fmod);           % # of modulation bands
Madj       = -99.*ones(NumAudBand, ...% initialize corrected M indices
                       NumModBand);

Ik   = 10.^(Lband/10);                % intensities per band
Iam  = 10.^(USOM(Lband)./10);         % calculate USOM intensities  A.2.3
Irs  = 10.^(HearThres('STI')./10);    % calculate hearing thresholds
for CurAudBand = 1:NumAudBand,
  Madj(CurAudBand,:) = ModSpec(CurAudBand,:).* ... % correct indices
                       Ik(CurAudBand)    ./    ... % (p.20)
                       (Ik(CurAudBand)  +      ...
                        Iam(CurAudBand) +      ...
                        Irs(CurAudBand)   );
end;
SNR  = 10.*log10(Madj./(1-Madj));     % transform to effective SNRs
hold off;
plot([1:7], Lband,            '-k');  % plot speech levels
hold on;
plot([1:7], USOM(Lband),     '--k');  % plot USOM levels
plot([1:7], HearThres('STI'), ':k');  % plot hearing thresholds
for CurModBand = [1:NumModBand],
 plot([1:7],                     ...  % plot equivalent noise levels
      Lband-SNR(:,CurModBand)',  ...
      '-.k'); 
end
set(gca, 'ylim', [0,100]);

TI   = (SNR + 15)./ 30;               % limit to proportion within [-15..15]
                                      % dB range {transmission indices}
for CurAudBand = 1:NumAudBand,
  SelInd = find(TI(CurAudBand,:) < 0);
  TI(CurAudBand,SelInd) = 0;
  SelInd = find(TI(CurAudBand,:) > 1);
  TI(CurAudBand,SelInd) = 1;
end;
MTI = mean(TI,2)';                    % average transmission indices per audioband (p.21)
[alfa, beta] = STISex(sex, 'STI');    % get spectral weights
STI = sum(alfa.*MTI) -            ... % STI is weighted sum of transmission indices
      sum(beta.*sqrt(MTI.*[MTI(2:end), 0])); %  minus redundancy correction (p.21)
% By Pete D. Best 05/04/09