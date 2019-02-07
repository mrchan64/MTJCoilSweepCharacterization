function [working, working_ref] = working_table(savename, rl, rh, ml, r2l)
	% !!!IMPORTANT!!! rl, rh, ml, r2l parameters are OPTIONAL, only savename is required 
	% FUNCTION to find working sensors and plot them on a table to see the relative success rate.
	T = load(savename);

	if nargin > 1
		% OVERRIDE PARAMETERS
		r_nom_low = rl;
		r_nom_high = rh;
		mr_low = ml;
		r_2 = r2l;
	else
		% DEFAULT PARAMETERS
		r_nom_low = 1e3;
		r_nom_high = 6e3;
		mr_low = 1e-1;
		r_2 = 0.9;
	end

	% result data
	Data_working = [];
	Pointer_working = [];
	R0_working = [];
	MR_working = [];
	Data_working_ref = [];
	Pointer_working_ref = [];
	R0_working_ref = [];
	MR_working_ref = [];

	working = [];
	% determine working
	a = length(T.nominal_res);
	for i = 1:a
		b = length(T.nominal_res{i});
		for j = 1:b
			cond1 = T.nominal_res{i}(j) > r_nom_low;
			cond2 = T.nominal_res{i}(j) < r_nom_high;
			cond3 = T.mr_r2{i}(j) > r_2;
			cond4 = abs(T.calculated_mr{i}(j)) > mr_low;
			working(i,j) = cond1 && cond2 && cond3 && cond4;
			% save working data
			if working(i,j)
				dat_ind = j*2-1;
				Data_working(end+1,:) = T.row_data{i}(dat_ind,:);
				Pointer_working(end+1, :) = [i j];
				R0_working(end+1, 1) = T.nominal_res{i}(j);
				MR_working(end+1, 1) = T.calculated_mr{i}(j);
			end
		end
	end

	working_ref = [];
	a = length(T.ref_nom_r);
	for i = 1:a
		cond1 = T.ref_nom_r(i) > r_nom_low;
		cond2 = T.ref_nom_r(i) < r_nom_high;
		cond3 = T.ref_mr_r2(i) > r_2;
		cond4 = abs(T.ref_mr(i)) > mr_low;
		working_ref(i) = cond1 && cond2 && cond3;
		% save working data
		if working_ref(i)
			Data_working_ref(end+1,:) = T.row_data{i}(2,:);
			Pointer_working_ref(end+1, :) = [i j];
			R0_working_ref(end+1, 1) = T.ref_nom_r(i);
			MR_working_ref(end+1, 1) = T.ref_mr(i);
		end
	end

	w = sum(sum(working));
	a =  size(working);
	tot = a(1) * a(2);
	perc = num2str(w/tot*100, '%.3f');
	fprintf('%s%% Success Rate | %d / %d Working Sensors\n', perc, w, tot);

end