function write_html_table(savename_f, savename_r, savename_html, rl, rh, ml, r2l, roh, mpl)

  tic;
  T1 = load(savename_f);
  T2 = load(savename_r);

  if nargin > 3
    r_nom_low = rl;
    r_nom_high = rh;
    mr_low = ml;
    r_2 = r2l;
  else
    r_nom_low = 1e3;
    r_nom_high = 6e3;
    mr_low = 1e-1;
    r_2 = 0.9;
  end

  if nargin > 6
    r_off_high = roh;
  else
    r_off_high = 1e10; % basically infinity
  end

  mpl_s = false;
  mr_perc_low = 0;
  if nargin > 6
    mr_perc_low = mpl;
    mpl_s = true;
  end
  
  % css styling
  style_header = '<style>table{height:100%}div{position:absolute;right:5px;top:5px;padding:15px;border:1px solid #000;background-color:rgba(255,255,255,.9)}div>span{padding:2px}thead tr{display:block}td,th{width:120px;text-align:center;padding:0 5px;position:relative;border:1px solid #000;user-select:none;cursor:pointer}tbody{display:block;height:100%;overflow:auto}td.row-title,th{background-color:#c96;color:#fff;font-weight:400}red{background-color:red}blue{background-color:#00f}yellow{background-color:orange}purple{background-color:purple}pink{background-color:pink}aqua{background-color:#0ff}aqua,blue,pink,purple,red,yellow{color:#fff;pointer-events:none}.green{background-color:#0f0}</style>';

  % legend
  legend_data_abs = '<div><span>Non-Reference Sensors:</span><br><span><red>Low R0 Sensors:</red> %d</span><br><span><yellow>High R0 Sensors:</yellow> %d</span><br><span><purple>Low MR Sensors:</purple> %d</span><br><span><blue>Low R2 Sensors:</blue> %d</span><br><span><aqua>High R0 Offset Sensors:</aqua> %d</span><br><span><span class=green>Working Sensors:</span> %d/%d</span><br>Survival Rate: %.2f%%</div>';
  legend_data_per = '<div><span>Non-Reference Sensors:</span><br><span><red>Low R0 Sensors:</red> %d</span><br><span><yellow>High R0 Sensors:</yellow> %d</span><br><span><pink>Low %%MR Sensors:</pink> %d</span><br><span><blue>Low R2 Sensors:</blue> %d</span><br><span><aqua>High R0 Offset Sensors:</aqua> %d</span><br><span><span class=green>Working Sensors:</span> %d/%d</span><br>Survival Rate: %.2f%%</div>';

  lor0 = '<red>%s</red>';         % red
  hir0 = '<yellow>%s</yellow>';   % yellow
  lomr = '<purple>%s</purple>';   % purple
  lor2 = '<blue>%s</blue>';       % blue
  lomp = '<pink>%s</pink>';       % pink
  lord = '<aqua>%s</aqua>';       % aqua

  l_br = '<br>';

  table = '<table>%s</table>';
  tbody = '<tbody>%s</tbody>';
  thead = '<thead>%s</thead>';
  t_row = '<tr>%s</tr>';
  t_col = '<td onclick="showGraph(%d,%d)">%s</td>';
  t_hdr = '<th>%s</th>';

  t_col_header = '<td class="row-title">%s</td>';
  t_col_good = '<td class="green" onclick="showGraph(%d,%d)">%s</td>';

  theadint = '';
  theadrowint = sprintf(t_hdr, '');
  for i = 1:7
    theadrowint = [theadrowint sprintf(t_hdr, ['Sens' num2str(i)])];
  end
  theadint = sprintf(t_row, theadrowint);

  num_lor0 = 0;
  num_hir0 = 0;
  num_lomr = 0;
  num_lor2 = 0;
  num_lord = 0;
  num_good = 0;
  num_total = 0;

  tbodyint = '';
  a = length(T1.nominal_res);
  for i = 1:a

    t_rowint = '';

    t_rowint = [t_rowint sprintf(t_col_header, T1.row_title{i})];

    b = length(T1.nominal_res{i});
    for j = 1:b

      % check for N/A sensor
      if T1.nominal_res{i}(j) == -1 && T1.calculated_mr{i}(j) == -1
        t_rowint = [t_rowint sprintf(t_col, i, j, 'N/A')];
        continue;
      end

      t_colint = '';
      res1 = [num2str(T1.nominal_res{i}(j)/1000, '%.2f') 'kOhm'];
      mr1 = [num2str(T1.calculated_mr{i}(j), '%.3f') 'Ohm/Oe'];
      r21 = num2str(T1.mr_r2{i}(j), '%.3f');
      res2 = [num2str(T2.nominal_res{i}(j)/1000, '%.2f') 'kOhm'];
      mr2 = [num2str(-T2.calculated_mr{i}(j), '%.3f') 'Ohm/Oe'];
      r22 = num2str(T2.mr_r2{i}(j), '%.3f');

      res = [num2str(mean([ T1.nominal_res{i}(j)/1000 T2.nominal_res{i}(j)/1000 ]), '%.2f') 'kOhm'];
      mr = [num2str(mean([ T1.calculated_mr{i}(j) -T2.calculated_mr{i}(j) ]), '%.3f') 'Ohm/Oe'];
      r2 = num2str(mean([ T1.mr_r2{i}(j) T2.mr_r2{i}(j) ]), '%.3f');
      mp = [num2str(mean([ T1.mr_perc{i}(j)*100 -T2.mr_perc{i}(j)*100 ]), '%.5f') '%/Oe'];
      rd = ['DCoff: ' num2str(mean([ T1.r_off_max{i}(j) T2.r_off_max{i}(j) ])*100, '%.2f') '%'];

      cond1 = T1.nominal_res{i}(j) > r_nom_high;
      cond2 = T1.nominal_res{i}(j) < r_nom_low;
      cond3 = (~mpl_s && (abs(T1.calculated_mr{i}(j)) < mr_low)) || (mpl_s && (abs(T1.mr_perc{i}(j)) < mr_perc_low));
      cond4 = T1.mr_r2{i}(j) < r_2;
      cond5 = T1.r_off_max{i}(j) > r_off_high;

      cond6 = T2.nominal_res{i}(j) > r_nom_high;
      cond7 = T2.nominal_res{i}(j) < r_nom_low;
      cond8 = (~mpl_s && (abs(T2.calculated_mr{i}(j)) < mr_low)) || (mpl_s && (abs(T2.mr_perc{i}(j)) < mr_perc_low));
      cond9 = T2.mr_r2{i}(j) < r_2;
      cond10 = T2.r_off_max{i}(j) > r_off_high;

      if cond1 || cond6
        num_hir0 = num_hir0 + 1;
        t_colint = [t_colint sprintf(hir0, res)];
      elseif cond2 || cond7
        num_lor0 = num_lor0 + 1;
        t_colint = [t_colint sprintf(lor0, res)];
      else
        t_colint = [t_colint res];
      end

      t_colint = [t_colint l_br];

      if cond3 || cond8
        num_lomr = num_lomr + 1;
        if ~mpl_s
          t_colint = [t_colint sprintf(lomr, mr)];
          t_colint = [t_colint l_br];
          t_colint = [t_colint mp];
        else
          t_colint = [t_colint mr];
          t_colint = [t_colint l_br];
          t_colint = [t_colint sprintf(lomp, mp)];
        end
      else
        t_colint = [t_colint mr];
        t_colint = [t_colint l_br];
        t_colint = [t_colint mp];
      end

      t_colint = [t_colint l_br];

      if cond4 || cond9
        num_lor2 = num_lor2 + 1;
        t_colint = [t_colint sprintf(lor2, r2)];
      else
        t_colint = [t_colint r2];
      end

      t_colint = [t_colint l_br];

      if cond5 || cond10
        num_lord = num_lord + 1;
        t_colint = [t_colint sprintf(lord, rd)];
      else
        t_colint = [t_colint rd];
      end

      if ~(cond1 || cond2 || cond3 || cond4 || cond5 || cond6 || cond7 || cond8 || cond9 || cond10)
        num_good = num_good + 1;
        m = t_col_good;
      else
        m = t_col;
      end
      num_total = num_total + 1;

      t_rowint = [t_rowint sprintf(m, i, j, t_colint)];

    end

    % form body

    tbodyint = [tbodyint sprintf(t_row, t_rowint)];

  end

  if mpl_s
    legend_data = legend_data_per;
  else
    legend_data = legend_data_abs;
  end
  legendfill = sprintf(legend_data, [num_lor0 num_hir0 num_lomr num_lor2 num_lord num_good num_total (num_good/num_total*100)]);
  tableall = sprintf(table, [sprintf(thead, theadint) sprintf(tbody, tbodyint)]);

  js_string = '';
  % mat to js for the row_data
  script_tag = '<script>%s</script>\n';
  data_store = 'var data = [%s];';
  data_row = '[%s],';
  data_unit = '%s,';

  a = length(T1.row_data);
  store_str = '';
  for r = 1:a
    row1 = T1.row_data{r};
    row2 = T2.row_data{r};
    row_str = '';
    for i = 1:7
      curve_str = '';
      datind = i;
      curr_curve1 = row1(datind,:);
      curr_curve2 = row2(datind,:);
      for point = curr_curve1
        curve_str = [curve_str sprintf(data_unit, num2str(point, '%.3f'))];
      end
      for point = curr_curve2
        curve_str = [curve_str sprintf(data_unit, num2str(point, '%.3f'))];
      end
      single_str = ['{curve:[' curve_str '],'...
      'r0:' num2str(T1.nominal_res{r}(i), '%.3f') ','...
      'mr:' num2str(T1.calculated_mr{r}(i), '%.6f') ','...
      'r2:' num2str(T1.mr_r2{r}(i), '%.2f') ','...
      'mrp:' num2str(T1.mr_perc{r}(i), '%.6f') ','...
      'r0off:' num2str(T1.r_off_max{r}(i), '%.3f')...
      '},'];
      row_str = [row_str single_str];
    end

    store_str = [store_str sprintf(data_row, row_str)];
  end

  data_store_fin = sprintf(data_store, store_str);
  js_string = [js_string sprintf(script_tag, data_store_fin)];

  % fields
  field_store = 'var fields = [%s];';
  field_str = '';
  for f = T1.fields;
    field_str = [field_str sprintf(data_unit, num2str(f))];
  end
  for f = T2.fields;
    field_str = [field_str sprintf(data_unit, num2str(-f))];
  end
  field_store_fin = sprintf(field_store, field_str);
  js_string = [js_string sprintf(script_tag, field_store_fin)];

  % row titles
  title_store = 'var titles = [%s];';
  title_str = '';
  title_unit = '"%s",';
  for r = 1:a
    title_str = [title_str sprintf(title_unit, T1.row_title{r})];
  end
  title_store_fin = sprintf(title_store, title_str);
  js_string = [js_string sprintf(script_tag, title_store_fin)];

  % add plotly
  plotly_tag = '<script id="plotly">%s</script>\n';
  plotly = sprintf(plotly_tag, fileread('plotly.min.js.txt'));
  js_string = [js_string plotly];

  % plotly_str = 'var plotly_str = "%s";';
  % plotly = sprintf(script_tag, sprintf(plotly_str, strrep(fileread('plotly.min.js'), '"', '\"')));
  % js_string = [js_string plotly];


  % js functions for opening graphs
  show_graph = sprintf(script_tag, fileread('showgraph.js.txt'));
  js_string = [js_string show_graph];



  totalstr = [style_header tableall legendfill js_string];


  f1 = fopen([savename_html '.html'], 'w');
  fprintf(f1, '%s', totalstr);
  fclose(f1);

  fprintf('HTML Write Time: %.3fs\n', toc);

end

