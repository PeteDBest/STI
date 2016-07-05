function out = DBLMultiAdd(varargin);
%function out = DBLMultiAdd(outFile, inFile1, inFile2, ...);
% mixes multiple double sound files down to a single track
%
% where:
% out        = boolean indicating success of operation
%
% outFile    = name of resulting file
% InFile1..n = names of files to mix down
frm      = 4096;                           % length of frames read
[x, Nvar] = size(varargin);
outFile  = varargin{1};                    % name of output file
fpoint   = zeros(Nvar,1);                  % initialize file pointer vector
mat      = zeros(Nvar,frm);                % matrix with input signals
len      = zeros(Nvar,1);                  % vector lengths of input signals
len(1)   = frm;                            % dummy output file

fpoint(1)= fopen(outFile,'w');             % open output file
for CurFil = [2:Nvar],                     % each input file
 fpoint(CurFil) = fopen(varargin{1,CurFil},'r'); % open input file
end

if length(find(fpoint<= 0))>= 1,           % at least one file failed
  out = 0;
else                                       % all files succesfully opened
 while ~MyFeof(fpoint),

  for CurFil = [2:Nvar],                   % each input file
   [sig, leng] =                       ...  % get slice of input signal
          fread(fpoint(CurFil),       ...    
                         frm,         ...
                         'double');
    mat(CurFil,1:leng) = sig;
    len(CurFil)        = leng;

  end
  olen = min(len);                         % length of output fragment
  osig = sum(mat(:,[1:olen]));             % add channels to output fragment
  fwrite(fpoint(1),                   ...  % write signal to stream
         osig,                        ...
         'double');

 end
 for CurFil = [1:Nvar],
  fclose(fpoint(CurFil));
 end
 out = 1;
end;

function a = MyFeof(fpoint);
a = 0;
for CurFil = [2:length(fpoint)],
  a = a + feof(fpoint(CurFil));
end;
if a > 0, a = 1; end;
% By Pete D. Best 03/27/09