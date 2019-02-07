% Code written by Matthew Ruofan Chan 4-11-2018

function WFGOff(WFG, channel);
% WFGOff(WFG);
% Disables the output for the Keysight 33600A.

% if channel unspecified, turns off all channels
if nargin<2
  channel = 0;
end

% turn off the WFG
if channel==1 || channel==2

    fprintf(WFG, 'OUTP%d OFF', channel);


elseif channel==0

    fprintf(WFG, 'OUTP1 OFF');
    fprintf(WFG, 'OUTP2 OFF');


else

    error('Not a valid channel selection for  Keysight 33600A!');

end
    