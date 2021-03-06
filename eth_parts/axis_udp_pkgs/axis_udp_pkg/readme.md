# axis_dump_gen

simplest parametrized data generator 

(`N_BYTES` and `ASYNC` as configurable parameters)

where

`N_BYTES` - size of output AXI-Stream bus in bytes. 
`ASYNC` - CDC(clock domain crossing) from internal logic to output AXI-Stream bus.

outout AXI-Stream bus supports TREADY, TLAST, TKEEP, where TKEEP always presented as '1' for all TKEEP vector length

Inputs:
1) `WORD_CNT_LIMIT` : limit for **number of words** in packet
2) `PAUSE` : pause between packets

Packet structure presented as array of 8 bit counters

example presented in picture

Component include Xilinx parametrized macros(XPM), which presented in current component as output fifo 
1) [`fifo_out_sync_xpm`](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) - for syncronous mode (`ASYNC = false`);
2) [`fifo_out_async_xpm`](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_xpm/fifo_out_async_xpm.vhd) - for asyncronous mode (`ASYNC = true`);

![arbiter scheme][logo]

[logo]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_dump_gen/axis_dump_gen.png
