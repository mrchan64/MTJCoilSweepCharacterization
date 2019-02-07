% Code written by Matthew Ruofan Chan 12-9-2018

% This class is a Matlab driver class to handle
% control of the Keithley 2260B series 
% Waveform Generator.
%
% This class is standalone and the only file
% you need to run all the functionality.

% List of methods:
%     .on()
%     .off()
%     .setVandI()
%     .close()

classdef KEI2260B < handle

    % IMPORTANT: in order to use the visa library in Matlab, 
    % you need to make sure the correct driver library 
    % is installed (if it isn't installed by default).
    %
    % For this implementation, we are using the National
    % Instruments ('ni') library, which is the NI-488.2
    % driver
    % The one I used: http://www.ni.com/download/ni-visa-17.5/7220/en/
    %
    % Specifically for Matlab, if the first one doesn't work try this one:
    % https://www.mathworks.com/hardware-support/ni-visa-keysight-visa-tekvisa.html

    % Programming guide: https://doc.xdevs.com/doc/Keithley/2260/2260B_Programming_Manual%28March2014%29.pdf (Page 43)

    properties
        kei    % the instrument object
        usbNum
    end

    methods

        % Initializes the kei connected to usbNum
        function obj = KEI2260B(usbNum);
            % kei = KEI2260B();
            % Initializes the Keithley 2260B

            try

              if nargin<1
                usbNum = '1';
                % this is the default address for COM1
              end

              obj.usbNum = ['ASRL' num2str(usbNum) '::INSTR'];

              % initializes the connection to the kei machine
              obj.kei = visa('ni', obj.usbNum);

              % opens the connection to the kei machine and prints a relevant output
              fopen(obj.kei);
              fprintf('Initialized connection to Keithley 2260B on %s\n', obj.usbNum);

            catch
              rethrow(lasterror);
            end

        end

        function on(obj)

            fprintf(obj.kei, 'OUTP 1');
        end

        function off(obj)

            fprintf(obj.kei, 'OUTP 0');
        end

        function setVandI(obj, voltage, current)

            a = sprintf('APPLY %f,%f', [voltage current]);
            fprintf(obj.kei, a);
        end



        % closes the connection
        function close(obj);

            fclose(obj.kei);
        end

    end

end
