function str = sub_calc_compact_subplot_position(nv)
    % calculate position of subplot for compact plotting
    % only for split x directions (e.g. subplot(3,1,1))
    % params:
    %   nv: number of plots
    max_v = 0.9;
    min_v = 0.1;
    max_h = 0.95;
    min_h = 0.1;
    arry_v = linspace(min_v, max_v,nv+1);
    % disp(arry_v)
    ht = arry_v(2) - arry_v(1);
    str = [];
    for ii = 1:nv
        str(ii).pos = [min_h, arry_v(end-ii), max_h-min_h, ht];
    end
end