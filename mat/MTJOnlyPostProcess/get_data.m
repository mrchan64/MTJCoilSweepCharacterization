function [R0_all, MR_all, Ros_all] = get_data(savename_f, savename_r)
	% FUNCTION to get data

	T1 = load(savename_f);
	T2 = load(savename_r);

	% result data
	R0_all = [];
	MR_all = [];
    Ros_all = [];

	a = length(T1.nominal_res);
	for i = 1:a
		b = length(T1.nominal_res{i});
		for j = 1:b
			dat_ind = j;
			R0_all(i,j) = mean([T1.nominal_res{i}(j) T2.nominal_res{i}(j)]);
			MR_all(i,j) = mean([T1.mr_perc{i}(j) -T2.mr_perc{i}(j)]);
            Ros_all(i,j) = mean([T1.r_off_max{i}(j) T2.r_off_max{i}(j)]);
		end
	end

end


