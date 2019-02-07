bitfile = 'C:/Users/Magneto/Documents/PC-FPGA/Matlab_API/pipetest.bit';
addpath('C:\Users\Magneto\Documents\PC-FPGA\Matlab_API\')

if ~libisloaded('okFrontPanel')
       loadlibrary('okFrontPanel', 'okFrontPanelDLL.h');
end

%% Connect to XEM

xptr = calllib('okFrontPanel', 'okFrontPanel_Construct');
num = calllib('okFrontPanel', 'okFrontPanel_GetDeviceCount', xptr);

success = configurefpga(xptr, bitfile);
