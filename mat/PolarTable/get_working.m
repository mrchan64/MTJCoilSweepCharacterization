function [Data_working, Pointer_working, R0_working, MR_working, Data_working_ref, Pointer_working_ref, R0_working_ref, MR_working_ref] = get_working(savename_f, savename_r, working, working_ref)
	% FUNCTION to find working sensors and plot them on a table to see the relative success rate.

	T1 = load(savename_f);
	T2 = load(savename_r);

	% result data
	Data_working = [];
	Pointer_working = [];
	R0_working = [];
	MR_working = [];
	Data_working_ref = [];
	Pointer_working_ref = [];
	R0_working_ref = [];
	MR_working_ref = [];

	a = length(T1.nominal_res);
	for i = 1:a
		b = length(T1.nominal_res{i});
		for j = 1:b
			if working(i,j)
				dat_ind = j*2-1;
				Data_working(end+1,:) = [T1.row_data{i}(dat_ind,:) T2.row_data{i}(dat_ind,:)];
				Pointer_working(end+1, :) = [i j];
				R0_working(end+1, 1) = mean([T1.nominal_res{i}(j) T2.nominal_res{i}(j)]);
				MR_working(end+1, 1) = mean([T1.calculated_mr{i}(j) -T2.calculated_mr{i}(j)]);
			end
		end

		if working_ref(i)
			Data_working_ref(end+1,:) = [T1.row_data{i}(2,:) T2.row_data{i}(2,:)];
			Pointer_working_ref(end+1) = [i];
			R0_working_ref(end+1, 1) = mean([T1.ref_nom_r(i) T2.ref_nom_r(i)]);
			MR_working_ref(end+1, 1) = mean([T1.ref_mr(i) -T2.ref_mr(i)]);
		end
	end

end