function working_polar_table(savename_f, savename_r, working, working_ref);

	T1 = load(savename_f);
	T2 = load(savename_r);

	% NOM RESISTANCE
	data = {};
	a = length(T1.nominal_res);
	for i = 1:a;
		data{end+1} = (T1.nominal_res{i} + T2.nominal_res{i})./2;
	end

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

	data = (T1.ref_nom_r + T2.ref_nom_r)/2;
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
	data = {};
	for i = 1:a(1);
		data{i} = (T1.calculated_mr{i} - T2.calculated_mr{i})/2;
	end

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

	data = (T1.ref_mr-T2.ref_mr)/2;
	uidata = [uidata num2cell(data')];
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
	tab.RowName = T1.row_title;
	tab.ColumnName = col_title;
	tab.CellSelectionCallback = {@show_plot, savename_f, savename_r};
	f.Visible = 'On';

	w = sum(sum(working));
	a =  size(working);
	tot = a(1) * a(2);
	perc = num2str(w/tot*100, '%.3f');
	fprintf('%s%% Success Rate | %d / %d Working Sensors Combined\n', perc, w, tot);
end

function show_plot(table, event, savename_f, savename_r)
	pause(.4);
	i = event.Indices(1);
	j = mod(event.Indices(2),8);
	T1 = load(savename_f);
	T2 = load(savename_r);
	if j==0;
		data = [T1.row_data{i}(2,:) T2.row_data{i}(2,:)];
		res = (T1.ref_nom_r(i) + T2.ref_nom_r(i))/2;
		mr = (T1.ref_mr(i) - T2.ref_mr(i))/2;
		r2 = (T1.ref_mr_r2(i) + T2.ref_mr_r2(i))/2;
		title_str = [T1.row_title{i} ' Ref \color{blue}R_n=' num2str(res/1000, '%.2f') 'k\Omega \color{black}MR=' num2str(mr) '\Omega/Oe \color{blue}r^2=' num2str(r2, '%.3f')];
	else
		data = [T1.row_data{i}(j*2-1,:) T2.row_data{i}(j*2-1,:)];
		res = (T1.nominal_res{i}(j) + T2.nominal_res{i}(j))/2;
		mr = (T1.calculated_mr{i}(j) - T2.calculated_mr{i}(j))/2;
		r2 = (T1.mr_r2{i}(j) + T2.mr_r2{i}(j))/2;
		title_str = [T1.row_title{i} ' AI' num2str(j) ' \color{blue}R_n=' num2str(res/1000, '%.2f') 'k\Omega \color{black}MR=' num2str(mr) '\Omega/Oe \color{blue}r^2=' num2str(r2, '%.3f')];
	end
	if strcmp(table.Parent.SelectionType, 'open')
		figure
		plot([T1.fields -T2.fields], data);
		title(title_str);
		xlabel('Oe')
		ylabel('Ohms')
	end
end