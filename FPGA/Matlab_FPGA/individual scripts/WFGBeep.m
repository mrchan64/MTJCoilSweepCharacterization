% Code written by Matthew Ruofan Chan 4-11-2018

function WFGBeep(WFG);
% WFGBeep(WFG);
% Makes a beep on the Keysight 33600A.

fprintf(WFG, 'SYST:BEEP');
