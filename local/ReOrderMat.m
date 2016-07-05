function out = ReOrderMat(M, Morder);
%function out = ReOrderMat(M, Morder);
% orders the row elements of M as indicated by the elements of Morder
%
% where:
%  out    = ordered matrix
%
%  M      = matrix to order
%  Morder = order of rwo elements
[noro, noco] = size(M);                % size of problem
out          = -999.*ones(noro, noco); % initialize output matrix
for CurCo = [1:noco],                  % for each column
  temp = sortrows([M(:,CurCo), Morder(:,CurCo)], 2); % sort rows
  out(:,CurCo) = temp(:,1);            % store sorted rows
end;
% By Pete D. Best 04/29/09