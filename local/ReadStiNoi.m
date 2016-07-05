function signal = ReadStiNoi(sex, len, srce, freeze);
%function signal = ReadStiNoi(sex, len, srce, freeze);
% reads fragment of STI noise
%
% where:
%  signal  = vector containing the STI signal
% 
%  sex     = sex of talker                         {'M': male, 'F': female}
%  len     = # of samples to read
%  srce    = # of STI test signal                                   [1..14]
%  freeze  = freeze speech                      [0: random sample (default)
%                                                1: fixed sample];
if nargin < 5,         % defaul for freeze
  freeze = 0;
end

switch upper(sex)
 case {'M'}
   DirPath  = 'H:\sounds\STI\ISO60268\Male\';
   FileName = sprintf('STInoi%02d.dbl', srce);

   numsamp  = 84672512;             % # of bytes in noise file;

   nmax    = fix(numsamp/8 - len);  % eight bytes per sample
   enam    = [DirPath,FileName];

   NumSamp = 0;

   fid=fopen(enam);
   if (fid>0)
     if ~freeze, fseek(fid,fix(nmax*rand(1))*8,'bof'); end; 
     [signal NumSamp]=fread(fid,len,'double');
     fclose(fid);
   end

   if (NumSamp ~= len)
     fprintf('Error in ==> ReadStiNoi\n  reading file: %s\n', enam);
     signal  = 0;
   end;  
  otherwise
     fprintf('Error in ==> ReadStiNoi\n female speech not implemented\n');
end;
% By Pete D. Best 04/11/09