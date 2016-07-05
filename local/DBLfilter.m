function out = DBLfilter(InFile, OutFile, ImpResp);
%function out = DBLfilter(InFile, OutFile, ImpResp);
% passes a filter on an audiofile in DBL format and saves the resulting
% file to disk, whitout placing the complete inputfile into memory
%
% where:
%  out     = boolean indicating succes of operation
%
%  InFile  = name of input file
%  OutFile = name of output file
%  ImpResp = impulse response of filter to apply

frm     = length(ImpResp);
OvrLp   = zeros(1,frm-1);                 % initialise overlapping part

fin  = fopen(InFile, 'r');              % open input file
fout = fopen(OutFile,'w');              % open output file

if (fin > 0 && fout > 0),               % only after succesful opening

 while ~feof(fin),                       % as long as EOF not reached
  [signal, len] = fread(fin,       ...  % get slice of input signal
                        frm,       ...
                        'double');
  signal = signal';                     % horizontal time!!!
  if len < frm,                         % if slice is shorter than expected
   signal = [signal, zeros(1,frm-len)]; % zeropad to slice length
  end
  signal = conv(signal,ImpResp);        % convolute slice with filter
  signal(1:frm-1) = signal(1:frm-1) + ...
                    OvrLp;              % add overlap to first half of signal
  fwrite(fout, signal(1:frm), 'double');% write first half of signal
  OvrLp  = signal(frm+1:end);           % store second half in overlap
 end;
 fclose(fout);                          % close output file
 fclose(fin);                           % close input file
 out = 1;                               % succes
% By Pete D. Best 03/17/09
else
 out = 0;                               % failed to open files
end
