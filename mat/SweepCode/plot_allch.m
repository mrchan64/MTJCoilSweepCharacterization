% test???
f = figure;
counter = 1;
while true
	plotting('Chip2_2_to_100.mat', counter, f);
	waitforbuttonpress
	key = get(gcf, 'currentkey');
	if strcmp(key,'leftarrow')
		counter = counter - 1;
	elseif strcmp(key,'rightarrow');
		counter = counter + 1;
	end
	if counter < 1
		counter = 1;
	end
	if counter > 50
		counter = 50;
	end
end


function plotting(savename, row, f)

	T = load(savename);

	mr = T.calculated_mr{row};
	nom_r = T.nominal_res{row};
	row_data = T.row_data{row};
	titles = T.row_title{row};
	fields = T.fields;
	if nargin > 2
		figure(f);
		f.WindowState = 'Maximized';
	else
		f = figure('WindowState', 'Maximized');
	end
	for i = 1:7
		subplot(2, 4, i);
		cla
		dat_ind = i*2-1;
		plot(fields, row_data(dat_ind, :));
		ylabel('Ohms')
		xlabel('Oe')
		title([titles ' AI' num2str(i) ' R_n=' num2str(nom_r(i)/1000, '%.2f') 'k\Omega MR=' num2str(mr(i)) '\Omega/Oe']);
	end

	subplot(2,4,8);
	cla
	plot(fields, row_data(2, :));
	title('Reference')
end