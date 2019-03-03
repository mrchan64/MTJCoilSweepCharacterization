function [Data_working, Pointer_working, R0_working, MR_working] = get_working(savename_f, savename_r, working)
	% FUNCTION to find working sensors and plot them on a table to see the relative success rate.

	T1 = load(savename_f);
	T2 = load(savename_r);

	% result data
	Data_working = [];
	Pointer_working = [];
	R0_working = [];
	MR_working = [];

	a = length(T1.nominal_res);
	for i = 1:a
		b = length(T1.nominal_res{i});
		for j = 1:b
			if working(i,j)
				dat_ind = j;
				Data_working(end+1,:) = [T1.row_data{i}(dat_ind,:) T2.row_data{i}(dat_ind,:)];
				Pointer_working(end+1, :) = [i j];
				R0_working(end+1, 1) = mean([T1.nominal_res{i}(j) T2.nominal_res{i}(j)]);
				MR_working(end+1, 1) = mean([T1.calculated_mr{i}(j) -T2.calculated_mr{i}(j)]);
			end
		end
	end

end