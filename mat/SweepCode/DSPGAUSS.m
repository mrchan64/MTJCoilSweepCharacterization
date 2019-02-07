% Code written by Matthew Ruofan Chan 12-8-2018

% This class is a Matlab driver class to handle
% control of the Lakeshore 475 DSP Gaussmeter
%
% This class is standalone and the only file
% you need to run all the functionality.

% List of methods:
%     .config()
%     .read()
%     .close()

classdef DSPGAUSS < handle

    % IMPORTANT: in order to use the gpib library in Matlab, 
    % you need to make sure the correct driver library 
    % is installed (it isn't installed by default).
    %
    % For this implementation, we are using the National
    % Instruments ('ni') library, which is the NI-488.2
    % driver
    % The one I used: http://www.ni.com/download/ni-488.2/7272/en/

    % Programming guide: https://www.lakeshore.com/Documents/475_Manual.pdf (go to page 102)

    properties
        DSP    % the instrument object
        gpibNum
    end

    methods

        % Initializes the DSP connected to gpibNum
        function obj = DSPGAUSS(gpibNum);
            % DSP = DSPGAUSS(gpibNum);

            obj.gpibNum = gpibNum;

            try

              % initializes the connection to the gaussmeter machine
              obj.DSP = gpib('ni', 0, gpibNum);

              % opens the connection to the gaussmeter machine and prints a relevant output
              fopen(obj.DSP);
              fprintf('Initialized connection to Gaussmeter on GPIB %d\n', gpibNum);
              fprintf(obj.DSP, '*CLS');
              warning('Interacting with the machine or pressing the menu button will break the GPIB connection');

            catch
              rethrow(lasterror);
            end

        end

        % configure the machine
        function config(obj, units, rrange, rmode);

            % Units: 1 G | 2 T | 3 Oe | 4 A/m
            % Range: 1-5 denotes decimal places shown (6-Range)
            % Mode: 1 DC | 2 RMS | 3 Peak

            if nargin>1
              fprintf(obj.DSP, 'UNIT %d',units)
            end

            if nargin>2
              fprintf(obj.DSP, 'RANGE %d', rrange)
            end

            if nargin>3
              fprintf(obj.DSP, 'RDGMODE %d,1,1,1,1', rmode)
            end
        end

        % read the values
        function [ field, freq ] = read(obj);
            % returns current numerical reading on display and frequency

            fprintf(obj.DSP, 'RDGFIELD?');
            field = fscanf(obj.DSP, '%e');

            fprintf(obj.DSP, 'RDGFRQ?');
            freq = fscanf(obj.DSP, '%e');
        end


        % closes the connection
        function close(obj);

            fclose(obj.DSP);
        end

    end

end
