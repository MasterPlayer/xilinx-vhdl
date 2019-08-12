# axis_arb_2_to_1

parametrized arbiter (`N_BYTES` as variable parameters)

Packets transmitted from two inputs to one output. 
inputs have equal priority. When packets arrive simultaneously, firstly transmitted packet for input, which analyze in current state of finite state machine. Packet from other input will be start to transmit only when packet for current channel transmit fully

`N_BYTES` - size of input and output AXI-Stream bus in bytes. 

Component include Xilinx parametrized macros(XPM), which presented in current component as output fifo (`fifo_out_sync_xpm`);

[source code of fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/fifo_parametrized/fifo_out_async_xpm)

![arbiter scheme][logo]

[logo]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_arb_2_to_1/axis_arb_2_to_1_v1.0.png "Logo Title Text 2"
