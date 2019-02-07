clear;
%% FPGA Control
% input parameters
% DCR Enable
en_dcr=1;
% PGA Gain
Gain=1;
% Settling Time (ms)
T_settle=1;
% Measurement Time (ms)
T_measure=10;
% HFIR Enable
enHFIR=1;
% DSM reset Enable
reset_ADC=0;
% Scan All Columns?
scan_en=0;
% end input  

bit_filename = 'C:\Users\Sean\Desktop\MR_AFE_TB\Matlab_FPGA\top_ADC.bit';

Gain=Gain-1;

%   Connect and config FPGA 
%   Returns board name, serial number, xem object and pointer to this
%   objector

%   Load library
if ~libisloaded('okFrontPanel')
	loadlibrary('okFrontPanel', 'okFrontPanelDLL.h');
end

% Try to construct an okUsbFrontPanel and open it
obj.ptr = calllib('okFrontPanel', 'okFrontPanel_Construct');
num = calllib('okFrontPanel', 'okFrontPanel_GetDeviceCount', obj.ptr);
for j=1:num
   m = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListModel', obj.ptr, j-1);
   sn = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListSerial', obj.ptr, j-1, '           ');
   if ~exist('snlist', 'var')
      mlist = m;
      snlist = sn;
   else
      mlist = [mlist;m];
      snlist = char(snlist, sn);
   end
end
% return
xptr = obj.ptr;


% only proceed if one device is connected
if isempty(m)
    error('error: there are no devices connected')
elseif size(m,1) > 1
    error('error: there is more than one device connected')
end

% create new pointer for XEM object and connect by serial number
xem = okusbfrontpanel(obj.ptr);
xem = openbyserial(xem,sn);
pause(0.01);

% program bit file and check for errors
result = configurefpga(xem, bit_filename);
if ~isequal(result,'ok_NoError')
    error('FPGA programming unsuccesfull with error code: %s',result)
else
    fprintf('FPGA programming succesfull with %s\n',bit_filename);
end
pause(0.1);

% Initial control parameters
setwireinvalue(xem, hex2dec('00'),en_dcr,hex2dec('ff'));
setwireinvalue(xem, hex2dec('01'),Gain,hex2dec('ff'));
setwireinvalue(xem, hex2dec('02'),T_settle,hex2dec('ff'));
setwireinvalue(xem, hex2dec('03'),T_measure,hex2dec('ff'));
setwireinvalue(xem, hex2dec('04'),enHFIR,hex2dec('ff'));
setwireinvalue(xem, hex2dec('05'),1,hex2dec('ff'));
setwireinvalue(xem, hex2dec('06'),reset_ADC,hex2dec('ff'));
setwireinvalue(xem, hex2dec('07'),scan_en,hex2dec('ff'));
% reset FIFOs
setwireinvalue(xem, hex2dec('08'),1,hex2dec('ff'));
setwireinvalue(xem, hex2dec('09'),1,hex2dec('ff'));
setwireinvalue(xem, hex2dec('0a'),1,hex2dec('ff'));
setwireinvalue(xem, hex2dec('0b'),1,hex2dec('ff'));
updatewireins(xem);
pause(0.01);

% % Start test
% setwireinvalue(xem, hex2dec('05'),0,hex2dec('ff'));
% updatewireins(xem);

%% DAQ
% AI_Fs = 1000;
% Refresh_Time = 0.1;
% Duration_Time = 110000*Refresh_Time;
% step_size = 0.002;    % Unit: mV
% % Duration_Time = 20000;
% 
% s1 = daq.createSession('ni');
% s1.Rate = AI_Fs;
% s1.DurationInSeconds = Duration_Time;
% 
% ch(1)=s1.addAnalogOutputChannel('Dev1',0,'Voltage');
% ch(2)=s1.addAnalogOutputChannel('Dev1',1,'Voltage');
% ch(1).Range = [-5,5];
% ch(2).Range = [-5,5];
% % cc=addClockConnection(s1,'external','Dev1/PFI1','ScanClock');
% 
% dt=1/AI_Fs;
% t = dt:dt:Duration_Time;
% % Linear Ramp Input
% for i=1:1:Duration_Time/Refresh_Time
%     Vo1((i-1)*AI_Fs*Refresh_Time+1:i*AI_Fs*Refresh_Time) = 0.9.*ones(1,AI_Fs*Refresh_Time);
%     Vo2((i-1)*AI_Fs*Refresh_Time+1:i*AI_Fs*Refresh_Time) = 21.*(0.01+step_size*1e-3*(i-1)).*ones(1,AI_Fs*Refresh_Time);
% end
% % Sinusoidal Input
% Vo1 = 0.9.*ones(1,AI_Fs*Duration_Time);
% Vo2 = 21.*(0.25.*ones(1,AI_Fs*Duration_Time)+0.13.*sin(2*pi*15.*t));

