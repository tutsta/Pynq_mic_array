# Pynq-Z2 microphone array
Microphone array processor for the Pynq-Z2 board

## Build steps
1. Create project based on the PynqZ2 board file
2. Add the IP repository ```ip_repo``` (open the IP Catalog, right-click in the catalogue, select "Add Repository" and navigate to the ```ip_repo``` folder)
3. Add the design sources: ```fixed_spi.vhd```, ```rx_fifo.xci```, ```tx_fifo.xci```, ```PYNQ_Z2.xdc```
4. Create the block design by running ```top_block.tcl``` (Tools -> Run Tcl Script...)
5. Create an HDL wrapper for the block design (in th Sources tab under Hierarchy, right click the block design and select "Create HDL Wrapper...")
6. Make sure the generated wrapper is set as the top-level module (right-click and select "Set as Top...")
7. Run "Generate Bitstream"