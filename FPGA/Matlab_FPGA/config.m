function [mlist,snlist,wireout,pipeout,word]=config()

if ~libisloaded('okFrontPanel')
	loadlibrary('okFrontPanel', 'okFrontPanelDLL.h');
end


% Try to construct an okUsbFrontPanel and open it (the board model doesn't matter).
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

% Destruct the object pointer.
%calllib('okFrontPanel', 'okFrontPanel_Destruct', xptr);
%% Connect to XEM

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
result = configurefpga(xem, 'C:\Users\Magneto\Documents\PC-FPGA\pipetest\pipetest\pipetest.bit');
if ~isequal(result,'ok_NoError')
    error('FPGA programming unsuccesfull with error code: %s',result)
end

% double-check to make sure FrontPanel is enabled
if isfrontpanelenabled(xem)
    fprintf('\nOpal Kelly board %s with serial number %s connected successfully\n',m,sn);
else
    error('Something went wrong programming the FPGA');
end
pause(0.1);

%pause time
pt=0.65;

setwireinvalue(xem, hex2dec('00'),bin2dec('11'),hex2dec('ffffffff'));
updatewireins(xem)
%pause(3);
updatewireouts(xem);
wireout = getwireoutvalue(xem, hex2dec('20'));

%fprintf('%d', wireout);
disp(wireout);
pause(0.01);

setwireinvalue(xem, hex2dec('00'),bin2dec('01'),hex2dec('ffffffff'));
updatewireins(xem)
pause(0.01);

setwireinvalue(xem, hex2dec('00'),0,hex2dec('ffffffff'));
updatewireins(xem)
%pause(3);
updatewireouts(xem);
wireout = getwireoutvalue(xem, hex2dec('20'));

pause(1.2);

% test trigger
activatetriggerin(xem, hex2dec('40'), 1);
%updatetriggerouts(xem);
%trig = istriggered(xem, hex2dec('60'), hex2dec('ffffffff'));

%test pipein
%byte_vector1 = (0:1:255)';
%byte_vector2 = (255:-1:0)';
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector1);
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector2);
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector1);
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector2);
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector1);
%success = writetoblockpipein(xem, hex2dec('80'), 256, byte_vector2);
%test pipeout
pipeout = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout1 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout2 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout3 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout4 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout5 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout6 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout7 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout8 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout9 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout10 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout11 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout12 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout13 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout14 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);
pause(pt);
pipeout15 = readfromblockpipeout(xem, hex2dec('a1'), 8192 ,262144);

word_array = double(pipeout(1:4:end)) + bitshift(double(pipeout(2:4:end)),8);
word_array1 = double(pipeout1(1:4:end)) + bitshift(double(pipeout1(2:4:end)),8);
word_array2 = double(pipeout2(1:4:end)) + bitshift(double(pipeout2(2:4:end)),8);
word_array3 = double(pipeout3(1:4:end)) + bitshift(double(pipeout3(2:4:end)),8);
word_array4 = double(pipeout4(1:4:end)) + bitshift(double(pipeout4(2:4:end)),8);
word_array5 = double(pipeout5(1:4:end)) + bitshift(double(pipeout5(2:4:end)),8);
word_array6 = double(pipeout6(1:4:end)) + bitshift(double(pipeout6(2:4:end)),8);
word_array7 = double(pipeout7(1:4:end)) + bitshift(double(pipeout7(2:4:end)),8);
word_array8 = double(pipeout8(1:4:end)) + bitshift(double(pipeout8(2:4:end)),8);
word_array9 = double(pipeout9(1:4:end)) + bitshift(double(pipeout9(2:4:end)),8);
word_array10 = double(pipeout10(1:4:end)) + bitshift(double(pipeout10(2:4:end)),8);
word_array11 = double(pipeout11(1:4:end)) + bitshift(double(pipeout11(2:4:end)),8);
word_array12 = double(pipeout12(1:4:end)) + bitshift(double(pipeout12(2:4:end)),8);
word_array13 = double(pipeout13(1:4:end)) + bitshift(double(pipeout13(2:4:end)),8);
word_array14 = double(pipeout14(1:4:end)) + bitshift(double(pipeout14(2:4:end)),8);
word_array15= double(pipeout15(1:4:end)) + bitshift(double(pipeout15(2:4:end)),8);

word = [word_array; word_array1; word_array2; word_array3; word_array4; word_array5; word_array6; word_array7; word_array8; word_array9; word_array10; word_array11; word_array12; word_array13; word_array14; word_array15];

%fprintf('%d', wireout);
disp(wireout);
%pause(0.1);
% Destruct the object pointer.
calllib('okFrontPanel', 'okFrontPanel_Destruct', obj.ptr);