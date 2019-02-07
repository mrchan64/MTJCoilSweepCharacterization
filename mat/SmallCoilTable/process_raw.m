function process_raw(savename, lin_range); % !!!IMPORTANT!!! lin_range is OPTIONAL parameter
  %
  % FUNCTION to process the row_data struct and output
  % 1. nominal_res    (Nominal Resistance, non-reference {row value}(column value))
  % 2. ref_nom_r      (Nominal Resistance, reference (row value))
  % 3. calculated_mr  (MR, non-reference {row value}(column value))
  % 4. ref_mr         (MR, reference (row value))
  % 5. mr_r2          (r^2 value, non-reference {row value}(column value))
  % 6. ref_mr_r2      (r^2 value, reference (row value))
  %   I added in a condition to average out the mr values for going in and coming back
  %   and set mr to 0 and r2 to 0 if they are too far apart
  %
  % Takes in struct in savename
  % 1. row_data       (Raw Values, {row number}(AI number, field number))
  %                   the AI number goes up to 14 because it alternates between AI+ and AI-
  %                   the AI- columns should all be shorted to vin- on board
  %                   so AI1-7 are in rows 1, 3, 5, 7, 9, 11, 13
  %                   and the reference sensor is even rows
  % 2. fields         (Array of fields (field number))
  % 3. row_title      (Title of Rows, unused here)
  %
  % field_linear_range sets max magnetic field range to do linear fit
  tic;

  if nargin > 1
    % OVERRIDE PARAMETERS
    field_linear_range = lin_range;
  else
    % DEFAULT PARAMETERS
    field_linear_range = 10;
  end

  fprintf('MR and R^2 calculation up until %d Oe\n', field_linear_range);

  T = load(savename);
  data = T.row_data;
  fields = T.fields;

  % finds index, there should be 3 sections 1 short, 1 long, 1 short
  cutind = find(abs(T.fields(1:ceil(end/4)))<=field_linear_range, 1, 'last');
  lin_fit_inds = cutind - 1; % for the off by one in matrix

  nominal_res = {};
  ref_nom_r = [];
  calculated_mr = {};
  ref_mr = [];
  mr_r2 = {};
  ref_mr_r2 = [];

  % sweep rows
  for row = data
    r = row{1};

    n_r = [];
    c_m = [];
    m_r = [];

    % non-reference
    for i = 1:2:14
      curr_dat = r(i,:);
      midind = ceil(length(fields)/2);

      % nominal resistance non-reference
      n_r(end+1) = mean([curr_dat(1) curr_dat(midind) curr_dat(end)]);

      % mr and r2 non-reference (short long short)
      lr1 = fitlm(fields(1:1+lin_fit_inds), curr_dat(1:1+lin_fit_inds));
      lr2 = fitlm(fields(midind-lin_fit_inds:midind+lin_fit_inds), curr_dat(midind-lin_fit_inds:midind+lin_fit_inds));
      lr3 = fitlm(fields(end-lin_fit_inds:end), curr_dat(end-lin_fit_inds:end));

      m1 = lr1.Coefficients.Estimate(2);
      m2 = lr2.Coefficients.Estimate(2);
      m3 = lr3.Coefficients.Estimate(2);
      r1 = lr1.Rsquared.Ordinary;
      r2 = lr2.Rsquared.Ordinary;
      r3 = lr3.Rsquared.Ordinary;

      % verify similarity
      if m1 * m2 > 0 && m2 * m3 > 0 && m3 * m1 > 0;
        c_m(end+1) = mean([m1 m2 m3]);
        m_r(end+1) = mean([r1 r2 r3]);
      else
        c_m(end+1) = 0;
        m_r(end+1) = 0;
      end

    end

    nominal_res{end+1} = n_r;
    calculated_mr{end+1} = c_m;
    mr_r2{end+1} = m_r;

    % reference
    curr_dat = r(2,:);

    % nominal resistance reference
    ref_nom_r(end+1) = mean([curr_dat(1) curr_dat(midind) curr_dat(end)]);

    % mr and r2 reference
    lr1 = fitlm(fields(1:1+lin_fit_inds), curr_dat(1:1+lin_fit_inds));
    lr2 = fitlm(fields(midind-lin_fit_inds:midind+lin_fit_inds), curr_dat(midind-lin_fit_inds:midind+lin_fit_inds));
    lr3 = fitlm(fields(end-lin_fit_inds:end), curr_dat(end-lin_fit_inds:end));

    m1 = lr1.Coefficients.Estimate(2);
    m2 = lr2.Coefficients.Estimate(2);
    m3 = lr3.Coefficients.Estimate(2);
    r1 = lr1.Rsquared.Ordinary;
    r2 = lr2.Rsquared.Ordinary;
    r3 = lr3.Rsquared.Ordinary;

    % verify similarity
    if m1 * m2 > 0 && m2 * m3 > 0 && m3 * m1 > 0;
      ref_mr(end+1) = mean([m1 m2 m3]);
      ref_mr_r2(end+1) = mean([r1 r2 r3]);
    else
      ref_mr(end+1) = 0;
      ref_mr_r2(end+1) = 0;
    end

  end

  save(savename, 'field_linear_range', 'nominal_res', 'ref_nom_r', 'calculated_mr', 'ref_mr', 'mr_r2', 'ref_mr_r2', '-append')

  fprintf('Execution time: %.3fs\n', toc);

end