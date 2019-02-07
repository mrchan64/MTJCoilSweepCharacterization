% Code written by Matthew Ruofan Chan 4-11-2018

function WFGPulseTime(WFG, channel, period, offset, amplitude, pwidth, leadtime, trailtime, phase);
% WFGPulseTime(WFG, channel, period);
% WFGPulseTime(WFG, channel, period, offset);
% WFGPulseTime(WFG, channel, period, offset, amplitude);
% WFGPulseTime(WFG, channel, period, offset, amplitude, pwidth);
% WFGPulseTime(WFG, channel, period, offset, amplitude, pwidth, leadtime, trailtime);

% Creates a pulse on the Keysight 33600A based on time rather than frequency
% This is the more ideal version since it uses time rather than frequency
% Alternatively, you can use WFGPulse() to use frequency instead

% The period parameter is in s
% Default offset is 0V
% Default pk-pk amplitude is 2V
% Default pulse width is 50% of period, pulse width is in s
% Default phase is 0 and the unit is in degrees


% check that the channel is specified
if nargin<2
    error('Channel needs to be specified for the Keysight 33600A!');
    return;
end

% check that the frequency is specified
if nargin<3
    error('Period needs to be specified for the Keysight 33600A!');
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


% set pwidth if pwidth not declared
if nargin<6

    pwidth = .5*period;

end

% verify pwidth is in [0.01 99.99]
if pwidth<.01*period
    warning('Lower pulse width parameter limit is 1% on the Keysight 33600A, so the input pulse width has been adjusted!');
    pwidth = .01*period;
elseif pwidth>.99*period
    warning('Upper pulse width parameter limit is 99% on the Keysight 33600A, so the input pulse width has been adjusted!');
    pwidth = .99*period;
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
fprintf(WFG, 'SOUR%d:FUNC:PULS:PER %.3e', [channel period]);
fprintf(WFG, 'SOUR%d:PHASE %.3edeg', [channel phase]);
fprintf(WFG, 'SOUR%d:FUNC:PULS:WIDT %.3e', [channel pwidth]);
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