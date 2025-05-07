function [E_tick_list, E_tick_pos] = generate_E_ticks(E_vals, n_ticks)
    if nargin < 2
        n_ticks = 6;
    end

    tens_pos = islocalmin(E_vals-floor(E_vals/10)*10);
    fives_pos = islocalmin(E_vals-floor(E_vals/5)*5);
    twos_pos = islocalmin(E_vals-floor(E_vals/2)*2);
    ones_pos = islocalmin(E_vals-floor(E_vals));
    halfs_pos = islocalmin(E_vals-floor(E_vals/0.5)*0.5);
    fifths_pos = islocalmin(E_vals-floor(E_vals/0.2)*0.2);
    tenths_pos = islocalmin(E_vals-floor(E_vals/0.1)*0.1);

    
    all_subdivs = {tens_pos, fives_pos, twos_pos, ones_pos, halfs_pos, fifths_pos, tenths_pos};
    indices = [];
    used = tens_pos;

    for i = 1:7
        if i ~= 1
            remaining = all_subdivs{i}-used;
            remaining(remaining<0)=0;
            indices = [indices find(remaining)];
            used = used + all_subdivs{i};
        else
            indices = [indices find(all_subdivs{i})];
        end
    end

    E_tick_pos = indices(1:n_ticks);
    E_tick_pos = sort(E_tick_pos);

    E_tick_list = round(E_vals(E_tick_pos), 1);
end