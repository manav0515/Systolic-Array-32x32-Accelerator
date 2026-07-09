#==============================================================
# Synopsys IC Compiler II - Script 03: Floorplan
# File: 03_floorplan.tcl
#==============================================================

source ../Scripts/systolic/01_setup.tcl

open_lib  SYSTOLIC_LIB5
open_block $DESIGN_NAME

#--------------------------------------------------------------
# Floorplan
#--------------------------------------------------------------

initialize_floorplan \
    -core_utilization  0.60 \
    -core_offset       {5 5} \
    -coincident_boundary false

#--------------------------------------------------------------
# Pin Placement
#--------------------------------------------------------------

set_individual_pin_constraints \
    -ports [get_ports clk] \
    -sides 2

set_individual_pin_constraints \
    -ports [get_ports {rst_n acc_clear}] \
    -sides 1 \
    -pin_spacing_distance 2

set_individual_pin_constraints \
    -ports [get_ports {row_data[*]}] \
    -sides 1 \
    -pin_spacing_distance 1

set_individual_pin_constraints \
    -ports [get_ports {col_data[*]}] \
    -sides 4 \
    -pin_spacing_distance 1

set_individual_pin_constraints \
    -ports [get_ports {result_bus[*]}] \
    -sides 3 \
    -pin_spacing_distance 1

place_pins -self

#--------------------------------------------------------------
# Initial coarse placement
#--------------------------------------------------------------

create_placement \
    -floorplan \
    -effort high

#--------------------------------------------------------------
# Reports
#--------------------------------------------------------------

report_floorplan      > $REPORTS_DIR/floorplan.rpt
check_pin_placement   > $REPORTS_DIR/check_pin_placement.rpt
report_placement      > $REPORTS_DIR/placement.rpt

#--------------------------------------------------------------
# Save
#--------------------------------------------------------------

save_block -as SYSTOLIC_FP
save_lib

puts "INFO: Floorplan completed successfully."
start_gui
