%testSTI.m
% mixes LTASS at a range of SNRs to STI test signals and plots the effect of STI
% as function of level;
clear;

SNRs   = [-20: 1: 20];                     % levels to calculate STI
STIval = NaN(length(SNRs), 2);             % initialize result matrix

GenltassSTINoi;                            % create LTASS noise 
GenAllSTINoi;                              % create STI test signals

if ~exist('.\out\', 'dir'), mkdir('.\out\'); end;
for CurTest = [1:length(SNRs)],            % for each SNR
 fprintf('Currently processing test # %d\n', CurTest); 
 DBLattn('.\out\temp.dbl',            ...  % place interfering noise at SNR
         '.\signals\STIltass.dbl',    ...
         -SNRs(CurTest));

for CurSti = [1:28],                       % for each test signal
 InFile1 = ['.\signals\', ...
            sprintf('STInoi%02d.dbl', CurSti)];  % template for filename of sti test signals
 InFile2 = '.\out\temp.dbl';
 OutFile = ['.\out\',                   ... 
            sprintf('STInoi%02d.dbl', CurSti)];  % template for filename of sti test signals
 DBLMultiAdd(OutFile, InFile1, InFile2);         % mix test signals
end;
[a,b]=GetSTI('.\out\', 75);                % calculate STI
STIval(CurTest, 1) = a;
STIval(CurTest, 2) = b;
hold off;
plot(SNRs',STIval(:,1), '-k');
hold on;
plot(SNRs',STIval(:,2), ':k');
set(gca, 'ylim', [-0.1,1.1]);
set(gca, 'xlim', [-20,20]);
pause(0.1);
end;