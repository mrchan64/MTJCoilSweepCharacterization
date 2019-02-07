function reset_to_raw(savename)
  T = load(savename);

  row_data = T.row_data;
  fields = T.fields;
  row_title = T.row_title;

  save(savename, 'row_data', 'fields', 'row_title');