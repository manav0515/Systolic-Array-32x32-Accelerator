#==============================================================
# Synopsys IC Compiler II - Script 02: Library & Netlist Read
# File: 02_netlist_read.tcl
#==============================================================

source ../Scripts/systolic/01_setup.tcl

#--------------------------------------------------------------
# 2a. Create in-memory library with SAED32 NDM
#--------------------------------------------------------------

create_lib \
    -ref_lib $PDK_PATH/lib/ndm/saed32rvt_c.ndm \
    SYSTOLIC_LIB5

#--------------------------------------------------------------
# 2b. Read synthesised gate-level netlist
#--------------------------------------------------------------

read_verilog $NETLIST_FILE \
    -library SYSTOLIC_LIB5 \
    -design  $DESIGN_NAME \
    -top     $DESIGN_NAME

#--------------------------------------------------------------
# 2c. Link and constrain
#--------------------------------------------------------------

link_block
read_sdc $SDC_FILE

#--------------------------------------------------------------
# 2d. Pre-placement design check
#--------------------------------------------------------------

check_design -checks pre_placement_stage \
    > $REPORTS_DIR/check_design_pre_place.rpt

save_block
save_lib

puts "INFO: Netlist read and design linked successfully."
start_gui
