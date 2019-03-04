function [R0_all, MR_all, Ros_all] = get_data(savename_f, savename_r)
	% FUNCTION to get data

	T1 = load(savename_f);
	T2 = load(savename_r);

	R0_all = (cell2mat(T1.nominal_res') + cell2mat(T2.nominal_res')) ./ 2;
	MR_all = (cell2mat(T1.calculated_mr') - cell2mat(T2.calculated_mr')) ./ 2;
	Ros_all = (cell2mat(T1.r_off_max') + cell2mat(T2.r_off_max')) ./ 2;

end


