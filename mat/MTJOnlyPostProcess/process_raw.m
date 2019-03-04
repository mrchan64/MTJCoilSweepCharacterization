function process_raw(savename, lin_range); % !!!IMPORTANT!!! lin_range is OPTIONAL parameter
  %
  % FUNCTION to process the row_data struct and output
  % 1. nominal_res    (Nominal Resistance {row value}(column value))
  % 2. calculated_mr  (MR {row value}(column value))
  % 3. mr_r2          (r^2 value {row value}(column value))
  % 4. r_max          (max data val {row value}(column value))
  % 5. r_min          (min data val {row value}(column value))
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

  % finds index
  cutind = find(T.fields(1:ceil(end/2))<=field_linear_range, 1, 'last');
  lin_fit_inds = cutind - 1; % for the off by one in matrix

  nominal_res = {};
  calculated_mr = {};
  mr_r2 = {};
  mr_perc = {};
  r_off_max = {};
  r_max = {};
  r_min = {};

  % sweep rows
  counter = 1;
  for row = data
    r = row{1};

    n_r = [];
    c_m = [];
    m_r = [];
    m_p = [];
    r_o = [];
    r_a = [];
    r_i = [];

    % non-reference
    for i = 1:7

      % check for N/A sensors (counter = array 8-11), (i = row 5-7)
      if counter > 7 && i > 4
        n_r(end+1) = -1;
        c_m(end+1) = -1;
        m_r(end+1) = -1;
        m_p(end+1) = -1;
        r_o(end+1) = -1;
        r_a(end+1) = -1;
        r_i(end+1) = -1;
        continue;
      end

      curr_dat = r(i,:);

      % nominal resistance non-reference
      n_r(end+1) = mean([curr_dat(1) curr_dat(end)]);

      % mr and r2 non-reference
      lr1 = fitlm(fields(1:1+lin_fit_inds), curr_dat(1:1+lin_fit_inds));
      lr2 = fitlm(fields(end-lin_fit_inds:end), curr_dat(end-lin_fit_inds:end));

      m1 = lr1.Coefficients.Estimate(2);
      m2 = lr2.Coefficients.Estimate(2);
      r1 = lr1.Rsquared.Ordinary;
      r2 = lr2.Rsquared.Ordinary;

      % verify similarity
      if m1 * m2 > 0 
        c_m(end+1) = mean([m1 m2]);
        m_r(end+1) = mean([r1 r2]);
      else
        c_m(end+1) = 0;
        m_r(end+1) = 0;
      end

      % mr percentage
      m_p(end+1) = c_m(end) / n_r(end);

      % max nominal res offset
      r_o(end+1) = range([curr_dat(1) curr_dat(end)]);

      % maximum and minimum of range of sensor
      r_a(end+1) = max(curr_dat);
      r_i(end+1) = min(curr_dat);

    end

    % change to percentage
    r_o = r_o ./ n_r;

    nominal_res{end+1} = n_r;
    calculated_mr{end+1} = c_m;
    mr_r2{end+1} = m_r;
    mr_perc{end+1} = m_p;
    r_off_max{end+1} = r_o;
    r_max{end+1} = r_a;
    r_min{end+1} = r_i;

    counter = counter+1;

  end

  save(savename, 'field_linear_range', 'nominal_res', 'calculated_mr', 'mr_r2', 'mr_perc', 'r_off_max', 'r_max', 'r_min', '-append')

  fprintf('Execution time: %.3fs\n', toc);

end