% queueOutputData(s1,transpose([Vo1;Vo2]));
% startBackground(s1);

%% 33600A Control
% Duration_Time = 60;
% Refresh_Time = 20;
% % set the usb address
% addr = 'USB0::2391::22279::MY53801604::0::INSTR';
% % initialize the KEY33600A
% wfg = KEY33600A(addr);
% % set a sine wave
% wfg.sin(1, 40e3, 0.1, 0.004, 0);      % Channel No, Frequency, Offset, Vpp, Phase
% wfg.sin(2, 40e3, 0.1, 0.004, 180);      % Channel No, Frequency, Offset, Vpp, Phase
% % turn on channel 1
% wfg.on(0, 0);       % Channel No, Output Impedance

%% DS360 Control
% % Reset previous Instrument Connections
% instrreset;
% % Open GPIB
% vg = visa('ni','GPIB0::8::INSTR');
% fopen(vg);
% 
% Vin_dB = 0;                   % unit: dBFS
% Vin_V = 0.6*10^(Vin_dB/20);     % unit: V
% Vin_s = char(strcat({'TTAA '},{num2str(Vin_V)},{'VP'}));
% 
% %Reset all Data
% fprintf(vg, '*CLS');
% 
% % set the output channel
% fprintf(vg, 'OUTM 0');     % output mode: 0: unbalanced, 1: balanced
% fprintf(vg, 'TERM 3');     % output load: 0: 50 ohm, 1: 150 ohm, 2: 600 ohm, 3: Hi-Z
% 
% fprintf(vg, 'FUNC 4');       % waveforem:   0: Sine, 1: Square,  4: Two-Tone
% fprintf(vg, 'TTBA 1.08VP');   % unit:        VP:Vpp, VR: Vrms
% fprintf(vg, 'TTBF 10000');    % frequency 
% fprintf(vg, Vin_s);   % unit:        VP:Vpp, VR: Vrms
% fprintf(vg, 'TTAF 23.842');    % frequency 
% fprintf(vg, 'OFFS 0.9');     % note:        disable when using balanced output
% 
% % turn-on DS360
% fprintf(vg, 'OUTE 1');
% pause (1);

%% FIFO readout
Cycle = 10;
data_points = 524288;
block_size = 2^8;
data_pipeout = zeros(4*data_points,Cycle);
data = zeros(data_points,Cycle);
% Start test
setwireinvalue(xem, hex2dec('05'),0,hex2dec('ff'));
updatewireins(xem);
pause(0.1);

for i=1:1:Cycle
    fifo_full = 0;
    fifo_full0 = 0;
    fprintf('Measuring %d of %d...\n',i,Cycle); 
    if i == 1
        setwireinvalue(xem, hex2dec('08'),0,hex2dec('ff')); % enable FIFO
        setwireinvalue(xem, hex2dec('09'),0,hex2dec('ff')); % enable FIFO0
        updatewireins(xem);
%         pause(0.6);
        % wait until FIFO is full
        while (fifo_full==0)
            updatewireouts(xem);
            fifo_full = getwireoutvalue(xem, hex2dec('23'));
            pause(0.01);
        end       
    elseif mod(i, 2) == 0       
        % read data from FIFO
        data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a0'), 4*block_size, 4*data_points);
        data(:,i-1) = data_pipeout(1:4:end,i-1);
        data_out((i-2)*(data_points-1)+1:(i-1)*(data_points-1),1) = data(1:data_points-1,i-1);
        setwireinvalue(xem, hex2dec('08'),1,hex2dec('ff')); % reset FIFO
        updatewireins(xem);
        pause(0.01);
        setwireinvalue(xem, hex2dec('08'),0,hex2dec('ff')); % enable FIFO
        updatewireins(xem);
        % wait until FIFO0 is full
        while (fifo_full0==0)
            updatewireouts(xem);
            fifo_full0 = getwireoutvalue(xem, hex2dec('24'));
            pause(0.01);
        end  
    else
        % read data from FIFO0
        data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a1'), 4*block_size, 4*data_points);
        data(:,i-1) = data_pipeout(1:4:end,i-1);
        data_out((i-2)*(data_points-1)+1:(i-1)*(data_points-1),1) = data(1:data_points-1,i-1);
        setwireinvalue(xem, hex2dec('09'),1,hex2dec('ff')); % reset FIFO0
        updatewireins(xem);
        pause(0.01);
        setwireinvalue(xem, hex2dec('09'),0,hex2dec('ff')); % enable FIFO0
        updatewireins(xem);
        % wait until FIFO is full
        while (fifo_full==0)
            updatewireouts(xem);
            fifo_full = getwireoutvalue(xem, hex2dec('23'));
            pause(0.01);
        end 
    end
