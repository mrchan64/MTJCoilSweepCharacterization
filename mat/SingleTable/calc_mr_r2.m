function calc_mr_r2(savename)
	% FUNCTION for calculating mr curve's r^2

	T = load(savename);

	mr_r2 = {};
	ref_mr_r2 = [];

	data = T.row_data;

	for row = data;
		r = row{1};
		a = size(r);
		r_r2 = [];
		for i = 1:2:a(1);
			lr1 = fitlm(T.fields(1:15), r(i,1:15));
			lr2 = fitlm(T.fields(end-14:end), r(i,end-14:end));
			r_r2(end+1) = (lr1.Rsquared.Ordinary + lr2.Rsquared.Ordinary)/2;
			if lr1.Rsquared.Ordinary * lr2.Rsquared.Ordinary < 0
				r_r2(end) = 0;
			end
		end
		mr_r2{end+1} = r_r2;

		% ref
		lr1 = fitlm(T.fields(1:15), r(2,1:15));
		lr2 = fitlm(T.fields(end-14:end), r(2,end-14:end));
		r_r2 = (lr1.Rsquared.Ordinary + lr2.Rsquared.Ordinary)/2;
		ref_mr_r2(end+1) = r_r2;
		if lr1.Rsquared.Ordinary * lr2.Rsquared.Ordinary < 0
			ref_mr_r2(end) = 0;
		end
	end

	save(savename, 'mr_r2', 'ref_mr_r2', '-append');

end