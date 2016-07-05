function M = LatinSquare(n);
% generates a digram-balanced Latin square as proposed by Wagenaar 1969
%
% where:
%  M   = digram-balanced Latin square
%
%  n   = nuber of row in latin square (must be even)
%
%------------------------------------------------------------------
% Berekent latin square, Finn D 6-5-2003 naar Drullman en Wagenaar
%------------------------------------------------------------------
%function M=latin_square_fun(n);

% clc
% n=input('..voer even aantal in >> ');

H1		=zeros(n,n);H2		=zeros(n,n);

for k=1:n-1
   for j=1:n-k
      if 2*round(k/2)~=k & 2*round(j/2)~=j;
         H1(k,j)=k+j-1;
      elseif 2*round(k/2)==k & 2*round(j/2)==j
         H1(k,j)=k+j;
      end
   end
end
H1	=H1+fliplr(flipud(H1));

for k=1:n
   for j=1:n+1-k
      if 2*round(k/2)~=k & 2*round(j/2)==j
         H2(k,j)=n+1 - H1(n+1-j,k);
      elseif 2*round(k/2)==k & 2*round(j/2)~=j
         H2(k,j)=n+1 - H1(n+1-j,k);
      end
   end
end
H2		=H2+flipud(triu(fliplr(H2),1));
M		=H1+H2;

for k=1:n
   for j=1:n
      if M(k,j) <= .5*n; M(k,j)=(n+2)/2 - M(k,j);
      else M(k,j) = (3*n+2)/2 - M(k,j);
      end
   end
end

%--- rearrange ---
hulp = M;
for k=1:n;
   for j=1:n;
      if hulp(j,1)==k;M(k,:) =hulp(j,:);
      end;
   end;
end

hulp = M;
for k=2:n;
   for j=2:n;
      if hulp(1,j)==k;
         for kk=1:n;
            M(kk,k) =hulp(kk,j);
         end;
      end;
   end;
end