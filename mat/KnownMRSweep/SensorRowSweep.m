clc, clear; instrreset; close all;

% THIS CODE RUNS ON THE SMALL COIL !!! BEWARE OF HIGH VOLTAGES AND CURRENTS GENERATED !!!
% 
% Code for running verifying MR sensor. Needs KEI2260B code file.
% Code written by Matthew Chan on 2/8/2019.
% Code uses a DAQ.
% Tested on Matlab R2018a for academic use.
%
% This code sweeps runs a sweep on the data and saves it to verify that sweep code is working
%
% NOTE: PLEASE PROCEED WITH CAUTION BECAUSE OF HIGH VOLTAGES

% fields = linspace(-10, 10, 100);
fields = [linspace(0, 40, 21) linspace(38, -38, 39) linspace(-40, 0, 21)]; % goes up to 40Oe and -40Oe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DAQ stuff
s = daq.createSession('ni');
s.Rate = 10e3; % 10 kHz sample rate, NOTE: Max for this many channel seems to be 71.4 kHz

daq_settle_time = .5; % .5s of waiting
daq_read_time = .25;	% .25 second for record
daq_pad_time = .25; % .25s of waiting
daq_total_time = daq_settle_time + daq_read_time + daq_pad_time;
daq_samples_per_step = daq_total_time * s.Rate;

conditioning_freq = 100;
conditioning_field = 20; %Oe
conditioning_time = 1; %s 

cm_bias = .1;

% data storage
global data;
global time;
data = [];
time = [];
channels = { 'ai1' 'ai1b' 'ai2' 'ai2b' 'ai3' 'ai3b' 'ai4' 'ai4b' 'ai5' 'ai5b' 'ai6' 'ai6b' 'ai7' 'ai7b'}; % this doesnt do anything actually

mean_data = [];

row_data = {};	% for each row curve;
row_title = {};

% ADD ANALOG CHANNELS
row1 = s.addAnalogInputChannel('Dev1', 'ai7', 'Voltage');
row2 = s.addAnalogInputChannel('Dev1', 'ai6', 'Voltage');
row3 = s.addAnalogInputChannel('Dev1', 'ai5', 'Voltage');
row4 = s.addAnalogInputChannel('Dev1', 'ai4', 'Voltage');
row5 = s.addAnalogInputChannel('Dev1', 'ai3', 'Voltage');
row6 = s.addAnalogInputChannel('Dev1', 'ai2', 'Voltage');
row7 = s.addAnalogInputChannel('Dev1', 'ai1', 'Voltage'); 
row8 = s.addAnalogInputChannel('Dev1', 'ai0', 'Voltage');

% Sweep Field channel
vfield = s.addAnalogOutputChannel('Dev1','ao1','Voltage');
% Vbias channel
vb_o = s.addAnalogOutputChannel('Dev1', 'ao0', 'Voltage');

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
s2.addDigitalChannel('Dev1', 'port1/line1', 'OutputOnly');      % Column Select2
s2.addDigitalChannel('Dev1', 'port1/line2', 'OutputOnly');      % Column Select3
s2.addDigitalChannel('Dev1', 'port1/line3', 'OutputOnly');      % Column Select4
s2.addDigitalChannel('Dev1', 'port1/line4', 'OutputOnly');      % Column Select5
s2.addDigitalChannel('Dev1', 'port1/line5', 'OutputOnly');      % Column Select6
s2.addDigitalChannel('Dev1', 'port1/line6', 'OutputOnly');      % Column Select7
s2.addDigitalChannel('Dev1', 'port1/line7', 'OutputOnly');      % Column Select8
s2.addDigitalChannel('Dev1', 'port2/line0', 'OutputOnly');      % Column Select9
s2.addDigitalChannel('Dev1', 'port2/line1', 'OutputOnly');      % Column Select10

% Turn on the selected column
outputSingleScan(s2, [1 0 0 0 0 0 0 0 0 0]);

d_listener = s.addlistener('DataAvailable', @rec_data);

% figure settings

f = figure('Visible', 'off', 'WindowState', 'Maximized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS------------------------------------------------------
m_time = .1;
hv = 7.7;

test_volt = fields./hv;

conditioning_volt = conditioning_field/hv;

% ----------------------------------------------------------------

% create sweep waveform (needs to be a column vector)
v_sweep = [];
conditioning = conditioning_wave(s.Rate, conditioning_freq, conditioning_volt, conditioning_time);
v_sweep = [conditioning']; conditioning_on = true; % comment out this line to remove conditioning
for v_ampl = test_volt
	this_step = ones(daq_samples_per_step, 1) * v_ampl;
	v_sweep = [v_sweep; this_step];
end
% bias voltage waveform (flat)
v_sweep(:,2) = v_sweep.*0 + cm_bias;

% set time start points and endpoints
a = length(fields);
t_off = 0;
if conditioning_on
	t_off = conditioning_time;
end
t_rec = 1:a;
record_start = (t_rec - 1) .* daq_total_time + daq_settle_time + t_off;
record_end = t_rec .* daq_total_time - daq_pad_time + t_off;

% get savename
fprintf('\n');
savename = input('Enter save file name: ', 's');

pause(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTUAL SWEEP
while true

	fprintf('\n')
	rownum = input('Enter Sensor Row (-1 to Terminate): ');
	fprintf('\n')

	if rownum==-1
		break;
	end

	row_title{end+1} = ['Row ' num2str(rownum)];

	% SWEEPING OE

	fprintf('Sweeping %d points\n', length(fields));
	% queue sweep
	queueOutputData(s, v_sweep);
	startBackground(s);
	tic;

	for counter = 1:length(fields);
		field = fields(counter);
		volt = test_volt(counter);
		rec_st = record_start(counter);
		rec_en = record_end(counter);

		fprintf('Testing %.3fV %.3fOe in coil.\n', volt, field);

		% wait for record start
		while toc < rec_st
			pause(.01);
		end

		data = [];
		time = [];

		% wait for record end
		while toc < rec_en
			pause(.01)
		end

		mean_data = [mean_data mean(data')'];

	end

	row_data{end+1} = mean_data; % just raw output data, postprocess later
	mean_data = [];

	fprintf('Sweep Finished\n');

	% save data
	if length(savename)>2
		save(savename, 'fields', 'row_data', 'row_title')
		fprintf('Saving file %s.mat\n', savename)
	else
		fprintf('Not saving file\n')
	end

end

delete(d_listener)

% END SWEEP
fprintf('Ending experiment\n');


% callback for available data
function rec_data(src, event)
	global data;
	global time;
	data = [data, event.Data'];
	time = [time, event.TimeStamps'];
end

% callback for generating conditioning wave
function wave = conditioning_wave(update_rate, frequency, amplitude, duration)
	ur = 1/update_rate;
	t = ur : ur : duration;
	wave = amplitude * sin((2*pi*frequency).*t);
end