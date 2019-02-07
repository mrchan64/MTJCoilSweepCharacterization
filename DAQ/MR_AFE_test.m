clear;
% Initilizing
global data_analog; 
global Tracker;
global Duration_Time;
global ax;
global AI_Fs;
global Refresh_Period;
global vg;
Tracker = 1;
AI_Fs = 250e3;
Refresh_Period = 1;
Duration_Time = 9*Refresh_Period;
% fc = 50e3;
% fH = 10e3;

%% GPIB control for DS360
% 
% % Reset previous Instrument Connections
% instrreset;
% % Open GPIB
% vg = visa('ni','GPIB0::8::INSTR');
% fopen(vg);
% 
% %Reset all Data
% fprintf(vg, '*CLS');
% 
% % set the output channel
% fprintf(vg, 'OUTM 0');     % output mode: 0: unbalanced, 1: balanced
% fprintf(vg, 'TERM 3');     % output load: 0: 50 ohm, 1: 150 ohm, 2: 600 ohm, 3: Hi-Z
% 
% fprintf(vg, 'FUNC 0');       % waveforem:   0: Sine, 1: Square
% fprintf(vg, 'AMPL 0.004VP');   % unit:        VP:Vpp, VR: Vrms
% fprintf(vg, 'OFFS 0.32');     % note:        disable when using balanced output
% fprintf(vg, 'FREQ 90000');    % frequency
% 
% % turn-on DS360
% fprintf(vg, 'OUTE 1');

%% DAQ
% Analog channels
s1 = daq.createSession('ni');
s1.Rate = AI_Fs;
s1.DurationInSeconds = Duration_Time;

ch(1)=s1.addAnalogOutputChannel('Dev1',0,'Voltage');
ch(2)=s1.addAnalogOutputChannel('Dev1',1,'Voltage');
ch(3)=s1.addAnalogInputChannel('Dev1',1,'Voltage');
ch(4)=s1.addAnalogInputChannel('Dev1',9,'Voltage');
% ch(3)=s1.addAnalogInputChannel('Dev1',0,'Voltage');
% ch(4)=s1.addAnalogInputChannel('Dev1',8,'Voltage');
ch(5)=s1.addAnalogInputChannel('Dev1',3,'Voltage');
ch(6)=s1.addAnalogInputChannel('Dev1',11,'Voltage');
% ch(5)=s1.addAnalogInputChannel('Dev1',2,'Voltage');
% ch(6)=s1.addAnalogInputChannel('Dev1',10,'Voltage');
% cc=addClockConnection(s1,'external','Dev1/PFI1','ScanClock');

ch(1).Range = [-5,5];
ch(2).Range = [-5,5];
ch(3).TerminalConfig = 'Differential';
ch(3).Range = [-2,2];
% ch(4).TerminalConfig = 'SingleEndedNonReferenced';
% ch(4).Range = [-2,2];
ch(5).TerminalConfig = 'Differential';
ch(5).Range = [-2,2];

dt=1/AI_Fs;
t = dt:dt:Duration_Time;
% Vo1 = 4.*(0.5.*ones(1,Duration_Time*AI_Fs)+0.2.*sin(2*pi*10e3*t));
% Vo2 = 4.*(0.924.*ones(1,Duration_Time*AI_Fs)-0.2.*sin(2*pi*10e3*t));

for i=1:1:Duration_Time/Refresh_Period
    Vo1((i-1)*ceil(AI_Fs*Refresh_Period)+1:i*ceil(AI_Fs*Refresh_Period)) = 0.95.*ones(1,ceil(AI_Fs*Refresh_Period));
    Vo2((i-1)*ceil(AI_Fs*Refresh_Period)+1:i*ceil(AI_Fs*Refresh_Period)) = 0.85.*ones(1,ceil(AI_Fs*Refresh_Period));
end
queueOutputData(s1,transpose([Vo1;Vo2]));

data_analog = zeros(ceil(AI_Fs*Duration_Time),4); 
lh = s1.addlistener('DataAvailable', @plotData);
s1.NotifyWhenDataAvailableExceeds = ceil(AI_Fs*Refresh_Period);
startBackground(s1);
while s1.IsRunning         
    pause(Refresh_Period);                                                      
end  

delete (lh);
% Output and plot
VIA = data_analog(:,1);
% Vac = data_analog(:,3);
Signal = mean(VIA);

% % Histogram Testing
% count = zeros(200/step_size+1,1);
% for i=1:1:length(Vac)
%     for j=1:1:200/step_size+1
%         if (Vac(i) >= (j-1)*0.2/(200/step_size)-0.2/(400/step_size)-0.1) && (Vac(i) < j*0.2/(200/step_size)-0.2/(400/step_size)-0.1)
%             count(j) = count(j)+1;
%         elseif (Vac(i) < -0.2/(400/step_size)-0.1)    
%             count(1) = count(1)+1;
%         else    
%             count(200/step_size+1) = count(200/step_size+1)+1;
%         end
%     end    
% end 
% 
% count_avg = mean(count(1+200/(4*step_size):end-200/(4*step_size)-1));
% DNL = (count(1+200/(4*step_size):end-200/(4*step_size)-1)-count_avg)/count_avg*step_size*1e3;    % Unit: uV
% for j=1:size(DNL)
%    INL(j)=sum(DNL(1:j));	%INL,j=DNL,0+DNL,1+...+DNL,j
% end
% 
% DNL_max=max(abs(DNL));
% INL_max=max(abs(INL));
% 
% for i=1:1:(Duration_Time/Refresh_Period-1)
%     Input(i,1) = 1e-3.*(-90+0.1*(i-1));
%     Output(i,1)=mean(Vac((i*ceil(AI_Fs*Refresh_Period)+ceil(AI_Fs*Refresh_Period*0.1)):(i+1)*ceil(AI_Fs*Refresh_Period)-ceil(AI_Fs*Refresh_Period*0.1),1));
% end    
% 
% % turn-off DS360
% fprintf(vg, 'OUTE 0');

%%
subplot(ax(1));    
plot(t,VIA,'b');
% xlim([0.054 0.055]);
title('VIA');
xlabel('Time [s]');
ylabel('Voltage [V]');
set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% 
% subplot(ax(2));
% % plot(t,Vac-VIA,'b');
% % xlim([0.054 0.055]);
% % title('Vac-VIA');
% % xlabel('Time [s]');
% % ylabel('Voltage [V]');
% % set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
set(gcf,'color','w');

% Offset=mean(Vac);

% Linearity Plot
% [fitob,gof] = fit(Input(11:end-1),Output(11:end-1),'poly1');
% Vlin=fitob.p1.*Input(11:end-1)+fitob.p2;
% INL=Output(11:end-1)-Vlin;
% INL_max=max(abs(INL));
% 
% figure;
% subplot(2,1,1);
% plot(Input(11:end-1).*1e3,Output(11:end-1).*1e3);
% title('DAQ Transfer Curve');
% xlabel('Vin [mV]');
% ylabel('Vout [mV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% subplot(2,1,2);
% bar(Input(11:end-1).*1e3,INL.*1e6);
% title('Linearity');
% xlabel('Vin [mV]');
% ylabel('INL [uV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% set(gcf,'color','w');

% % Histogram Plot
% figure;
% subplot(2,1,1);
% bar(DNL);
% title('DAQ DNL');
% xlabel('Output Code');
% ylabel('DNL [uV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% subplot(2,1,2);
% bar(INL);
% title('DAQ INL');
% xlabel('Output Code');
% ylabel('INL [uV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% set(gcf,'color','w');

% File_Name='Data_test.mat';
% save(File_Name,'Vcell','Vref');


