clear; %clc; 
% DAQ Acquisition

duration = 10;

s = daq.createSession('ni');
s.Rate = 10e3; % 10 kHz sample rate, NOTE: Max for this many channel seems to be 71.4 kHz
s.DurationInSeconds = duration; % 10s of acquisition

% data storage
global data;
global time;
data = [];
time = [];
channels = { 'ai1' 'ai1b' 'ai2' 'ai2b' 'ai3' 'ai3b' 'ai4' 'ai4b' 'ai5' 'ai5b' 'ai6' 'ai6b' 'ai7' 'ai7b'};

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

% output channel
vfield.Range = [-5 5];
vfield.TerminalConfig = 'SingleEnded';
fprintf('Channel ao0 configured for vfield\n');

% create output wave
f = 1e2; % 100hz
a = 1;
t = 0:1/s.Rate:duration;
wave = a.*sin((2*pi*f).*t);

queueOutputData(s, wave');

d_listener = s.addlistener('DataAvailable', @rec_data);

% start DAQ
fprintf('Starting Acquisition\n')
tic;
startBackground(s)

while s.IsRunning
	pause(.1);
end
delete(d_listener)

fprintf('Ending Acquisition\n')
fprintf('Time: %.2f\n', toc);

% callback for available data
function rec_data(src, event)
	global data;
	global time;
	data = [data, event.Data'];
	time = [time, event.TimeStamps'];
end