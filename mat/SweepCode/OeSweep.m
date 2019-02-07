clc, clear; instrreset; close all;

% Code for running Xiahan Zhou's MTJ Characterization for Sensor. Needs KEI2260B code file.
% Code written by Matthew Chan on 1/10/2019.
% Code uses a Keithley 2260B source, and a DAQ. Chip requires FPGA code to run.
% Tested on Matlab R2018a for academic use.
%
% This code sweeps current field for current rode at multiple bias Voltages and plots them in order to ascertain which sensors are working and which sensors are not
%
% NOTE: PLEASE PROCEED WITH CAUTION BECAUSE OF HIGH VOLTAGES

% fields = linspace(-10, 10, 100);
fields = [linspace(0, 100, 21) linspace(95, 0, 20)];
pause_time = 1; % time between changes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DAQ stuff
s = daq.createSession('ni');
s.Rate = 10e3; % 10 kHz sample rate, NOTE: Max for this many channel seems to be 71.4 kHz
s.DurationInSeconds = 1; % 1s of acquisition

% data storage
global data;
global time;
data = [];
time = [];
channels = { 'ai1' 'ai1b' 'ai2' 'ai2b' 'ai3' 'ai3b' 'ai4' 'ai4b' 'ai5' 'ai5b' 'ai6' 'ai6b' 'ai7' 'ai7b'};

mean_data = [];

curve_data = {};	% for each bias curve;
curve_title = {};
curr_data = [];

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
	ch.Range = [-5 5];
	ch.TerminalConfig = 'SingleEnded';
	fprintf('Channel ai%d configured\n', counter);
	counter = counter + 1;
end
counter = 1;
for ch = ana_in_b
	ch.Range = [-5 5];
	ch.TerminalConfig = 'SingleEnded';
	fprintf('Channel ai%db configured\n', counter);
	counter = counter + 1;
end

d_listener = s.addlistener('DataAvailable', @rec_data);

% figure settings

f = figure('Visible', 'off', 'WindowState', 'Maximized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS------------------------------------------------------
m_time = .1;
hv = 1.2;
ha = 39;
v_lim = max(fields)/hv * 1.1;

r_nom = 4.75e3; % resistance in current source

test_curr = fields./ha;

% ----------------------------------------------------------------

% initialize connection
k = KEI2260B(3); % COM3

% initial conditions and protections
if v_lim < 20
	v_lim = 20;
end
i_lim = max(test_curr)*1.2;
if i_lim < 1.4
	i_lim = 1.4;
end
fprintf(k.kei, 'VOLT:PROT %.3f', v_lim)
fprintf(k.kei, 'CURR:PROT %.3f', i_lim);
k.setVandI(v_lim, 0); % v_lim and 0 A
pause(2)
k.on();
fprintf(k.kei, 'DISP:MENU:NAME 0') % show measurements on device
fprintf('Device Initialized\n');

pause(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTUAL SWEEP
while true

	fprintf('\n')
	vbias = input('Enter Current VBias (mV) (-1 to Terminate): ');
	fprintf('\n')

	if vbias==-1
		break;
	end

	curve_title{end+1} = [num2str(vbias) 'mV'];
	curr_data(end+1) = vbias / r_nom;

	% SWEEPING OE

	fprintf('Sweeping %d points\n', length(fields));

	for test_i = test_curr
		% pause(pause_time)

		% set current on power supply
		k.setVandI(v_lim, test_i);
		pause(pause_time);

		% get current measure
		fprintf(k.kei, 'MEAS:CURR?');
		ni = fscanf(k.kei, '%e');
		% get voltage measure
		fprintf(k.kei, 'MEAS:VOLT?');
		nv = fscanf(k.kei, '%e');

		% DAQ Gather Data
		startBackground(s)
		while s.IsRunning
			pause(1);
		end

		mean_data = [mean_data mean(data')'];
		data = [];
		time = [];

		fprintf('Testing %.3fA %.3fOe in coil. Measured %.3fA and %.3fV.\n', test_i, test_i*ha, ni, nv);

	end

	curve_data{end+1} = mean_data ./ curr_data(end); % mean_data is in V, so dividing by I will give resistance
	mean_data = [];

	fprintf('Sweep Finished\n');
	plotOnFig(f, fields, curve_data, curve_title);
	% END OE SWEEP

end

% END SWEEP
fprintf('Ending experiment\n');

pause(5);
k.off();
pause(3);
k.close();
fprintf('Instruments turned off\n');


% callback for available data
function rec_data(src, event)
	global data;
	global time;
	data = [data, event.Data'];
	time = [time, event.TimeStamps'];
end

function plotOnFig(fig, fields, curve_data, titles)
	% only plots ai1-7 and not the b plots
	num_curves = length(titles);
	figure(fig);
	for i =  1:7
		subplot(2, 4, i);
		cla
		dat_ind = i*2-1;
		hold on
		for j = 1:num_curves
			plot(fields, curve_data{j}(dat_ind, :));
		end
		hold off
		ylabel('Ohms')
		xlabel('Oe')
		legend(titles);
		title(['AI' num2str(i)]);
	end
	fig.Visible = 'on';
end