end
% cut out the first column data
data_out=data_out(1*(data_points-1)+1:end,1);

%% Read output (Single Channel)
% Duration_Cycle = 100;
% % data_points is set larger than data_length to ensure FIFO empty after read
% data_points = 2^8;
% % block size must be multiple of 16
% block_size = 2^8;
% % real data length (measurement time/ADC period)
% data_length = 256;
% % over sampling ratio
% OSR = 10000;
% % reference voltage
% Vref = 0.1;
% 
% data_pipeout = zeros(4*data_points,Duration_Cycle);
% data = zeros(data_points,Duration_Cycle);
% data_analog = zeros(data_points,Duration_Cycle);
% 
% % start test
% setwireinvalue(xem, hex2dec('05'),0,hex2dec('ff'));
% updatewireins(xem);
% pause(0.01);
% figure;
% box on;
% dT=2.805/(data_length-1);
% 
% for i=1:1:Duration_Cycle
%     fprintf('Measuring %d of %d...\n',i,Duration_Cycle); 
%     fifo_full1 = 0;
%     fifo_full2 = 0;
%     if i == 1
%         setwireinvalue(xem, hex2dec('0a'),0,hex2dec('ff')); % enable FIFO1
%         setwireinvalue(xem, hex2dec('0b'),0,hex2dec('ff')); % enable FIFO2
%         updatewireins(xem);
%         % wait until FIFO1 is full
%         while (fifo_full1==0)
%             updatewireouts(xem);
%             fifo_full1 = getwireoutvalue(xem, hex2dec('21'));
%             pause(0.1);
%         end        
%     elseif mod(i, 2) == 0       
%         % read data from FIFO1
%         data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a2'), 4*block_size, 4*data_points);
%         data(:,i-1) = double(data_pipeout(2:4:end,i-1))*2^8 + double(data_pipeout(1:4:end,i-1)); 
%         data_analog(:,i-1) = data(:,i-1)./OSR.*(2*Vref)-Vref;
%         data_tran((i-2)*(data_length-1)+1:(i-1)*(data_length-1),1) = data_analog(1:data_length-1,i-1);
%         Time=dT:dT:length(data_tran)*dT;
%         
%         setwireinvalue(xem, hex2dec('0a'),1,hex2dec('ff')); % reset FIFO1
%         updatewireins(xem);
%         pause(0.01);
%         % plot data
%         plot(Time,data_tran.*1e3);  
%         % end plot
%         setwireinvalue(xem, hex2dec('0a'),0,hex2dec('ff')); % enable FIFO1
%         updatewireins(xem);
%         % wait until FIFO2 is full
%         while (fifo_full2==0)
%             updatewireouts(xem);
%             fifo_full2 = getwireoutvalue(xem, hex2dec('22'));
%             pause(0.1);
%         end    
%     else
%         % read data from FIFO2
%         data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a3'), 4*block_size, 4*data_points);
%         data(:,i-1) = double(data_pipeout(2:4:end,i-1))*2^8 + double(data_pipeout(1:4:end,i-1)); 
%         data_analog(:,i-1) = data(:,i-1)./OSR.*(2*Vref)-Vref;
%         data_tran((i-2)*(data_length-1)+1:(i-1)*(data_length-1),1) = data_analog(1:data_length-1,i-1); 
%         Time=dT:dT:length(data_tran)*dT;
%         % plot data
%         plot(Time,data_tran.*1e3);  
%         % end plot
%         setwireinvalue(xem, hex2dec('0b'),1,hex2dec('ff')); % reset FIFO2
%         updatewireins(xem);
%         pause(0.01);
% 
%         setwireinvalue(xem, hex2dec('0b'),0,hex2dec('ff')); % enable FIFO2
%         updatewireins(xem);
%         % wait until FIFO1 is full
%         while (fifo_full1==0)
%             updatewireouts(xem);
%             fifo_full1 = getwireoutvalue(xem, hex2dec('21'));
%             pause(0.1);
%         end 
%     end
% end
% data_tran=data_tran(1*(data_length-1)+1:end,1);
% title('Tran Results');
% xlabel('Time [s]');
% ylabel('Voltage [mV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% set(gcf,'color','w');
 
%% Read output (Multi-Channel)    
% % make sure CH8 and CH5 are switched!
% Duration_Cycle = 1000;
% % data_points is set larger than data_length to ensure FIFO empty after read
% data_points = 2^8;
% % block size must be multiple of 16
% block_size = 2^8;
% % real data length 
% data_length = 256;
% % over sampling ratio
% OSR = 10000;
% 
% data_pipeout = zeros(4*data_points,Duration_Cycle);
% data = zeros(data_points,Duration_Cycle);
% data_analog = zeros(data_points,Duration_Cycle);
% 
% % start test
% setwireinvalue(xem, hex2dec('05'),0,hex2dec('ff'));
% updatewireins(xem);
% pause(0.01);
% figure;
% box on;
% dT=2.805*7/(data_length-1);
% 
% for i=1:1:Duration_Cycle
%     fprintf('Measuring %d of %d...\n',i,Duration_Cycle); 
%     fifo_full1 = 0;
%     fifo_full2 = 0;
%     if i == 1
%         setwireinvalue(xem, hex2dec('0a'),0,hex2dec('ff')); % enable FIFO1
%         setwireinvalue(xem, hex2dec('0b'),0,hex2dec('ff')); % enable FIFO2
%         updatewireins(xem);
%         % wait until FIFO1 is full
%         while (fifo_full1==0)
%             updatewireouts(xem);
%             fifo_full1 = getwireoutvalue(xem, hex2dec('21'));
%             pause(0.1);
%         end        
%     elseif mod(i, 2) == 0       
%         % read data from FIFO1
%         data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a2'), 4*block_size, 4*data_points);
%         data(:,i-1) = double(data_pipeout(2:4:end,i-1))*2^8 + double(data_pipeout(1:4:end,i-1)); 
%         data_analog(:,i-1) = data(:,i-1)./OSR.*0.2-0.1;
%         data_tran((i-2)*(data_length-1)+1:(i-1)*(data_length-1),1) = data_analog(1:data_length-1,i-1);
%         data_tran1 = data_tran(1:7:end,1);
%         data_tran2 = data_tran(2:7:end,1);
%         data_tran3 = data_tran(3:7:end,1);
%         data_tran4 = data_tran(4:7:end,1);
%         data_tran5 = data_tran(5:7:end,1);
%         data_tran6 = data_tran(6:7:end,1);
%         data_tran7 = data_tran(7:7:end,1);
%         Time1=dT:dT:length(data_tran1)*dT;
%         Time2=dT:dT:length(data_tran2)*dT;
%         Time3=dT:dT:length(data_tran3)*dT;
%         Time4=dT:dT:length(data_tran4)*dT;
%         Time5=dT:dT:length(data_tran5)*dT;
%         Time6=dT:dT:length(data_tran6)*dT;
%         Time7=dT:dT:length(data_tran7)*dT;
%         
%         setwireinvalue(xem, hex2dec('0a'),1,hex2dec('ff')); % reset FIFO1
%         updatewireins(xem);
%         pause(0.01);
%         % plot data
%         plot(Time7,data_tran7.*1e3,'y',Time1,data_tran1.*1e3,'b',Time2,data_tran2.*1e3,'r',Time3,data_tran3.*1e3,'k',Time5,data_tran5.*1e3,'c',Time6,data_tran6.*1e3,'g',Time4,data_tran4.*1e3,'m');  
%         legend('C1','C2','C3','C4','C6','C7','C8');
%         % end plot
%         setwireinvalue(xem, hex2dec('0a'),0,hex2dec('ff')); % enable FIFO1
%         updatewireins(xem);
%         % wait until FIFO2 is full
%         while (fifo_full2==0)
%             updatewireouts(xem);
%             fifo_full2 = getwireoutvalue(xem, hex2dec('22'));
%             pause(0.1);
%         end    
%     else
%         % read data from FIFO2
%         data_pipeout(:,i-1) = readfromblockpipeout(xem, hex2dec('a3'), 4*block_size, 4*data_points);
%         data(:,i-1) = double(data_pipeout(2:4:end,i-1))*2^8 + double(data_pipeout(1:4:end,i-1)); 
%         data_analog(:,i-1) = data(:,i-1)./OSR.*0.2-0.1;
%         data_tran((i-2)*(data_length-1)+1:(i-1)*(data_length-1),1) = data_analog(1:data_length-1,i-1);
%         data_tran1 = data_tran(1:7:end,1);
%         data_tran2 = data_tran(2:7:end,1);
%         data_tran3 = data_tran(3:7:end,1);
%         data_tran4 = data_tran(4:7:end,1);
%         data_tran5 = data_tran(5:7:end,1);
%         data_tran6 = data_tran(6:7:end,1);
%         data_tran7 = data_tran(7:7:end,1);   
%         Time1=dT:dT:length(data_tran1)*dT;
%         Time2=dT:dT:length(data_tran2)*dT;
%         Time3=dT:dT:length(data_tran3)*dT;
%         Time4=dT:dT:length(data_tran4)*dT;
%         Time5=dT:dT:length(data_tran5)*dT;
%         Time6=dT:dT:length(data_tran6)*dT;
%         Time7=dT:dT:length(data_tran7)*dT;
%         % plot data
%         plot(Time7,data_tran7.*1e3,'y',Time1,data_tran1.*1e3,'b',Time2,data_tran2.*1e3,'r',Time3,data_tran3.*1e3,'k',Time5,data_tran5.*1e3,'c',Time6,data_tran6.*1e3,'g',Time4,data_tran4.*1e3,'m');  
%         legend('C1','C2','C3','C4','C6','C7','C8');
%         % end plot
%         setwireinvalue(xem, hex2dec('0b'),1,hex2dec('ff')); % reset FIFO2
%         updatewireins(xem);
%         pause(0.01);
% 
%         setwireinvalue(xem, hex2dec('0b'),0,hex2dec('ff')); % enable FIFO2
%         updatewireins(xem);
%         % wait until FIFO1 is full
%         while (fifo_full1==0)
%             updatewireouts(xem);
%             fifo_full1 = getwireoutvalue(xem, hex2dec('21'));
%             pause(0.1);
%         end 
%     end
% end
% data_tran1=data_tran1(1*(data_length-1)+1:end,1);
% data_tran2=data_tran2(1*(data_length-1)+1:end,1);
% data_tran3=data_tran3(1*(data_length-1)+1:end,1);
% data_tran4=data_tran4(1*(data_length-1)+1:end,1);
% data_tran5=data_tran5(1*(data_length-1)+1:end,1);
% data_tran6=data_tran6(1*(data_length-1)+1:end,1);
% data_tran7=data_tran7(1*(data_length-1)+1:end,1);
% title('Tran Results');
% xlabel('Time [s]');
% ylabel('Voltage [mV]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% set(gcf,'color','w');
% save('test.mat','data_tran1','data_tran2','data_tran3','data_tran4','data_tran5','data_tran6','data_tran7','Time1','Time2','Time3','Time4','Time5','Time6','Time7');

%% Histogram Testing
% % data_points is set larger than data_length to ensure FIFO empty after read
% data_points = 2^6;
% % block size must be multiple of 16
% block_size = 2^6;
% % real data length (measurement time/ADC period)
% data_length = 50;
% % over sampling ratio
% OSR = 10000;
% 
% data_pipeout = zeros(4*data_points,Duration_Time);
% data = zeros(data_points,Duration_Time);
% 
% % start test
% setwireinvalue(xem, hex2dec('05'),0,hex2dec('ff'));
% updatewireins(xem);
% 
% for i=1:1:Duration_Time
%     fprintf('Measuring %d of %d...\n',i,Duration_Time);
% %     Vin = 0.021+21*(step_size*2*1e-3*(i-1));
% %     % Configue FG
% %     fprintf(vg, ['AMPL ' num2str(Vin) 'VP']);   % unit:        VP:Vpp, VR: Vrms
% %     % End configue
%     pause(1);  
%     % Instant Result
% %     Chip_out(i,1) = getwireoutvalue(xem, hex2dec('20'));
%     % Averaged Result
%     data_pipeout(:,i) = readfromblockpipeout(xem, hex2dec('a1'), 4*block_size, 4*data_points);
% end
% % Analog_out = Chip_out./OSR.*0.2-0.1;
% data(:,:) = double(data_pipeout(2:4:end,:))*2^8 + double(data_pipeout(1:4:end,:)); 
% data_analog = data./OSR.*0.2-0.1;
% 
% for m=1:1:Duration_Time
%     data_out((m-1)*(data_length-1)+1:m*(data_length-1),1) = data(1:data_length-1,m);
%     data_tran((m-1)*(data_length-1)+1:m*(data_length-1),1) = data_analog(1:data_length-1,m); 
% end
% % Vsig = mean(data_tran);
% Time=1/(data_length-1):1/(data_length-1):Duration_Time;

% data_count = zeros(OSR,1);
% for i=1:1:length(data_out)
%     for j=1:1:OSR
%         if (data_out(i) == (j-1))
%             data_count(j) = data_count(j)+1;
%         elseif (data_out(i) >= OSR)    
%             data_count(OSR) = data_count(OSR)+1;
%         end
%     end    
% end

% % Sin Input INL Calculation
% A=OSR/2;
% vin=(0:OSR-1)-OSR/2;	%distance of codes to mid code
% sin2ramp=1./(pi* sqrt(A^2*ones(size(vin))-vin.*vin));
% while sum(data_count(2:OSR-1)) < (Duration_Time*1e3/(T_settle+T_measure))*sum(sin2ramp(2:OSR-1))
%   A=A+0.1;
%   sin2ramp=1./(pi* sqrt(A^2*ones(size(vin))-vin.*vin));
% end
% 
% figure;
% plot([0:OSR-1],data_count,[0:OSR-1],sin2ramp*(Duration_Time*1e3/(T_settle+T_measure)));
% title('CODE HISTOGRAM - SINE WAVE');
% xlabel('DIGITAL OUTPUT CODE');
% ylabel('COUNTS');
% data_countn=data_count(2:OSR-1)./((Duration_Time*1e3/(T_settle+T_measure)).*sin2ramp(2:OSR-1))'; %End points discarded!
% figure;
% plot([1:OSR-2],data_countn);
% title('CODE HISTOGRAM - NORMALIZED')
% xlabel('DIGITAL OUTPUT CODE');
% ylabel('NORMALIZED COUNTS');
% 
% DNL=data_countn(2001:OSR-2002)-1;
% INL=cumsum(DNL);
% [p,S]=polyfit([1:5998]',INL,1);
% INL_best=INL-p(1)*[1:5998]'-p(2);

% Ramp Input INL Calculation
% % DC Input
% count_avg = mean(data_count(2:end-1));
% DNL = (data_count(2:end-1)-count_avg)/count_avg;    % Unit: LSB
% INL = cumsum(DNL);
% [p,S]=polyfit([1:OSR-2]',INL,1);
% INL_best=INL-p(1)*[1:OSR-2]'-p(2);

% % AC Input
% count_avg = mean(data_count(1+1501:end-1501));
% DNL = (data_count(1+1501:end-1501)-count_avg)/count_avg;    % Unit: LSB
% INL = cumsum(DNL);
% [p,S]=polyfit([1:6998]',INL,1);
% INL_best=INL-p(1)*[1:6998]'-p(2);
% 
% % DNL/INL Plot
% DNL_max=max(abs(DNL));
% INL_max=max(abs(INL_best));
% figure;
% subplot(2,1,1);
% bar(DNL);
% title('ADC DNL');
% xlabel('Output Code');
% ylabel('DNL [LSB]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% subplot(2,1,2);
% bar(INL_best);
% title('ADC INL');
% xlabel('Output Code');
% ylabel('INL [LSB]');
% set(gca,'FontSize',12,'FontName', 'Arial', 'FontWeight', 'Bold');
% set(gcf,'color','w');

%% Close
pause(1);
% % turn-off DS360
% fprintf(vg, 'OUTE 0');
% turn-off 33600A
% wfg.off();
% wfg.close();
% destruct FPGA
calllib('okFrontPanel', 'okFrontPanel_Destruct', obj.ptr);






