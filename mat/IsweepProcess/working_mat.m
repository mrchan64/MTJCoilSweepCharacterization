function [working, working_ref] = working_table(savename, rl, rh, ml, r2l, roh, mpl)
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

	if nargin > 5
		r_off_high = roh;
	else
		r_off_high = 1e10; % basically infinity
	end

	mpl_s = false;
	mr_perc_low = 0;
	if nargin > 6
		mr_perc_low = mpl;
		mpl_s = true;
	end

	working = [];
	% determine working
	a = length(T.nominal_res);
	for i = 1:a
		b = length(T.nominal_res{i});
		for j = 1:b
			cond1 = T.nominal_res{i}(j) > r_nom_low;
			cond2 = T.nominal_res{i}(j) < r_nom_high;
			cond3 = T.mr_r2{i}(j) > r_2;
			cond4 = (~mpl_s && (abs(T.calculated_mr{i}(j)) > mr_low)) || (mpl_s && (abs(T.mr_perc{i}(j)) > mr_perc_low));
			cond5 = T.r_off_max{i}(j) < r_off_high;
			working(i,j) = cond1 && cond2 && cond3 && cond4 && cond5;
		end
	end

	working_ref = [];
	a = length(T.ref_nom_r);
	for i = 1:a
		cond1 = T.ref_nom_r(i) > r_nom_low;
		cond2 = T.ref_nom_r(i) < r_nom_high;
		cond3 = T.ref_mr_r2(i) > r_2;
		cond4 = (~mpl_s && (abs(T.ref_mr(i)) > mr_low)) || (mpl_s && (abs(T.mr_perc_ref(i)) > mpl));
		cond5 = T.r_off_max_ref(i) < r_off_high;
		working_ref(i) = cond1 && cond2 && cond3 && cond4 && cond5;
		% save working data
	end

	w = sum(sum(working));
	a =  size(working);
	tot = a(1) * a(2);
	perc = num2str(w/tot*100, '%.3f');
	fprintf('%s%% Success Rate | %d / %d Working Sensors\n', perc, w, tot);

end