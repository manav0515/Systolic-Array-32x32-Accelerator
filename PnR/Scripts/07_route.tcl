#==============================================================
# Synopsys IC Compiler II - Script 07: Routing
# Version  : W-2024.09
# Design   : systolic_array_32x32
# Strategy : Maximum quality, bounded runtime
# Every option verified against installation reference file
#==============================================================

source ../Scripts/systolic/01_setup.tcl

open_lib   SYSTOLIC_LIB6
open_block systolic_cts

#--------------------------------------------------------------
# SECTION 1: COMMON — applies to all routing stages
# route.common.enable_multi_thread
#   Verified line 2902, default true
#   Explicit set ensures it's never accidentally off
#
# route.common.concurrent_redundant_via_mode
#   Verified line 2893, default off
#   Setting to 'revisit' inserts redundant vias during routing
#   improves reliability with small runtime cost
#
# route.common.concurrent_redundant_via_effort_level
#   Verified line 2892, default low — set to medium
#
# route.common.rc_driven_setup_effort_level
#   Verified line 2943, default medium — set to high
#   Improves RC-driven wire sizing for setup timing
#
# route.common.post_detail_route_fix_soft_violations
#   Verified line 2938, default false
#   Fixes soft rule violations after detail route
#   Small runtime cost, cleaner DRC output
#--------------------------------------------------------------

set_app_options -name route.common.enable_multi_thread \
    -value true

set_app_options -name route.common.concurrent_redundant_via_mode \
    -value revisit

set_app_options -name route.common.concurrent_redundant_via_effort_level \
    -value medium

set_app_options -name route.common.rc_driven_setup_effort_level \
    -value high

set_app_options -name route.common.post_detail_route_fix_soft_violations \
    -value true

#--------------------------------------------------------------
# SECTION 2: GLOBAL ROUTE
# route.global.timing_driven
#   Verified line 3081, default false — must enable
#
# route.global.effort_level
#   Verified line 3063, default medium
#   high = better congestion spreading before detail route
#   Reduces DRC iterations needed in detail route
#   Net runtime effect: positive (fewer detail iterations)
#
# route.global.crosstalk_driven
#   Verified line 3058, default false
#   Left false — SAED 32nm at 7.5ns has no SI closure risk
#   Enabling adds runtime with no benefit here
#
# route.global.timing_driven_effort_level
#   Verified line 3082, default high — already optimal
#   Explicit set for documentation clarity
#--------------------------------------------------------------

set_app_options -name route.global.timing_driven \
    -value true

set_app_options -name route.global.effort_level \
    -value high

set_app_options -name route.global.timing_driven_effort_level \
    -value high

#--------------------------------------------------------------
# SECTION 3: TRACK ASSIGNMENT
# route.track.timing_driven
#   Verified line 3086, default false — must enable
#   Timing-driven TA assigns critical nets to better tracks
#   Reduces setup violations entering detail route
#
# route.track.crosstalk_driven
#   Verified line 3085, default false
#   Left false — consistent with global, saves runtime
#--------------------------------------------------------------

set_app_options -name route.track.timing_driven \
    -value true

#--------------------------------------------------------------
# SECTION 4: DETAIL ROUTE
# route.detail.timing_driven
#   Verified line 3041, default false — must enable
#
# route.detail.diode_libcell_names
#   Verified line 2995 — specifies SAED32 antenna diode
#
# route.detail.antenna_fixing_preference
#   Verified line 2974, default hop_layers
#   hop_layers = router jumps to higher metal to fix antenna
#   This is the correct default — use_diodes was invalid
#   Diodes available as fallback via diode_libcell_names
#
# route.detail.drc_convergence_effort_level
#   Verified line 2997, default medium
#   high = more aggressive DRC fixing per iteration
#   Means fewer total iterations needed — net runtime win
#
# route.detail.force_max_number_iterations
#   Verified line 3006, default false
#   Leave false — router stops early if no progress detected
#   This is the smart early-exit mechanism — don't disable it
#
# route.detail.optimize_wire_via_effort_level
#   Verified line 3023, default low
#   medium = better wire/via optimization without heavy cost
#
# route.detail.optimize_tie_off_effort_level
#   Verified line 3022, default low — set medium
#--------------------------------------------------------------

