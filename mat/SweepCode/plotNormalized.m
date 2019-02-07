function plotNormalized(savename);
	T = load(savename);

	num_curves = length(T.curve_title);
	figure('WindowState', 'Maximized');
	for i =  1:7
		subplot(2, 4, i);
		cla
		dat_ind = i*2-1;
		hold on
		for j = 1:num_curves
			newdat = T.curve_data{j}(dat_ind, :);
			newdat = newdat - mean(newdat);
			plot(T.fields, newdat);
		end
		hold off
		ylabel('Ohms')
		xlabel('Oe')
		legend(T.curve_title);
		title(['AI' num2str(i)]);
	end

end