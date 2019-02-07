function [Data_working, Pointer_working, R0_working, MR_working, Data_working_ref, Pointer_working_ref, R0_working_ref, MR_working_ref] = working_table(savename)
	% FUNCTION to find working sensors and plot them on a table to see the relative success rate.
	T = load(savename);

	r_nom_low = 1e3;
	r_nom_high = 6e3;
	mr_low = 1e-1;
	r_2 = 0.9;

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
			Pointer_working_ref(end+1, :) = [i];
			R0_working_ref(end+1, 1) = T.ref_nom_r(i);
			MR_working_ref(end+1, 1) = T.ref_mr(i);
		end
	end

	w = sum(sum(working));
	a =  size(working);
	tot = a(1) * a(2);
	perc = num2str(w/tot*100, '%.3f');
	fprintf('%s%% Success Rate | %d / %d Working Sensors\n', perc, w, tot);

	% NOM RESISTANCE
	data = T.nominal_res;

	uidata = {};
	for row_dat = data
		uidata = [uidata; num2cell(row_dat{1})];
	end

	a = size(uidata);

	for i = 1:a(1)
		for j = 1:a(2)
			e = uidata{i,j};
			if working(i,j);
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
			else
				uidata{i,j} = [num2str(e/1000, '%.2f') 'k'];
			end
		end
	end

	col_title = {};
	for i = 1:7
		col_title{end+1} = ['ai' num2str(i) ' R_n'];
	end
	
	% NOM RESISTANCE REFERENCE

	data = T.ref_nom_r;
	uidata{1, end+1} = 0;

	a = length(data);
	for i = 1:a
		e = data(i);
		if working_ref(i)
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
		else
			uidata{i,end} = [num2str(e/1000, '%.2f') 'k'];
		end
	end

	col_title{end+1} = 'Ref R_n';


	% MR

	data = T.calculated_mr;
	uidata2 = {};

	for row_dat = data
		uidata2 = [uidata2; num2cell(row_dat{1})];
	end
	a = size(uidata2);
	for i = 1:a(1)
		for j = 1:a(2)
			e = uidata2{i,j};
			if working(i,j);
				uidata2{i,j} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e, '%.4f') '</TD></TR></table></html>'];
			else
				uidata2{i,j} = num2str(e, '%.4f');
			end
		end
	end
	uidata = [uidata uidata2];

	a = size(uidata);
	a = a(2);
	b = size(data);



	for i = 1:7
		col_title{end+1} = ['ai' num2str(i) ' MR'];
	end

	% MR REFERENCE

	data = T.ref_mr;
	uidata = [uidata num2cell(T.ref_mr')];
	a = size(uidata);
	for i = 1:a(1)
		e = data(i);
		if working_ref(i)
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e, '%.4f') '</TD></TR></table></html>'];
		else
			uidata{i,end} = num2str(e, '%.4f');
		end
	end
	col_title{end+1} = 'Ref MR';



	
	f=figure('Visible', 'Off');
	f.WindowState = 'Maximized';
	tab = uitable(f);
	tab.Units = 'Normalized';
	tab.Position = [0,0, 1,1];
	tab.Data = uidata;
	tab.RowName = T.row_title;
	tab.ColumnName = col_title;
	tab.CellSelectionCallback = {@show_plot, savename};
	f.Visible = 'On';
end

function show_plot(table, event, savename)
	pause(.4);
	i = event.Indices(1);
	j = mod(event.Indices(2),8);
	T = load(savename);
	if j==0;
		data = T.row_data{i}(2,:);
		title_str = [T.row_title{i} ' Ref \color{blue}R_n=' num2str(T.ref_nom_r(i)/1000, '%.2f') 'k\Omega \color{black}MR=' num2str(T.ref_mr(i)) '\Omega/Oe \color{blue}r^2=' num2str(T.ref_mr_r2(i), '%.3f')];
	else
		data = T.row_data{i}(j*2-1,:);
		title_str = [T.row_title{i} ' AI' num2str(j) ' \color{blue}R_n=' num2str(T.nominal_res{i}(j)/1000, '%.2f') 'k\Omega \color{black}MR=' num2str(T.calculated_mr{i}(j)) '\Omega/Oe \color{blue}r^2=' num2str(T.mr_r2{i}(j), '%.3f')];
	end
	if strcmp(table.Parent.SelectionType, 'open')
		T = load(savename);
		figure
		plot(T.fields, data);
		title(title_str);
		xlabel('Oe')
		ylabel('Ohms')
	end
end