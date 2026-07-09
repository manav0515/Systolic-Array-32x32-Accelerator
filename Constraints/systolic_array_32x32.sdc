create_clock -name CLK -period 9.5 [get_ports clk]

set_clock_uncertainty  0.15 [get_clocks CLK]
set_clock_transition   0.15 [get_clocks CLK]

set_input_delay 2.0 -clock CLK \
    [remove_from_collection [all_inputs] [get_ports clk]]

set_output_delay 2.0 -clock CLK [all_outputs]

set_driving_cell -lib_cell BUFX2 \
    [remove_from_collection [all_inputs] [get_ports clk]]

set_load 0.5 [all_outputs]

set_false_path -from [get_ports rst_n]
set_false_path -from [get_ports acc_clear]

set_max_transition 0.25 [current_design]
set_max_fanout     20   [current_design]
