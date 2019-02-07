% Code written by Matthew Ruofan Chan 4-11-2018

function WFG = initWFG(usbNum);
% WFG = initWFG();
% Initializes the Keysight 33600A

% IMPORTANT: in order to use the visa library in Matlab, 
% you need to make sure the correct driver library 
% is installed (if it isn't installed by default).
%
% For this implemetnation, we are using the National
% Instruments ('ni') library, which is the NI-488.2
% driver
% The one I used: http://www.ni.com/download/ni-visa-17.5/7220/en/
%
% Specifically for Matlab, if the first one doesn't work try this one:
% https://www.mathworks.com/hardware-support/ni-visa-keysight-visa-tekvisa.html

% Useful documentation: http://rfmw.em.keysight.com/spdhelpfiles/33500/webhelp/US/Content/__E_Features%20and%20Functions/03%20Pulse%20Waveforms.htm

try

  if nargin<1
    usbNum = 'USB0::2391::22279::MY53801604::0::INSTR';
    % this is the default address of the EEMS-HALL KEYSIG33622A 01
  end

  % initializes the connection to the WFG machine
  WFG = visa('ni', usbNum);

  % opens the connection to the WFG machine and prints a relevant output
  fopen(WFG);
  fprintf('Initialized connection to Keysight 33600A on %s\n', usbNum);

catch
  rethrow(lasterror);
end
