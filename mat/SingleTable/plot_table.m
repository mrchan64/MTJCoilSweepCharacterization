function plot_table(savename, alt)
	T = load(savename);


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
			if e>8e3;
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#33CCCC><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
			elseif e<=8e3 && e>6e3
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#00FFCC><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
			elseif e<=6e3 && e>1e3
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
			elseif e<=1e3 && e>.5e3
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
			else
				uidata{i,j} = ['<html><table border=0 width=400 bgcolor=#FF0000><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
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
		if e>8e3;
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#33CCCC><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
		elseif e<=8e3 && e>6e3
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#00FFCC><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
		elseif e<=6e3 && e>1e3
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#00FF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
		elseif e<=1e3 && e>.5e3
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
		else
			uidata{i,end} = ['<html><table border=0 width=400 bgcolor=#FF0000><TR><TD>' num2str(e/1000, '%.2f') 'k</TD></TR></table></html>'];
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
			uidata2{i,j} = [num2str(uidata2{i,j}, '%.4f')];
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
		uidata{i, end} = num2str(uidata{i, end}, '%.4f');
	end
	col_title{end+1} = 'Ref MR';

	% check for shuffle

	shuffle = false;
	if nargin > 1;
		shuffle = true;
		a = size(uidata);
		b = a(2)/2;
		n_uidata = {};
		n_col_title = {};
		for i = 1:b
			for j = 1:a(1)
				n_uidata{j,2*i-1} = uidata{j,i};
				n_uidata{j,2*i} = uidata{j,i+b};
			end
			n_col_title{2*i-1} = col_title{i};
			n_col_title{2*i} = col_title{i+b};
		end
		uidata = n_uidata;
		col_title = n_col_title;
	end



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
		title_str = [T.row_title{i} ' Ref R_n=' num2str(T.ref_nom_r(i)/1000, '%.2f') 'k\Omega MR=' num2str(T.ref_mr(i)) '\Omega/Oe'];
	else
		data = T.row_data{i}(j*2-1,:);
		title_str = [T.row_title{i} ' AI' num2str(j) ' R_n=' num2str(T.nominal_res{i}(j)/1000, '%.2f') 'k\Omega MR=' num2str(T.calculated_mr{i}(j)) '\Omega/Oe'];
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