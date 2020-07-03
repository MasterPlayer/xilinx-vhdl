# xilinx-vhdl

-------------

## axis_infrastructure

Include some modules, description, testbench files for components, which work with AXI-Stream interface
№ | Name | Description 
--|------|------------
1 | [axis_dump_gen](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen) | data generator with Master AXI-Stream interface for output data 
2 | [axis_checker](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_checker) | checking unit for input stream with Slave AXI-Stream interface for input stream
3 | [axis_collector](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_collector) | component for accumulate, hold, ordering and transmission data. 
4 | [axis_arb_2_to_1](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_arb_2_to_1) | 2-to-1 AXI-Stream arbiter with equal priority over inputs and ring survey
5 | [axis_pkt_sw_2_to_1](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_pkt_sw_2_to_1) | 2 to 1 AXI-Stream arbiter with accumulation packets, equal priority over both inputs and ring survey 
6 | [axis_loader_ss](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_loader_ss) | Component for programming FPGA over SlaveSerial protocol

-------------

## fifo_parametrized 

Include fifo primitives for instantiate them to other component for flexibility configuration

№ | Name | Description 
--|------|------------
1 | [fifo_out_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_xpm/fifo_out_async_xpm.vhd) | Asyncronous fifo for realize as Master AXI Stream
2 | [fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | Syncronous fifo for realize as Master AXI Stream
3 | [fifo_out_sync_xpm_id](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm_id/fifo_out_sync_xpm_id.vhd) | Syncronous fifo for realize as Master AXI Stream with support TID field
4 | [fifo_cmd_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_async_xpm/fifo_cmd_async_xpm.vhd) | Asyncronous fifo for realize command support
5 | [fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | Syncronous fifo for realize command support 
6 | [fifo_in_pkt_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_pkt_sw/fifo_in_pkt_sw.vhd) | Syncronous fifo for accumulate packets 
7 | [fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) | Syncronous fifo for implement Slave AXI-Stream
8 | [fifo_in_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_async_xpm/fifo_ain_sync_xpm.vhd) | Asyncronous fifo for implement Slave AXI-Stream


-------------

## ram_parametrized

include RAM primitives for instantiate them to other components for flexibility configuration

№ | Name | Description 
--|------|------------
1 | [sdpram](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/ram_parametrized/sdpram_xpm) | single port RAM with configurable parameters
2 | [tdpram](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/ram_parametrized/tdpram_xpm/tdpram_xpm.vhd) | true dual port RAM with configurable parameters

------------------

## syncronizers

Include components, wrappers for syncronization CDC signals
№ | Name | Description 
--|------|------------
1 | [rst_syncer](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/syncronizers/rst_syncer.vhd)  | reset signal syncronization unit
