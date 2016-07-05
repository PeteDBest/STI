function [alfa, beta] = STISex(sex, source);
%function [alfa, beta] = STISex(sex, source);
% returns the male and female weighting factors of audio spectrum
% 
% where:
%  alfa    = octave weighting factor
%  beta    = comodulation compensation weighting factors
%
%  sex     = sex of speaker                        {'m': male; 'f':female}
%  source  = spectral weighting function        {'STI': ISO 60268-16:2003}
alfas = [0.085, 0.127, 0.230, 0.233, 0.309, 0.224, 0.173; ...
         0    , 0.117, 0.223, 0.216, 0.328, 0.250, 0.194];
betas = [0.085, 0.078, 0.065, 0.011, 0.047, 0.095, 0;     ...
         0    , 0.099, 0.066, 0.062, 0.025, 0.076, 0];
switch lower(source)
  case {'sti'}
  if lower(sex) == 'm',
    alfa = alfas(1,:);
    beta = betas(1,:);
  else
    alfa = alfas(2,:);
    beta = betas(2,:);
  end
end
% By Pete D. Best 03/23/09