function HL = HearThres(HD);
%function HL = HearThres(HD);
% determines hearing thresholds per octave band to compensate for
% audibility
%
% where:
%  HL   = hearing levels                [dB SPL]
%
%  HD   = type of head phone {'STI'    = as in standard,
%                             'DT48'   = Beyer dynamic dt 48
%                             'HDA200' = Sennheiser HDA 200
%                             'TDH39'  = the obvious
switch lower(HD)
 case {'sti'}
  HL = [46, 27, 12, 6.5, 7.5, 8, 12];   % standard Table A.2
 case {'dt48'}
 case {'hda200'}
 case {'tdh39'}
end
% By Pete D. Best 03/23/09