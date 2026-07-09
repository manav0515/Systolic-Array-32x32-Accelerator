#==============================================================
# Synopsys IC Compiler II - Script 05: Placement
# File: 05_placement.tcl
#==============================================================

source ../Scripts/systolic/01_setup.tcl

#--------------------------------------------------------------
# 5a. Mode / corner / scenario
#--------------------------------------------------------------

remove_modes    -all
remove_corners  -all
remove_scenarios -all

create_mode    func
create_corner  nom
create_scenario -name func::nom -mode func -corner nom

current_mode     func
current_scenario func::nom

source $SDC_FILE

#--------------------------------------------------------------
# 5b. TLUPlus parasitics
#--------------------------------------------------------------

read_parasitic_tech \
    -tlup     $PDK_PATH/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus \
    -layermap $PDK_PATH/tech/star_rcxt/saed32nm_tf_itf_tluplus.map \
    -name     p1

read_parasitic_tech \
    -tlup     $PDK_PATH/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus \
    -layermap $PDK_PATH/tech/star_rcxt/saed32nm_tf_itf_tluplus.map \
    -name     p2

set_parasitic_parameters -late_spec p1 -early_spec p2

#--------------------------------------------------------------
# 5c. App options
#--------------------------------------------------------------

set_app_options -name place.coarse.continue_on_missing_scandef -value true

#--------------------------------------------------------------
# 5d. Placement
#--------------------------------------------------------------

place_pins -self
place_opt
legalize_placement

#--------------------------------------------------------------
# 5e. Reports
#--------------------------------------------------------------

check_legality -verbose \
    > $REPORTS_DIR/check_legality.rpt

report_timing -delay max -max_paths 10 \
    > $REPORTS_DIR/timing_post_place.rpt

report_qor -summary \
    > $REPORTS_DIR/qor_post_place.rpt

save_block -as systolic_placement
save_lib

puts "INFO: Placement complete."
