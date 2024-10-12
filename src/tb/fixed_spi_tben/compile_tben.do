# set the Modelsim working library directory name
set work_lib work
set common common_lib

# Create and/or map the libraries
vlib $work_lib
vmap $work_lib $work_lib

# Reset the testbench file list
set vhdl_file_list ""

# Xilinx IP sim files
lappend vhdl_file_list ../mic_array/mic_array.gen/sources_1/ip/rx_fifo/synth/rx_fifo.vhd
lappend vhdl_file_list ../mic_array/mic_array.gen/sources_1/ip/tx_fifo/synth/tx_fifo.vhd

# Design files
lappend vhdl_file_list ../fixed_spi.vhd

# Testbench files
lappend vhdl_file_list fixed_spi.vgen
lappend vhdl_file_list fixed_spi.tben

# Compile the testbench files
foreach i $vhdl_file_list {
    puts "vcom -2002 -work $work_lib $i"
    vcom -2002 -work $work_lib $i
}
