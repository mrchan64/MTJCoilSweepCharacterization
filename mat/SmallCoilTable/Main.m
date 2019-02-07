clear;

savename = 'isweep/Chip1_500';

% PARAMETERS
saturation_range = 10; 		% max Oe to process linear fit to on both sides
reprocess_data = true; 		% will rerun process_raw if true
rewrite_html = false; 		% will rewrite the html table
% for finding working (overrides working_table parameters)
r_nom_low = 1e3;
r_nom_high = 6e3;
mr_low = 1e-1;
r_2 = 0.9;


% reprocessing data
if reprocess_data
	fprintf('Reprocessing data\n');
	reset_to_raw(savename);
	process_raw(savename, saturation_range);
end

% gather working data
fprintf('Finding working sensors\n');
[working, working_ref] = working_mat(savename, r_nom_low, r_nom_high, mr_low, r_2);

% mat working
working_table(savename, working, working_ref);


% get working data
[Data_working,Pointer_working,R0_working,MR_working,Data_working_ref,Pointer_working_ref,R0_working_ref,MR_working_ref]=get_working(savename, working, working_ref);

% rewriting html
if rewrite_html
	write_html_table(savename, r_nom_low, r_nom_high, mr_low, r_2);
end

% CALCULATION
% non-reference
MR_avg=mean(MR_working);
MR_mis=MR_working-MR_avg;
MR_mis_std=std(MR_working);
MR_mis_max=max(abs(MR_mis));

R0_avg=mean(R0_working);
R0_mis=R0_working-R0_avg;
R0_mis_std=std(R0_working);
R0_mis_max=max(abs(R0_mis));

% reference
MR_avg_ref=mean(MR_working_ref);
MR_mis_ref=MR_working_ref-MR_avg_ref;
MR_mis_std_ref=std(MR_working_ref);
MR_mis_max_ref=max(abs(MR_mis_ref));

R0_avg_ref=mean(R0_working_ref);
R0_mis_ref=R0_working_ref-R0_avg_ref;
R0_mis_std_ref=std(R0_working_ref);
R0_mis_max_ref=max(abs(R0_mis_ref));