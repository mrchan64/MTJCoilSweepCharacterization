function reorg_data(savename);

  T = load(savename);
  fields = T.HA;

  a = size(T.Rstep1);
  row_title = {'Array 1', 'Array 2', 'Array 3', 'Array 4', 'Array 5', 'Array 6', 'Array 7', 'Array 8', 'Array 9', 'Array 10', 'Array 11'};
  % row_data = {T.Rstep1', T.Rstep2', T.Rstep3', T.Rstep4', T.Rstep5', T.Rstep6', T.Rstep7'};

  T.Rstep1 = T.Rstep1 .* 1000;
  T.Rstep2 = T.Rstep2 .* 1000;
  T.Rstep3 = T.Rstep3 .* 1000;
  T.Rstep4 = T.Rstep4 .* 1000;
  T.Rstep5 = T.Rstep5 .* 1000;
  T.Rstep6 = T.Rstep6 .* 1000;
  T.Rstep7 = T.Rstep7 .* 1000;

  row_data = {};
  for i = 1:a(2)
    temp_dat = [T.Rstep1(:,i)'; T.Rstep2(:,i)'; T.Rstep3(:,i)'; T.Rstep4(:,i)'; T.Rstep5(:,i)'; T.Rstep6(:,i)'; T.Rstep7(:,i)'];
    row_data{end+1} = temp_dat;
  end

  save(savename, 'fields', 'row_title', 'row_data');