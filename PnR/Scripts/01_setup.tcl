#==============================================================
# Synopsys IC Compiler II - Script 01: Setup & Environment
# File: 01_setup.tcl
#==============================================================

set DESIGN_NAME  "systolic_array_32x32"

set NETLIST_FILE "/home/student/Documents/Manav/Output/systolic/dft/systolic_dft.vg"
set SDC_FILE     "/home/student/Documents/Manav/Output/systolic/dft/systolic_dft.sdc"

# PDK / library paths
set PDK_PATH     "/home/student/Documents/Manav/RTL2GDSII/Workshop/ref"
set LIB_DIR      "$PDK_PATH/lib/stdcell_rvt"
set TECH_DIR     "$PDK_PATH/tech"

# Output directories
set OUTPUT_DIR   "../systolic_outputs"
set REPORTS_DIR  "../systolic_reports"

file mkdir $OUTPUT_DIR
file mkdir $REPORTS_DIR

puts "INFO: Setup complete for design: $DESIGN_NAME"
