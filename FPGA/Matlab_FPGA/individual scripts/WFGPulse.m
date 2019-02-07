% Code written by Matthew Ruofan Chan 4-11-2018

function WFGPulse(WFG, channel, freq, offset, amplitude, dcycle, leadtime, trailtime, phase);
% WFGPulse(WFG, channel, freq);
% WFGPulse(WFG, channel, freq, offset);
% WFGPulse(WFG, channel, freq, offset, amplitude);
% WFGPulse(WFG, channel, freq, offset, amplitude, dcycle);
% WFGPulse(WFG, channel, freq, offset, amplitude, dcycle, leadtime, trailtime);

% Creates a pulse on the Keysight 33600A
% This is the nonideal version since it uses frequency to match the other functions.
% Alternatively, you can use WFGPulseTime() to use pulse period and pulse width instead

% The frequency parameter is in Hz
% Default offset is 0V
% Default pk-pk amplitude is 2V
% Default duty cycle is 50%, duty cycle is in percentage
% Default phase is 0 and the unit is in degrees


% check that the channel is specified
if nargin<2
    error('Channel needs to be specified for the Keysight 33600A!');
    return;
end

% check that the frequency is specified
if nargin<3
    error('Frequency needs to be specified for the Keysight 33600A!');
    return;
end

% verify the channel
if ~(channel==1 || channel==2)
    error('The specified channel isn''t valid  for the Keysight 33600A!');
    return;
end
    

low = -1;
high = 1;



% set other values if only offset is declared
if nargin==4

    low = low + offset;
    high = high + offset;


% set high and low voltage if offset and amplitude are both declared
elseif nargin>4

    low = offset - amplitude/2;
    high = offset + amplitude/2;


end

% check that high and low voltages are in range
if low<-5 || high>5
    error('Output Waveform cannot go above 5V or below -5V on the Keysight 33600A!');
    return
end


% set dcycle if dcycle not declared
if nargin<6

    dcycle = 50;

end

% verify dcycle is in [0.01 99.99]
if dcycle<0.01
    warning('Lower duty cycle parameter limit is 0.01% on the Keysight 33600A, so the input duty cycle has been adjusted!');
    dcycle = 0.01;
elseif dcycle>99.99
    warning('Upper duty cycle parameter limit is 99.99% on the Keysight 33600A, so the input duty cycle has been adjusted!');
    dcycle = 99.99;
end


% set leadtime if leadtime is not declared
if nargin<7

    if (high-low) <= 4
        leadtime = 2.9e-9;
    else
        leadtime = 3.3e-9;
    end

end

% verify leadtime
if (high-low) <= 4
    if leadtime<2.9e-9
        warning('Lower lead time parameter limit is 2.9e-9 (2.9ns) on the Tektronix WFG3052C, so the input lead time has been adjusted!');
        leadtime = 2.9e-9;
    end
else
    if leadtime<3.3e-9
        warning('Lower lead time parameter limit is 3.3e-9 (3.3ns) on the Tektronix WFG3052C, so the input lead time has been adjusted!');
        leadtime = 3.3e-9;
    end
end


% set trailtime if trailtime is not declared
if nargin<8

    if (high-low) <= 4
        trailtime = 2.9e-9;
    else
        trailtime = 3.3e-9;
    end

end

% verify trailtime
if (high-low) <= 4
    if trailtime<2.9e-9
        warning('Lower trail time parameter limit is 2.9e-9 (2.9ns) on the Tektronix WFG3052C, so the input trail time has been adjusted!');
        trailtime = 2.9e-9;
    end
else
    if trailtime<3.3e-9
        warning('Lower trail time parameter limit is 3.3e-9 (3.3ns) on the Tektronix WFG3052C, so the input trail time has been adjusted!');
        trailtime = 3.3e-9;
    end
end


% set phase if phase is not declared
if nargin<9

    phase = 0;

end

% set phase to be in [-180 180)
phase = mod(phase+180, 360) - 180;


% set waveform
fprintf(WFG, 'SOUR%d:FREQ %.3e', [channel freq]);
fprintf(WFG, 'SOUR%d:PHASE %.3edeg', [channel phase]);
fprintf(WFG, 'SOUR%d:FUNC:PULS:DCYC %.3e', [channel dcycle]);
fprintf(WFG, 'SOUR%d:FUNC puls', channel);

% set edge times first if going above 4 Vpp otherwise you get an error on the machine
if (high - low) > 4
    fprintf(WFG, 'SOUR%d:FUNC:PULS:TRAN:LEAD %.3e', [channel leadtime]);
    fprintf(WFG, 'SOUR%d:FUNC:PULS:TRAN:TRA %.3e', [channel trailtime]);
end

fprintf(WFG, 'SOUR%d:VOLT:HIGH %.3e', [channel high]);
fprintf(WFG, 'SOUR%d:VOLT:LOW %.3e', [channel low]);
fprintf(WFG, 'SOUR%d:FUNC:PULS:TRAN:LEAD %.3e', [channel leadtime]);
fprintf(WFG, 'SOUR%d:FUNC:PULS:TRAN:TRA %.3e', [channel trailtime]);