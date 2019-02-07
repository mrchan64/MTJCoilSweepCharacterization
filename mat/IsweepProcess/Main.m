clear; clc; close all;

savename_list = {...
'isweep/Chip1_500'...
'isweep/Chip1_550'...
'isweep/Chip1_600'...
'isweep/Chip1_650'...
'isweep/Chip1_700'...
'isweep/Chip1_750'...
'isweep/Chip1_800'...
'isweep/Chip1_850'...
'isweep/Chip1_900'};

% PARAMETERS
saturation_range = 10; 		% max Oe to process linear fit to on both sides
% for finding working (overrides working_table parameters)
r_nom_low = 1e3;
r_nom_high = 6e3;
mr_low = 1e-1;
r_2 = 0.9;

% additional parameters
use_additional_parameters = true;
max_r0_offset = 500;
mr_perc_low = 1e-5;

percentages = [];

% process each one
for savename = savename_list
  savename = savename{1};
  % fprintf('Processing %s\n', savename);
  % process_raw(savename, saturation_range);
end

% gather working data
fprintf('Finding working sensors:\n');
for savename = savename_list
  savename = savename{1};
  if use_additional_parameters
    [working, working_ref] = working_mat(savename, r_nom_low, r_nom_high, mr_low, r_2, max_r0_offset, mr_perc_low);
  else
    [working, working_ref] = working_mat(savename, r_nom_low, r_nom_high, mr_low, r_2);
  end

  % calc percentage
  w = sum(sum(working));
  a =  size(working);
  tot = a(1) * a(2);
  percentages(end+1) = w/tot*100;


  % create the table
  working_table(savename, working, working_ref, savename);
end

for i = 1:length(savename_list);
  savename = savename_list{i};
  perc = percentages(i);
  fprintf('%s has %.3f%% non-reference working\n', savename, perc);
end
