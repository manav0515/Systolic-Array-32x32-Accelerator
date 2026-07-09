#==============================================================
# Synopsys IC Compiler II - Script 07: Routing
# Version: W-2024.09 (Clean Build)
# File: 07_route.tcl
#==============================================================

source ../Scripts/systolic/01_setup.tcl

open_lib   SYSTOLIC_LIB5
open_block systolic_cts

#--------------------------------------------------------------
# 7a. Global route options
#--------------------------------------------------------------
set_app_options -name route.global.timing_driven    -value true
set_app_options -name route.global.crosstalk_driven -value false

#--------------------------------------------------------------
# 7b. Track assignment options
#--------------------------------------------------------------
set_app_options -name route.track.timing_driven     -value true
set_app_options -name route.track.crosstalk_driven  -value true

#--------------------------------------------------------------
# 7c. Detail route options — VERIFIED W-2024.09 SYNTAX
#--------------------------------------------------------------
set_app_options -name route.detail.timing_driven                -value true
set_app_options -name route.detail.antenna                      -value true
set_app_options -name route.detail.antenna_fixing_preference    -value use_diodes
set_app_options -name route.detail.diode_libcell_names          -value */ANTENNA_RVT

#--------------------------------------------------------------
# 7d. Routing sequence
#--------------------------------------------------------------
route_global
route_track
route_detail

#--------------------------------------------------------------
# 7e. Hold fixing — W-2024.09 correct method
#--------------------------------------------------------------
# Note: Ensure CLK matches the exact name from your 'report_clocks' check
set_fix_hold [get_clocks CLK]

#--------------------------------------------------------------
# 7f. Post-route optimisation
#--------------------------------------------------------------
route_opt

#--------------------------------------------------------------
# 7g. Checks and reports
#--------------------------------------------------------------
check_routes \
    > $REPORTS_DIR/check_routes.rpt

report_timing \
    -delay max \
    -max_paths 10 \
    > $REPORTS_DIR/timing_post_route.rpt

report_timing \
    -delay min \
    -max_paths 10 \
    > $REPORTS_DIR/timing_hold_post_route.rpt

report_qor -summary \
    > $REPORTS_DIR/qor_post_route.rpt

report_congestion \
    > $REPORTS_DIR/congestion_post_route.rpt

#--------------------------------------------------------------
# 7h. Write intermediate outputs
#--------------------------------------------------------------
write_verilog \
    -output $OUTPUT_DIR/${DESIGN_NAME}.routed.v

write_sdc \
    -output $OUTPUT_DIR/${DESIGN_NAME}.routed.sdc

save_block -as systolic_routed
save_lib

puts "INFO: Routing complete successfully."
exit
