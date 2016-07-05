function out = DBLAmpMod(modul, carrier, combined);
%function out = DBLAmpMod(modul, carrier, combined);
% applies  amplitude modulation
%
% where:
% out        = boolean indicating success of operation
%
% modul      = filename of modulating signal
% carrier    = filename of carrier signal
% combined   = filename of combined signal

fin1    = fopen(modul,   'r');          % open input file 1
fin2    = fopen(carrier, 'r');          % open input file 2
fout    = fopen(combined,'w');          % open output file
frm     = 4096;

if (fin1 > 0 && fin2 > 0 && fout > 0)   % only after succesful opening
while (~feof(fin1) && ~feof(fin2))
  [signal1, len1] = fread(fin1,    ...  % get slice of input signal
                          frm,     ...
                         'double');

  [signal2, len2] = fread(fin2,    ...  % get slice of input signal
                          frm,     ...
                         'double');
  leno = min([len1; len2]);             
 fwrite(fout,                      ...  % write modulated signal to file
       signal1(1:leno).*           ...
       signal2(1:leno),            ...
       'double');     
end
fclose(fout);
fclose(fin2);
fclose(fin1);
out    = 1;
else
 out    = 0;
end;
% By Pete D. Best 03/26/09
