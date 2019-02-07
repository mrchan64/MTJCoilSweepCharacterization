%function xem = ok_init(FPGA_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  M-file for testing FrontPanel APIs with Matlab.
%
%  Notes: This must be run on a 32-bit version of Matlab. It will not run
%  on a 64-bit version without some serious effort in installing extra
%  compilers. All this version needs is the free version of Microsoft
%  visual studio 2008. If you are coding the XEM6001, you also must use
%  version 4.0 of FrontPanel. 
%
%  For some reason, under FrontPanel 4.0 and using the XEM6001, the device
%  seems to want calls to the API to say 'okFrontPanel' instead of
%  'okUsbFrontPanel' like what used to be.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add paths and load DLL

% addpath('C:\Program Files (x86)\Opal Kelly\FrontPanelUSB\API')
% addpath('C:\Program Files (x86)\Opal Kelly\FrontPanelUSB\API\Matlab')
addpath('C:\Users\Magneto\Documents\PC-FPGA\Matlab_API\')

%if ~libisloaded('okFrontPanel')
%       loadlibrary('okFrontPanel', 'okFrontPanelDLL.h');
%end

%% Connect to XEM

% get number of devices and serial numbers
[m,sn] = ok_getdevicelist;

% only proceed if one device is connected
if isempty(m)
error('error: there are no devices connected')
elseif size(m,1) > 1
error('error: there is more than one device connected')
end

% create new pointer for XEM object and connect by serial number
xptr = calllib('okFrontPanel', 'okFrontPanel_Construct');
xem = okusbfrontpanel(xptr);
xem = openbyserial(xem,sn);

pause(0.01);

% program bit file and check for errors
result = configurefpga(xem, FPGA_file);
if ~isequal(result,'ok_NoError')
    error('FPGA programming unsuccesfull with error code: %s',result)
end

% double-check to make sure FrontPanel is enabled
if isfrontpanelenabled(xem)
    fprintf('\nOpal Kelly board %s with serial number %s connected successfully\n',m,sn);
else
    error('Something went wrong programming the FPGA');
end




