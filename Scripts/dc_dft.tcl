##################################################
# DFT - Scan Insertion Script
# Runs AFTER dc.tcl completes
# Based on your working FIFO DFT flow
##################################################

set project_path /home/student/Documents/Manav

set_host_options -max_cores 8

##################################################
# Libraries — same as dc.tcl
##################################################

set_app_var target_library "saed32rvt_ss0p7vn40c.db"
set_app_var link_library   "* saed32rvt_ss0p7vn40c.db"

set_app_var search_path [list . \
    $project_path/Design \
    /home/student/Downloads/Workshop/ref/lib/stdcell_rvt \
]

file mkdir $project_path/Report/systolic/dft
file mkdir $project_path/Output/systolic/dft

##################################################
# Read synthesised netlist from dc.tcl output
##################################################

read_verilog $project_path/Output/systolic/systolic_array_32x32_mapped.vg

current_design systolic_array_32x32
link

##################################################
# Re-apply constraints
##################################################

source $project_path/Design/systolic_array_32x32.sdc

##################################################
# Scan Configuration
# 8 chains — matches your 8-core setup
# More chains = faster test = better coverage
##################################################

set_scan_configuration \
    -style         multiplexed_flip_flop \
    -chain_count   8

##################################################
# Define existing DFT signals
##################################################

# Clock — same name as your SDC
set_dft_signal \
    -view existing_dft \
    -type ScanClock \
    -port clk \
    -timing {45 55}

# Reset — held inactive during scan
set_dft_signal \
    -view existing_dft \
    -type Reset \
    -port rst_n \
    -active_state 0

# acc_clear held low during test
set_dft_signal \
    -view existing_dft \
    -type Constant \
    -port acc_clear \
    -active_state 0

##################################################
# Define scan spec ports
# These match the ports added to the RTL
##################################################

set_dft_signal \
    -view spec \
    -type ScanEnable \
    -port test_se \
    -active_state 1

set_dft_signal \
    -view spec \
    -type ScanDataIn \
    -port test_si

set_dft_signal \
    -view spec \
    -type ScanDataOut \
    -port test_so

##################################################
# Create test protocol and DRC check
##################################################

create_test_protocol

dft_drc > $project_path/Report/systolic/dft/dft_drc_pre.rpt

##################################################
# Compile with scan
##################################################

compile -scan

##################################################
# Preview scan before insertion
##################################################

preview_dft > $project_path/Report/systolic/dft/preview_dft.rpt

##################################################
# Insert scan chains
##################################################

insert_dft
compile_ultra -incremental -no_autoungroup

##################################################
# Post-insertion DRC
##################################################

dft_drc > $project_path/Report/systolic/dft/dft_drc_post.rpt

##################################################
# Reports
##################################################

report_scan_path \
    -view existing \
    -cell all \
    > $project_path/Report/systolic/dft/scan_path.rpt

report_area \
    > $project_path/Report/systolic/dft/area_post_dft.rpt

report_power \
    -analysis_effort low \
    > $project_path/Report/systolic/dft/power_post_dft.rpt

##################################################
# Write DFT netlist — this goes into ICC2
# Replace the original mapped.vg with this
##################################################

write_file \
    -format    verilog \
    -hierarchy \
    -output    $project_path/Output/systolic/dft/systolic_dft.vg

write_test_protocol \
    -output $project_path/Output/systolic/dft/systolic_scan.spf

write_sdc \
    $project_path/Output/systolic/dft/systolic_dft.sdc

echo "DFT Insertion Complete."
#exit
