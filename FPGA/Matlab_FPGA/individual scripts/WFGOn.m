% Code written by Matthew Ruofan Chan 4-11-2018

function WFGOn(WFG, channel, impedance);
% WFGOn(WFG);
% Enables the output for the Keysight 33600A.

% % if channel unspecified, turns on all channels
% if nargin<2
%   channel = 0;
% end

% turn on the WFG
if channel==1 || channel==2
    
    % Specify output impedance
                if impedance == 0       % high Z
                    fprintf(WFG, 'OUTP%d:LOAD INF', channel);
                elseif impedance >= 1 && impedance <= 10e3
                    fprintf(WFG, 'OUTP%d:LOAD %d', [channel impedance]);
                else
                    error('Impedance must be between 1 to 10k Ohms for Keysight 33600A!');
                end 
    
    fprintf(WFG, 'OUTP%d ON', channel);


elseif channel==0

    % Specify output impedance
                if impedance == 0       % high Z
                    fprintf(WFG, 'OUTP1:LOAD INF');
                    fprintf(WFG, 'OUTP2:LOAD INF');
                elseif impedance >= 1 && impedance <= 10e3
                    fprintf(WFG, 'OUTP1:LOAD %d', impedance);
                    fprintf(WFG, 'OUTP2:LOAD %d', impedance);
                else
                    error('Impedance must be between 1 to 10k Ohms for Keysight 33600A!');
                end
    
    fprintf(WFG, 'OUTP1 ON');
    fprintf(WFG, 'OUTP2 ON');


else

    error('Not a valid channel selection for Keysight 33600A!');

end
    