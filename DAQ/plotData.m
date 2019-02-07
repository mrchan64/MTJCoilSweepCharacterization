function plotData(src,event)
    global data_analog; 
    global Tracker;
    global Duration_Time;
    global ax;
    global AI_Fs;
    global Refresh_Period;
    global vg;
    fprintf('Measuring %d of %d...\n',Tracker,(Duration_Time/Refresh_Period));
%     % Configue DS360
%     amp = sprintf('AMPL %0.5fVP',0.004+0.00004*(Tracker-1));
%     fprintf(vg, amp); % unit:        VP:Vpp, VR: Vrms
%     % End configue
    data_analog((ceil(AI_Fs*Refresh_Period)*(Tracker-1)+1):ceil(AI_Fs*Refresh_Period)*Tracker,:)=[event.Data];
    if Tracker == 1
        figure;
    end
    ax(1) = subplot(2,1,1);
    plot(event.TimeStamps,event.Data(:,1),'b');
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    ax(2) = subplot(2,1,2);
%     plot(event.TimeStamps,event.Data(:,3),'b');
%     xlabel('Time [s]');
%     ylabel('Voltage [V]');    
    
    Tracker = Tracker + 1;
end