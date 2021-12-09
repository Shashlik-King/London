function [focus] = focus_calculator(focus)

focus.total_mom = focus.moment .* focus.load_level .* focus.model;
focus.total_def = focus.def .* focus.load_level .* focus.model;
focus.total_defmud = focus.load_disp .* focus.load_level .* focus.model;

end