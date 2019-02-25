clear; clc; close all;

savename_list = {...
'isweep2/Chip2_500'...
'isweep2/Chip2_550'...
'isweep2/Chip2_600'...
'isweep2/Chip2_650'...
'isweep2/Chip2_700'...
'isweep2/Chip2_750'...
'isweep2/Chip2_800'...
'isweep2/Chip2_850'...
'isweep2/Chip2_900'};

% PARAMETERS
reprocess_data = false;
show_tables = true;
saturation_range = 10; 		% max Oe to process linear fit to on both sides
% for finding working (overrides working_table parameters)
r_nom_low = 1e3;
r_nom_high = 6e3;
mr_low = 1e-3;
r_2 = 0.9;

% additional parameters
use_additional_parameters = true;
max_r0_offset = 500;
mr_perc_low = 1e-5;

% show all data for one cell
plot_one_sensor = false;
show_row = 382; % row name of sensor % row 182 col 5 is good %row 302 col 6 is good
show_col = 3;   % col name of sensor, 8 is used for ref

% test params for showing how often they work
show_accumulation_table = true;

% CODE 

percentages = [];
accumulation = [];

% process each one
for savename = savename_list
  savename = savename{1};
  if reprocess_data
    fprintf('Processing %s\n', savename);
    process_raw(savename, saturation_range);
  end
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
  if show_tables
    working_table(savename, working, working_ref, savename);
  end

  % accumulation
  if length(accumulation) == 0
    accumulation = [working working_ref'];
  else
    accumulation = accumulation + [working working_ref'];
  end

end

for i = 1:length(savename_list);
  savename = savename_list{i};
  perc = percentages(i);
  fprintf('%s has %.3f%% non-reference working\n', savename, perc);
end

% show all on one table if that is specified
if plot_one_sensor
  T = load(savename_list{1});
  titles = T.row_title;
  ind = find(contains(titles, ['Row ' num2str(show_row)]));
  if length(ind) > 0  % exists
    if show_col > 0 && show_col < 8
      plot_fields = T.fields;
      plot_data = {};
      figure
      hold on;
      for savename = savename_list
        savename = savename{1};
        T = load(savename);
        plot_data{end+1} = T.row_data{ind}(show_col*2-1, :);
        plot(plot_fields, plot_data{end});
      end
      hold off;
      legend(savename_list);
      title([T.row_title{ind} 'AI' num2str(show_col)]);
      xlabel('Oe');
      ylabel('Ohms')
    elseif show_col == 8
      plot_fields = T.fields;
      plot_data = {};
      figure
      hold on;
      for savename = savename_list
        savename = savename{1};
        T = load(savename);
        plot_data{end+1} = T.row_data{ind}(2, :);
        plot(plot_fields, plot_data{end});
      end
      hold off;
      legend(savename_list);
      title([T.row_title{ind} 'Ref']);
      xlabel('Oe');
      ylabel('Ohms')
    else
      fprintf('Column %d does not exist\n', show_col);
    end
  else
    fprintf('Row %d does not exist in dataset\n', show_row);
  end
end