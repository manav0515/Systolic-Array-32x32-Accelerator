##################################################
# Multithreading — use 8 of your 12 cores
# Leave 4 free for OS + ICC2 later
##################################################

set_host_options -max_cores 8

##################################################
# Setup
##################################################

set project_path /home/student/Documents/Manav

set_app_var search_path [list . \
    $project_path/Design \
    /home/student/Downloads/Workshop/ref/lib/stdcell_rvt \
]

set_app_var target_library "saed32rvt_ss0p7vn40c.db"
set_app_var link_library   "* saed32rvt_ss0p7vn40c.db"

file mkdir $project_path/Report/systolic
file mkdir $project_path/Output/systolic

##################################################
# Read RTL
##################################################

analyze -format verilog $project_path/Design/pe.v
analyze -format verilog $project_path/Design/systolic_array_32x32.v

elaborate systolic_array_32x32
current_design systolic_array_32x32
link

##################################################
# Constraints
##################################################

source $project_path/Design/systolic_array_32x32.sdc

##################################################
# Design Checks
##################################################

check_design
check_timing

##################################################
# Compile — single compile_ultra is enough
# -retime dropped: retiming + muxed output
# is clean, no need for aggressive retiming
##################################################

compile_ultra -no_autoungroup

##################################################
# Reports
##################################################

report_area        > $project_path/Report/systolic/report_area.rpt
report_power       > $project_path/Report/systolic/report_power.rpt
report_timing      > $project_path/Report/systolic/report_timing.rpt
report_qor         > $project_path/Report/systolic/report_qor.rpt
report_constraints > $project_path/Report/systolic/report_constraints.rpt

##################################################
# Output
##################################################

write_file -format verilog \
    -hierarchy \
    -output $project_path/Output/systolic/systolic_array_32x32_mapped.vg

write_sdc \
    $project_path/Output/systolic/systolic_array_32x32_mapped.sdc

echo "DC Synthesis Complete."
exit
