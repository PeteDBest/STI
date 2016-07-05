%testSTI.m

SNRs   = [-20: 1: 20];                     % levels to calculate STI
STIval = -0.05*ones(length(SNRs), 2);      % initialize result matrix

for CurTest = [1:length(SNRs)],            % for each SNR
% for CurTest = [21],                        % for each SNR
 fprintf('Currently processing test # %d\n', CurTest); 
 DBLattn('.\signals\temp.dbl',        ...  % place interfering noise at SNR
         '.\signals\STIltass.dbl',    ...
         -SNRs(CurTest));

for CurSti = [1:28],                       % for each testsignal
 InFile1 = ['H:\sounds\STI\ISO60268\Male\', ...
            sprintf('STInoi%02d.dbl', CurSti)];  % template for filename of sti test signals
%  InFile1 = '.\signals\STIltass.dbl';
 InFile2 = '.\signals\temp.dbl';
 OutFile = ['.\signals\',                   ... 
            sprintf('STInoi%02d.dbl', CurSti)];  % template for filename of sti test signals
 DBLMultiAdd(OutFile, InFile1, InFile2);         % mix test signals
end;
[a,b]=GetSTI('.\signals\', 75);             % calculate STI
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