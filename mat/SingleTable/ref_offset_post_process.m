function ref_offset_post_process(savename)
  T = load(savename);

  a = length(T.row_data);

  mean_offset = {};
  std_dev = {};

  for i = 1:a
    b = size(T.row_data{i});
    row_mean = [];
    row_std = [];
    for j = 1:2:b(1)
      dat = T.row_data{i}(j,:) - T.row_data{i}(2,:);
      row_mean(end+1) = mean(dat);
      row_std(end+1) = std(dat);
    end
    mean_offset{end+1} = row_mean;
    std_dev{end+1} = row_std;
  end

  save(savename, 'mean_offset', 'std_dev', '-append')

end