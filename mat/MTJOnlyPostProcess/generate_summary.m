function generate_summary(savename_f, savename_r, savename_processed, working)

	T1 = load(savename_f);
	T2 = load(savename_r);

	num_arrays = length(T1.row_data);

	R0_avg = zeros(1, num_arrays);
	R0_std = zeros(1, num_arrays);
	MR_avg = zeros(1, num_arrays);
	MR_std = zeros(1, num_arrays);
	Ros_avg = zeros(1, num_arrays);
	MR_sensor_avg = zeros(1, num_arrays);
	MR_sensor_std = zeros(1, num_arrays);

	% For Array 1-7 find statistics if more than 4/7 working sensors
	for i = 1:7
		if sum(working(i,:)) >=4
			row_work_r0 = mean([T1.nominal_res{i}(working(i,:)); T2.nominal_res{i}(working(i,:))]);
			row_work_mr = mean([T1.mr_perc{i}(working(i,:)); -T2.mr_perc{i}(working(i,:))]);
			row_work_ro = mean([T1.r_off_max{i}(working(i,:)); T2.r_off_max{i}(working(i,:))]);
			min_ = min([T1.r_min{i}(working(i,:)); T2.r_min{i}(working(i,:))]);
			max_ = min([T1.r_max{i}(working(i,:)); T2.r_max{i}(working(i,:))]);
			row_work_mr_sensor = (max_ - min_) ./ min_;
			R0_avg(i) = mean(row_work_r0);
			R0_std(i) = std(row_work_r0);
			MR_avg(i) = mean(row_work_mr);
			MR_std(i) = std(row_work_mr);
			Ros_avg(i) = mean(row_work_ro);
			MR_sensor_avg(i) = mean(row_work_mr_sensor);
			MR_sensor_std(i) = std(row_work_mr_sensor);
		end
	end

	% For Array 8- 11, we are leaving out sensors 5-7 so find statistics if more than 2/4 working sensors
	for i = 8:11
		if sum(working(i,:)) >=2
			row_work_r0 = mean([T1.nominal_res{i}(working(i,:)); T2.nominal_res{i}(working(i,:))]);
			row_work_mr = mean([T1.mr_perc{i}(working(i,:)); -T2.mr_perc{i}(working(i,:))]);
			row_work_ro = mean([T1.r_off_max{i}(working(i,:)); T2.r_off_max{i}(working(i,:))]);
			min_ = min([T1.r_min{i}(working(i,:)); T2.r_min{i}(working(i,:))]);
			max_ = min([T1.r_max{i}(working(i,:)); T2.r_max{i}(working(i,:))]);
			row_work_mr_sensor = (max_ - min_) ./ min_;
			R0_avg(i) = mean(row_work_r0);
			R0_std(i) = std(row_work_r0);
			MR_avg(i) = mean(row_work_mr);
			MR_std(i) = std(row_work_mr);
			Ros_avg(i) = mean(row_work_ro);
			MR_sensor_avg(i) = mean(row_work_mr_sensor);
			MR_sensor_std(i) = std(row_work_mr_sensor);
		end
	end

	% make MR_avg and MR_sensor positive
	MR_avg = abs(MR_avg);
	MR_sensor_avg = abs(MR_sensor_avg);

	% save the summary
	save(savename_processed,'R0_avg','R0_std','MR_avg','MR_std','Ros_avg','MR_sensor_avg','MR_sensor_std');

	% Plot
	figure;
	subplot(2,1,1);
	hold on;
	box on;
	bar(R0_avg.*1e-3);
	errorbar(R0_avg.*1e-3,R0_std.*1e-3,'.','LineWidth',2);
	xlim([0.5 11.5]);
	xlabel('Sensor Array','FontSize',18);
	ylabel('R0 (kOhm)','FontSize',18);
	set(gca,'FontSize',18);
	subplot(2,1,2);
	bar(Ros_avg.*100);
	xlim([0.5 11.5]);
	xlabel('Sensor Array','FontSize',18);
	ylabel('Offset (%)','FontSize',18);
	set(gca,'FontSize',18);
	set(gcf,'color','w');

	figure;
	subplot(2,1,1);
	hold on;
	box on;
	bar(MR_avg.*100);
	errorbar(MR_avg.*100,MR_std.*100,'.','LineWidth',2);
	xlim([0.5 11.5]);
	xlabel('Sensor Array','FontSize',18);
	ylabel('MR (%/Oe)','FontSize',18);
	set(gca,'FontSize',18);
	set(gcf,'color','w');
	subplot(2,1,2);
	hold on;
	box on;
	bar(MR_sensor_avg.*100);
	errorbar(MR_sensor_avg.*100,MR_sensor_std.*100,'.','LineWidth',2);
	xlim([0.5 11.5]);
	xlabel('Sensor Array','FontSize',18);
	ylabel('MR sensor (%)','FontSize',18);
	set(gca,'FontSize',18);
	set(gcf,'color','w');
