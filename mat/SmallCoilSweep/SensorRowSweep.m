clc, clear; instrreset; close all;

% THIS CODE RUNS ON THE SMALL COIL !!! BEWARE OF HIGH VOLTAGES AND CURRENTS GENERATED !!!
% 
% Code for running Xiahan Zhou's MTJ Characterization for Sensor. Needs KEI2260B code file.
% Code written by Matthew Chan on 1/15/2019.
% Code uses a DAQ. Chip requires FPGA code to run.
% Tested on Matlab R2018a for academic use.
%
% This code sweeps through all rows (changed manually using FPGA) and determines which sensors are working and which sensors are not at 700mV bias. Sensor selection is manual, use SensorRowSweep.m to just get MR and Nominal Resistance values for all sensors.
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
conditioning_field = 50; %Oe
conditioning_time = 10; %s 

% data storage
global data;
global time;
data = [];
time = [];
channels = { 'ai1' 'ai1b' 'ai2' 'ai2b' 'ai3' 'ai3b' 'ai4' 'ai4b' 'ai5' 'ai5b' 'ai6' 'ai6b' 'ai7' 'ai7b'};

mean_data = [];

row_data = {};	% for each row curve;
row_title = {};

% Output channel (vfield)

vfield = s.addAnalogOutputChannel('Dev1','ao1','Voltage');

% acquisition channels (b channel is vin-)

% AI1 (Vin+0)
ai1 = s.addAnalogInputChannel('Dev1','ai1','Voltage');
ai1B = s.addAnalogInputChannel('Dev1','ai9','Voltage');

% AI2 (Vin+5)
ai2 = s.addAnalogInputChannel('Dev1','ai2','Voltage');
ai2B = s.addAnalogInputChannel('Dev1','ai10','Voltage');

% AI3 (Vin+10)
ai3 = s.addAnalogInputChannel('Dev1','ai3','Voltage');
ai3B = s.addAnalogInputChannel('Dev1','ai11','Voltage');

% AI4 (Vin+15)
ai4 = s.addAnalogInputChannel('Dev1','ai4','Voltage');
ai4B = s.addAnalogInputChannel('Dev1','ai12','Voltage');

% AI5 (Vin+20)
ai5 = s.addAnalogInputChannel('Dev1','ai5','Voltage');
ai5B = s.addAnalogInputChannel('Dev1','ai13','Voltage');

% AI6 (Vin+25)
ai6 = s.addAnalogInputChannel('Dev1','ai6','Voltage');
ai6B = s.addAnalogInputChannel('Dev1','ai14','Voltage');

% AI7 (Vin+31)
ai7 = s.addAnalogInputChannel('Dev1','ai7','Voltage');
ai7B = s.addAnalogInputChannel('Dev1','ai15','Voltage');

ana_in = [ ai1 ai2 ai3 ai4 ai5 ai6 ai7 ];
ana_in_b = [ ai1B ai2B ai3B ai4B ai5B ai6B ai7B ];

% settings: non-differential and -5V to 5V
counter = 1;
for ch = ana_in
	ch.Range = [-10 10];
	ch.TerminalConfig = 'SingleEnded';
	fprintf('Channel ai%d configured\n', counter);
	counter = counter + 1;
end
counter = 1;
for ch = ana_in_b
	ch.Range = [-10 10];
	ch.TerminalConfig = 'SingleEnded';
	fprintf('Channel ai%db configured\n', counter);
	counter = counter + 1;
end

% output channel
vfield.Range = [-10 10];
vfield.TerminalConfig = 'SingleEnded';
fprintf('Channel ao0 configured for vfield\n');

d_listener = s.addlistener('DataAvailable', @rec_data);

% figure settings

f = figure('Visible', 'off', 'WindowState', 'Maximized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS------------------------------------------------------
m_time = .1;
hv = 7.7;

r_nom = 4.75e3; % resistance in current source
bias_V = .7; % V .7 best?

test_volt = fields./hv;
bias_I = bias_V / r_nom;

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

	row_data{end+1} = mean_data ./ bias_I; % mean_data is in V, so dividing by I will give resistance
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