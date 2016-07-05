function out=GenDBLWhite(file, t, fs)
% function out=GenDBLWhite(file, t, fs)
%
%  generates white noise within -1<= wnoise<=1 limits and stores it in dbl
%  format on disk
%
% where
%  out  = succes of operation
%
%  file = name of output file
%  t    = duration of signal
%  fs   = sample frequency of signal;
%
Slice   = 4096;                      % size of slize
noSamp  = ceil(t*fs);                % number of samples needed
noSlice = floor(noSamp/Slice);       % # of slices
tail    = rem(noSamp, Slice);        % samples in last slice
ovsamp  = ceil(1.01*Slice);          % create 1 % overshoot

fout    = fopen(file,'w');           % open output file
if (fout > 0),                        % only after succesful opening

for curSlice = 1:noSlice,            % for each slice
 fwrite(fout,                    ... % write noise slice to file 
        GenSlice(Slice, ovsamp), ...
        'double');      
end
wnoise = GenSlice(Slice, ovsamp);    % get last noise slice
fwrite(fout,              ...        % write last noise slice to file
       wnoise(1:tail),    ...
       'double');     
fclose(fout);
out    = 1;
else
out    = 0;
end;

function wnoise = GenSlice(Slice , ovsamp)
wnoise = randn([1, ovsamp]);        % standard-normally distributed random numbers
dlsamp = find(abs(wnoise >= 5));    % samples more than 5 std from mean;
wnoise(dlsamp) =[];                 % remove outliers
wnoise = wnoise(1:Slice);           % trim to desired length
wnoise = wnoise./5;                 % normalise noise to <-1..1>;


%By Pete D. Best 09/03/26