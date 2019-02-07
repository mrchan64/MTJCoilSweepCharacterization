function write_html_table(savename)

  T = load(savename);

  r_nom_low = 1e3;
  r_nom_high = 6e3;
  mr_low = 1e-1;
  r_2 = 0.9;
  
  % css styling
  style_header = '<style>table{height:100%}div{position:absolute;right:5px;top:5px;padding:15px;border:1px solid #000;background-color:rgba(255,255,255,.9)}div>span{padding:2px}thead tr{display:block}td,th{width:120px;text-align:center;padding:0 5px;position:relative;border:1px solid #000}tbody{display:block;height:100%;overflow:auto}td.row-title,th{background-color:#c96;color:#fff;font-weight:400}red{background-color:red;color:#fff}blue{background-color:#00f;color:#fff}yellow{background-color:orange;color:#fff}purple{background-color:purple;color:#fff}.green{background-color:#0f0}</style>';

  % legend
  legend_data = '<div><span>Non-Reference Sensors:</span><br><span><red>Low R0 Sensors:</red> %d</span><br><span><yellow>High R0 Sensors:</yellow> %d</span><br><span><purple>Low MR Sensors:</purple> %d</span><br><span><blue>Low R2 Sensors:</blue> %d</span><br><span><span class=green>Working Sensors:</span> %d/%d</span><br>Survival Rate: %.2f%%</div>';

  lor0 = '<red>%s</red>';         % red
  hir0 = '<yellow>%s</yellow>';   % yellow
  lomr = '<purple>%s</purple>';   % purple
  lor2 = '<blue>%s</blue>';       % blue

  l_br = '<br>';

  table = '<table>%s</table>';
  tbody = '<tbody>%s</tbody>';
  thead = '<thead>%s</thead>';
  t_row = '<tr>%s</tr>';
  t_col = '<td>%s</td>';
  t_hdr = '<th>%s</th>';

  t_col_header = '<td class="row-title">%s</td>';
  t_col_good = '<td class="green">%s</td>';

  theadint = '';
  theadrowint = sprintf(t_hdr, '');
  for i = 1:7
    theadrowint = [theadrowint sprintf(t_hdr, ['AI' num2str(i)])];
  end
  theadrowint = [theadrowint sprintf(t_hdr, 'Ref')];
  theadint = sprintf(t_row, theadrowint);

  num_lor0 = 0;
  num_hir0 = 0;
  num_lomr = 0;
  num_lor2 = 0;
  num_good = 0;
  num_total = 0;

  tbodyint = '';
  a = length(T.nominal_res);
  for i = 1:a

    t_rowint = '';

    t_rowint = [t_rowint sprintf(t_col_header, T.row_title{i})];

    b = length(T.nominal_res{i});
    for j = 1:b

      t_colint = '';
      res = [num2str(T.nominal_res{i}(j)/1000, '%.2f') 'kOhm'];
      mr = [num2str(T.calculated_mr{i}(j), '%.3f') 'Ohm/Oe'];
      r2 = num2str(T.mr_r2{i}(j), '%.3f');

      cond1 = T.nominal_res{i}(j) > r_nom_high;
      cond2 = T.nominal_res{i}(j) < r_nom_low;
      cond3 = abs(T.calculated_mr{i}(j)) < mr_low;
      cond4 = T.mr_r2{i}(j) < r_2;

      if cond1
        num_hir0 = num_hir0 + 1;
        t_colint = [t_colint sprintf(hir0, res)];
      elseif cond2
        num_lor0 = num_lor0 + 1;
        t_colint = [t_colint sprintf(lor0, res)];
      else
        t_colint = [t_colint res];
      end

      t_colint = [t_colint l_br];

      if cond3
        num_lomr = num_lomr + 1;
        t_colint = [t_colint sprintf(lomr, mr)];
      else
        t_colint = [t_colint mr];
      end

      t_colint = [t_colint l_br];

      if cond4
        num_lor2 = num_lor2 + 1;
        t_colint = [t_colint sprintf(lor2, r2)];
      else
        t_colint = [t_colint r2];
      end

      if ~(cond1 || cond2 || cond3 || cond4)
        num_good = num_good + 1;
        m = t_col_good;
      else
        m = t_col;
      end
      num_total = num_total + 1;

      t_rowint = [t_rowint sprintf(m, t_colint)];

    end

    % reference

    t_colint = '';
    res = [num2str(T.ref_nom_r(i)/1000, '%.2f') 'kOhm'];
    mr = [num2str(T.ref_mr(i), '%.3f') 'Ohm/Oe'];
    r2 = num2str(T.ref_mr_r2(i), '%.3f');

    cond1 = T.ref_nom_r(i) > r_nom_high;
    cond2 = T.ref_nom_r(i) < r_nom_low;
    cond3 = abs(T.ref_mr(i)) < mr_low;
    cond4 = T.ref_mr_r2(i) < r_2;

    if cond1
      t_colint = [t_colint sprintf(hir0, res)];
    elseif cond2
      t_colint = [t_colint sprintf(lor0, res)];
    else
      t_colint = [t_colint res];
    end

    t_colint = [t_colint l_br];

    if cond3
      t_colint = [t_colint sprintf(lomr, mr)];
    else
      t_colint = [t_colint mr];
    end

    t_colint = [t_colint l_br];

    if cond4
      t_colint = [t_colint sprintf(lor2, r2)];
    else
      t_colint = [t_colint r2];
    end

    if ~(cond1 || cond2 || cond3 || cond4)
      m = t_col_good;
    else
      m = t_col;
    end
    t_rowint = [t_rowint sprintf(m, t_colint)];

    % form body

    tbodyint = [tbodyint sprintf(t_row, t_rowint)];

  end

  legendfill = sprintf(legend_data, [num_lor0 num_hir0 num_lomr num_lor2 num_good num_total (num_good/num_total*100)]);
  tableall = sprintf(table, [sprintf(thead, theadint) sprintf(tbody, tbodyint)]);
  totalstr = [style_header tableall legendfill];

  f1 = fopen([savename '.html'], 'w');
  fprintf(f1, '%s', totalstr);
  fclose(f1);

end

