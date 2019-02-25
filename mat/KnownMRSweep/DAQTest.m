clear; clc;

% DAQ stuff
s = daq.createSession('ni');
s.Rate = 10e3; % 10 kHz sample rate, NOTE: Max for this many channel seems to be 71.4 kHz

daq_settle_time = .5; % .5s of waiting
daq_read_time = .25;	% .25 second for record
daq_pad_time = .25; % .25s of waiting
daq_total_time = daq_settle_time + daq_read_time + daq_pad_time;
daq_samples_per_step = daq_total_time * s.Rate;

% ADD ANALOG CHANNELS
row1 = s.addAnalogInputChannel('Dev1', 'ai7', 'Voltage');
row2 = s.addAnalogInputChannel('Dev1', 'ai6', 'Voltage');
row3 = s.addAnalogInputChannel('Dev1', 'ai5', 'Voltage');
row4 = s.addAnalogInputChannel('Dev1', 'ai4', 'Voltage');
row5 = s.addAnalogInputChannel('Dev1', 'ai3', 'Voltage');
row6 = s.addAnalogInputChannel('Dev1', 'ai2', 'Voltage');
row7 = s.addAnalogInputChannel('Dev1', 'ai1', 'Voltage'); 
row8 = s.addAnalogInputChannel('Dev1', 'ai0', 'Voltage');

% Vbias channel
vb_o = s.addAnalogOutputChannel('Dev1', 'ao0', 'Voltage');
% Sweep Field channel
vfield = s.addAnalogOutputChannel('Dev1','ao1','Voltage');

ana_in = [ row1 row2 row3 row4 row5 row6 row7 row8 ];

% settings: non-differential and -10V to 10V
counter = 1;
for ch = ana_in
	ch.Range = [-10 10];
	ch.TerminalConfig = 'SingleEnded';
	fprintf('Row %d configured\n', counter);
	counter = counter + 1;
end

vb_o.Range = [-10 10];
vb_o.TerminalConfig = 'SingleEnded';
fprintf('Channel ao0 configured for V Bias\n');

vfield.Range = [-10 10];
vfield.TerminalConfig = 'SingleEnded';
fprintf('Channel ao0 configured for vfield\n');

% DAQ for digital stuff (only need to run one column)
s2 = daq.createSession('ni');
s2.addDigitalChannel('Dev1', 'port1/line0', 'OutputOnly');      % Column Select1
% s2.addDigitalChannel('Dev2', 'port1/line1', 'OutputOnly');      % Column Select2
% s2.addDigitalChannel('Dev2', 'port1/line2', 'OutputOnly');      % Column Select3
% s2.addDigitalChannel('Dev2', 'port1/line3', 'OutputOnly');      % Column Select4
% s2.addDigitalChannel('Dev2', 'port1/line4', 'OutputOnly');      % Column Select5
% s2.addDigitalChannel('Dev2', 'port1/line5', 'OutputOnly');      % Column Select6
% s2.addDigitalChannel('Dev2', 'port1/line6', 'OutputOnly');      % Column Select7
% s2.addDigitalChannel('Dev2', 'port1/line7', 'OutputOnly');      % Column Select8
% s2.addDigitalChannel('Dev2', 'port2/line0', 'OutputOnly');      % Column Select9
% s2.addDigitalChannel('Dev2', 'port2/line1', 'OutputOnly');      % Column Select10

% Turn on the selected column
outputSingleScan(s2, [1]);