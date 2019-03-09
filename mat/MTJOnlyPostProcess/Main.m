clear;

% raw data files
savename_raw_forward = 'raw_data/MR_Chip4_RB100k_30Oe_pos';
savename_raw_reverse = 'raw_data/MR_Chip4_RB100k_30Oe_neg';

% target for processed data files
savename_forward = 'processed_data/MR_Chip4_RB100k_30Oe_pos_processed';
savename_reverse = 'processed_data/MR_Chip4_RB100k_30Oe_neg_processed';

% target for summary
savename_processed = 'processed_data/Chip4_Sensor_Summary';
savename_html = 'html/MR_Chip4'; % Make sure if there is a subdirectory, the folder already exists

% PARAMETERS
saturation_range = 10;    % max Oe to process linear fit to on both sides
% reorganize_data = false; % if data needs to be reorganized to Matthew's format (should already be done)
include_raw_in_wrkspace = true;
reprocess_data = true;  % will rerun process_raw if true
rewrite_summary = true;   % will rewrite sensor performance summary file
rewrite_html = true;    % will rewrite the html table
% for finding working (overrides working_table parameters)
r_nom_low = 10e3;
r_nom_high = 1000e3;
mr_low = 1e-1;
r_2 = 0.91;

% additional parameters
use_additional_parameters = true;
max_r0_offset = .05; % Changed to percentage (.05 = 5%)
mr_perc_low = 10e-5;

% check for overriding
if strcmp(savename_forward, savename_raw_forward) || strcmp(savename_reverse, savename_raw_reverse)
  warning('The savenames will cause the raw data to be overwritten.  Please set a different name.  Now ending.')
  return;
end

% copy file to new reprocess location
copyfile([savename_raw_forward '.mat'], [savename_forward '.mat']);
copyfile([savename_raw_reverse '.mat'], [savename_reverse '.mat']);

% load raw data into workspace
if include_raw_in_wrkspace
  T_raw_f = load(savename_raw_forward);
  T_raw_r = load(savename_raw_reverse);
end

% reorganize data in copied files
reorg_data(savename_forward);
reorg_data(savename_reverse);

% reprocessing data
if reprocess_data
  fprintf('Reprocessing data\n');
  reset_to_raw(savename_forward); reset_to_raw(savename_reverse);
  process_raw(savename_forward, saturation_range);
  process_raw(savename_reverse, saturation_range);
end

% gather working data
fprintf('Finding working sensors\n');
if use_additional_parameters
  work_f = working_mat(savename_forward, r_nom_low, r_nom_high, mr_low, r_2, max_r0_offset, mr_perc_low);
  work_r = working_mat(savename_reverse, r_nom_low, r_nom_high, mr_low, r_2, max_r0_offset, mr_perc_low);
else 
  work_f = working_mat(savename_forward, r_nom_low, r_nom_high, mr_low, r_2);
  work_r = working_mat(savename_reverse, r_nom_low, r_nom_high, mr_low, r_2);
end

% mat working
working = work_f & work_r;
working_polar_table(savename_forward, savename_reverse, working);

% saving working mats to reprocessed data
save(savename_forward, 'work_f', 'working', '-append');
save(savename_reverse, 'work_r', 'working', '-append');

% get working data
[Data_working,Pointer_working,R0_working,MR_working]=get_working(savename_forward, savename_reverse, working);

% rewriting html
if rewrite_html
  if use_additional_parameters
    write_html_table(savename_forward, savename_reverse, savename_html, r_nom_low, r_nom_high, mr_low, r_2, max_r0_offset, mr_perc_low);
  else
    write_html_table(savename_forward, savename_reverse, savename_html, r_nom_low, r_nom_high, mr_low, r_2);
  end
end

% generate summary and load summary into struct
% loaded in as:
%   T_summ.R0_avg
%   T_summ.R0_std
%   T_summ.MR_avg
%   T_summ.MR_std
%   T_summ.Ros_avg
if rewrite_summary
  generate_summary(savename_forward, savename_reverse, savename_processed, working);
  T_summ = load(savename_processed);
end

% R0, MR, AND Ro DATA AS MATRIX INSTEAD OF CELLS
[R0_all, MR_all, Ros_all, MR_sensor] = get_data(savename_forward, savename_reverse);

% Operations and other calculations can go down here
% ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
