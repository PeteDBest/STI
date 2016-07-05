function DBLattn(OutFile, InFile, attn);
%function DBLattn(OutFile, InFile, attn);
% attenuates a DBL file 
% where:
%  out     = boolean indicating succes of operation
%
%  InFile  = name of input file
%  OutFile = name of output file
%  attn    = level change                            [dB]

frm     = 4096;

fin  = fopen(InFile, 'r');              % open input file
fout = fopen(OutFile,'w');              % open output file

if (fin > 0 && fout > 0),               % only after succesful opening

 while ~feof(fin),                       % as long as EOF not reached
  [signal, len] = fread(fin,       ...  % get slice of input signal
                        frm,       ...
                        'double');
  signal = dB2amp(signal,attn);         % adjust volume
  fwrite(fout, signal, 'double');       % write first half of signal
 end;
 fclose(fout);                          % close output file
 fclose(fin);                           % close input file
 out = 1;                               % succes

else
 out = 0;                               % failed to open files
end
