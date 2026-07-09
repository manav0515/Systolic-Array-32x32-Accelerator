##################################################
# PrimeTime Signoff STA
# Corner: ss0p7vn40c — matches DC exactly
# Power: toggle-rate estimation, no SAIF
##################################################

set project_path /home/student/Documents/Manav
set PDK_PATH     "$project_path/RTL2GDSII/Workshop/ref"

set DESIGN_NAME  "systolic_array_32x32"
set RPT_DIR      "$project_path/Report/systolic/pt"
set OUT_DIR      "$project_path/Output/systolic"

file mkdir $RPT_DIR

##################################################
# Libraries — same corner as DC
##################################################

set_app_var target_library \
    "$PDK_PATH/lib/stdcell_rvt/saed32rvt_ss0p7vn40c.db"

set_app_var link_library \
    "* $PDK_PATH/lib/stdcell_rvt/saed32rvt_ss0p7vn40c.db"

set_app_var search_path [list . \
    $PDK_PATH/lib/stdcell_rvt \
]

##################################################
# Read final routed netlist from ICC2
##################################################

read_verilog $OUT_DIR/${DESIGN_NAME}_final.v

current_design $DESIGN_NAME
link_design

##################################################
# Apply final SDC from ICC2
##################################################

read_sdc $OUT_DIR/${DESIGN_NAME}_final.sdc

##################################################
# Back-annotate parasitics from ICC2 SPEF
##################################################

read_parasitics \
    -format spef \
    $OUT_DIR/${DESIGN_NAME}_final.spef

##################################################
# Operating conditions — worst case
##################################################

set_operating_conditions \
    -max saed32rvt_ss0p7vn40c \
    -library saed32rvt_ss0p7vn40c

##################################################
# Design checks
##################################################

check_timing \
    > $RPT_DIR/check_timing.rpt

##################################################
# Setup timing — max delay paths
##################################################

report_timing \
    -delay_type    max \
    -max_paths     50 \
    -nworst        5 \
    -path_type     full_clock_expanded \
    -input_pins \
    > $RPT_DIR/timing_setup.rpt

##################################################
# Hold timing — min delay paths
##################################################

report_timing \
    -delay_type    min \
    -max_paths     50 \
    -nworst        5 \
    -path_type     full_clock_expanded \
    -input_pins \
    > $RPT_DIR/timing_hold.rpt

##################################################
# Global timing summary
##################################################

report_global_timing \
    > $RPT_DIR/global_timing.rpt

##################################################
# Clock reports
##################################################

report_clock \
    > $RPT_DIR/clocks.rpt

report_clock_timing \
    -type summary \
    > $RPT_DIR/clock_summary.rpt

report_clock_timing \
    -type skew \
    > $RPT_DIR/clock_skew.rpt

report_clock_timing \
    -type latency \
    > $RPT_DIR/clock_latency.rpt

##################################################
# Constraint violations
##################################################

report_constraint \
    -all_violators \
    > $RPT_DIR/violations.rpt

##################################################
# Power — toggle rate estimation, no SAIF
# Default toggle rate: 0.1 (10% activity)
# Typical for systolic array during compute
##################################################

set_power_analysis_options \
    -default_toggle_rate 0.1 \
    -default_static_probability 0.5

update_power

report_power \
    -hierarchy \
    -levels 3 \
    > $RPT_DIR/power.rpt

##################################################
# QoR summary
##################################################

report_qor \
    > $RPT_DIR/qor.rpt

echo "============================================"
echo " PrimeTime STA Complete: $DESIGN_NAME"
echo " Reports in: $RPT_DIR"
echo "============================================"
exit
