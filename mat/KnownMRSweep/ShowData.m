function ShowData(savename)
	T = load(savename);

	Vb = .1;
	R1 = 1.5e3;
	R2 = 42.2e3;
	Vcm = 1.65;
	data = T.row_data{1};
	T.row_data{1} = (R2*Vb*R1)./(R1.*(Vcm-data)+R2.*Vb);

	figure('Name', 'Known MR Sensor');
	hold on;

	a = size(T.row_data{1});
	titles = {};

	for i = 1:a(1)
		plot(T.fields, T.row_data{1}(i,:));
		titles{end+1} = ['Row ' num2str(i)];
	end
	hold off;

	legend(titles)
	xlabel('Oe');
	ylabel('Ohms');
	title('Known MR Sensor 8 rows');

	figure('Name', 'Known MR Sensor (normalized)');
	hold on;

	a = size(T.row_data{1});
	titles = {};

	for i = 1:a(1)
		plot(T.fields, T.row_data{1}(i,:) - T.row_data{1}(i,1));
		titles{end+1} = ['Row ' num2str(i)];
	end
	hold off;

	legend(titles)
	xlabel('Oe');
	ylabel('Ohms');
	title('Known MR Sensor 8 rows (normalized)');

	figure('Name', 'Known MR Sensor (normalized row1-6,8)');
	hold on;

	a = size(T.row_data{1});
	titles = {};

	for i = 1:a(1)
		if i == 7
			continue
		end
		plot(T.fields, T.row_data{1}(i,:) - T.row_data{1}(i,1));
		titles{end+1} = ['Row ' num2str(i)];
	end
	hold off;

	legend(titles)
	xlabel('Oe');
	ylabel('Ohms');
	title('Known MR Sensor 7 rows (normalized row1-6,8)');

	figure('Name', 'Known MR Sensor (row1-6,8)');
	hold on;

	a = size(T.row_data{1});
	titles = {};

	for i = 1:a(1)
		if i == 7
			continue
		end
		plot(T.fields, T.row_data{1}(i,:));
		titles{end+1} = ['Row ' num2str(i)];
	end
	hold off;

	legend(titles)
	xlabel('Oe');
	ylabel('Ohms');
	title('Known MR Sensor 7 rows (row1-6,8)');

end