% Code written by Matthew Ruofan Chan 4-11-2018

function WFGRamp(WFG, channel, freq, offset, amplitude, symmetry, phase);
% WFGRamp(WFG, channel, freq);
% WFGRamp(WFG, channel, freq, offset);
% WFGRamp(WFG, channel, freq, offset, amplitude);
% WFGRamp(WFG, channel, freq, offset, amplitude, symmetry);

% Creates a triangle wave on the Keysight 33600A

% The frequency parameter is in Hz
% Default offset is 0V
% Default pk-pk amplitude is 2V
% Default symmetry is 50%, symmetry is in percentage
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

    % check that amplitude is not less than 1e-3
    if amplitude < 1e-3
        warning('Lower amplitude parameter limit is 1e-3 (1mVpp) on the Keysight 33600A, so the input parameter has been adjusted!')
        amplitude = 1e-3;
    end

    low = offset - amplitude/2;
    high = offset + amplitude/2;


end

% check that high and low voltages are in range
if low<-5 || high>5
    error('Output Waveform cannot go above 5V or below -5V on the Keysight 33600A!');
    return
end


% set symmetry if symmetry not declared
if nargin<6

    symmetry = 50;

end

% verify symmetry is in [0 100]
if symmetry<0
    warning('Lower symmetry parameter limit is 0% on the Keysight 33600A, so the input symmetry has been adjusted!');
    symmetry = 0;
elseif symmetry>100
    warning('Upper symmetry parameter limit is 100% on the Keysight 33600A, so the input symmetry has been adjusted!');
    symmetry = 100;
end


% set phase if phase is not declared
if nargin<7

    phase = 0;

end

% set phase to be in [-180 180)
phase = mod(phase+180, 360) - 180;


% set waveform
fprintf(WFG, 'SOUR%d:FUNC ramp', channel);
fprintf(WFG, 'SOUR%d:VOLT:HIGH %.3e', [channel high]);
fprintf(WFG, 'SOUR%d:VOLT:LOW %.3e', [channel low]);
fprintf(WFG, 'SOUR%d:FREQ %.3e', [channel freq]);
fprintf(WFG, 'SOUR%d:PHASE %.3edeg', [channel phase]);
fprintf(WFG, 'SOUR%d:FUNC:RAMP:SYMM %.3e', [channel symmetry]);