set_app_options -name route.detail.timing_driven \
    -value true

set_app_options -name route.detail.diode_libcell_names \
    -value */ANTENNA_RVT

set_app_options -name route.detail.drc_convergence_effort_level \
    -value high

set_app_options -name route.detail.optimize_wire_via_effort_level \
    -value medium

set_app_options -name route.detail.optimize_tie_off_effort_level \
    -value medium

#--------------------------------------------------------------
# SECTION 5: ROUTING SEQUENCE
#
# route_global: verified lines 30, 46-204
#   No inline options needed — app options set above
#
# route_track: verified lines 38, 207-283
#   No arguments — man page explicitly states this
#
# route_detail: verified lines 26, 285-445
#   -max_number_iterations 40 = verified default (line 314)
#   Router stops at 40 OR when no progress detected
#   (force_max_number_iterations is false = smart exit on)
#   40 is sufficient — muxed output removes the routing cause
#   of previous infinite runs
#--------------------------------------------------------------

route_global
route_track
route_detail -max_number_iterations 40

#--------------------------------------------------------------
# SECTION 6: POST-ROUTE OPTIMISATION
# route_opt: verified lines 33, 447-475
#   Handles setup, hold, DRC, area, power automatically
#
# route_opt.flow.enable_ccd
#   Verified line 3102, default false
#   With +5.86ns setup slack, CCD not needed
#   Would add significant runtime — leave false
#
# route_opt.flow.enable_power
#   Verified line 3113, default true
#   Already on by default — power optimization included
#--------------------------------------------------------------

route_opt

#--------------------------------------------------------------
# SECTION 7: VERIFICATION AND REPORTS
# All commands and options verified against reference
#
# check_routes: verified lines 7, 477-755
#
# report_timing -delay_type: verified line 782
#   CRITICAL: option is -delay_type NOT -delay
#   -path_type full_clock_expanded: verified line 949
#   Shows full clock path — essential for hold debug
#
# report_qor: verified lines 1259-1441
#   -include: verified line 1288
#   Valid values: design_stats, electrical_drc, hold, setup
#   Reporting all four for complete picture
#
# report_congestion: verified lines 1444-1600
#   -mode hot_spot: verified line 1500
#   Shows congestion hotspots — more useful than summary
#--------------------------------------------------------------

check_routes \
    > $REPORTS_DIR/check_routes.rpt

report_timing \
    -delay_type    max \
    -max_paths     20 \
    -path_type     full_clock_expanded \
    > $REPORTS_DIR/timing_post_route_setup.rpt

report_timing \
    -delay_type    min \
    -max_paths     20 \
    -path_type     full_clock_expanded \
    > $REPORTS_DIR/timing_post_route_hold.rpt

report_qor \
    -include {design_stats electrical_drc hold setup} \
    > $REPORTS_DIR/qor_post_route.rpt

report_congestion \
    -mode hot_spot \
    > $REPORTS_DIR/congestion_post_route.rpt

#--------------------------------------------------------------
# SECTION 8: WRITE OUTPUTS
# write_verilog: verified lines 1960-2270
#   Filename is POSITIONAL — no -output flag
#
# write_sdc: verified lines 2272-2370
#   -output flag IS required here
#--------------------------------------------------------------

write_verilog \
    $OUTPUT_DIR/${DESIGN_NAME}.routed.v

write_sdc \
    -output $OUTPUT_DIR/${DESIGN_NAME}.routed.sdc

save_block -as systolic_routed
save_lib

puts "INFO: Routing complete — systolic_array_32x32"
exit
