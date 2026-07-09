#==============================================================
# Synopsys IC Compiler II - Script 04: Power Planning
# File: 04_power_planning.tcl
#==============================================================

source ../Scripts/systolic/01_setup.tcl

#--------------------------------------------------------------
# 4a. Create and connect PG nets
#--------------------------------------------------------------

create_net -power  {VDD}
create_net -ground {VSS}

connect_pg_net -all_blocks -automatic

#--------------------------------------------------------------
# 4b. Power / ground rings
#--------------------------------------------------------------

create_pg_ring_pattern core_ring_pattern \
    -horizontal_layer   M7 \
    -horizontal_width   0.8 \
    -horizontal_spacing 0.4 \
    -vertical_layer     M8 \
    -vertical_width     0.8 \
    -vertical_spacing   0.4

set_pg_strategy core_power_ring \
    -core \
    -pattern {{name: core_ring_pattern} {nets: {VDD VSS}} {offset: {1.0 1.0}}}

compile_pg -strategies core_power_ring

#--------------------------------------------------------------
# 4c. Power mesh
#--------------------------------------------------------------

create_pg_mesh_pattern mesh \
    -layers {
        {{vertical_layer:   M6} {width: 0.5}  {spacing: interleaving} {pitch: 4} {offset: 0.5}}
        {{horizontal_layer: M7} {width: 0.6}  {spacing: interleaving} {pitch: 4} {offset: 0.5}}
        {{vertical_layer:   M8} {width: 0.6}  {spacing: interleaving} {pitch: 4} {offset: 0.5}}
    }

set_pg_strategy core_mesh \
    -pattern {{pattern: mesh} {nets: VDD VSS}} \
    -core \
    -extension {stop: innermost_ring}

compile_pg -strategies core_mesh

#--------------------------------------------------------------
# 4d. Standard-cell power rails
#--------------------------------------------------------------

create_pg_std_cell_conn_pattern std_cell_rail \
    -layers    {M1} \
    -rail_width 0.06

set_pg_strategy rail_strat \
    -core \
    -pattern {{name: std_cell_rail} {nets: VDD VSS}}

compile_pg -strategies rail_strat

#--------------------------------------------------------------
# 4e. Connectivity check
#--------------------------------------------------------------

check_pg_connectivity > $REPORTS_DIR/pg_connectivity.rpt

save_block
save_lib

puts "INFO: Power planning complete."
