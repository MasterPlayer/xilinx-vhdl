# axis_loader_ss

## Description

component for programming external Xilinx FPGA device in Slave Serial mode with support AXI-Stream interface with manual control and AXI-Stream interface
TLAST doesn't support and ignored in this implementation. This module writing with recomendations, which enumerated in next documents. 

This module manual-controlled. it means what if bitstream file was fully transmitted, user must send signal over `PROG_DONE` pin for complete transmit bitstream and transit finite state machine to analyze `DONE` signal from external FPGA. 

Module supports asyncronous or syncronous mode.

* ug470_7Series_Config
* xapp583

![module_name][logo0]

## GENERIC

1) `WAIT_ABORT_LIMIT` - number of clock periods for wait `DONE` signal from FPGA. if `DONE` signal doesn't asserted for this time, finite state machine returns to initial state for wait new data 
2) `ASYNC_MODE` - use sync/async mode for programming interface and S_AXIS_* bus
3) `N_BYTES` - number of bytes for axi-stream bus.

## PORTS 

### Inputs
* `CLK` - clock interface for S_AXIS_ bus
* `CLK_SS` - clock interface for internal logic and SlaveSerial interface 
* `RESET` - reset signal for internal fifo and logic
* `PROG_DONE` - signal for switching state from transition bitstream state or wait for data from S_AXIS_ bus to wait DONE signal from external FPGA 


### AXI-Stream Slave interface 
**All Signals in CLK clock domain** 
* `S_AXIS_TDATA` - data input. Width configurable with `N_BYTES` parameter. Current version support modes 1/2/4/8 bytes data width
* `S_AXIS_TKEEP` - input signal indicate valid bytes in current word. Width configurabe width `N_BYTES` parameter, current version support modes 1/2/4/8 bits width for `TKEEP`
* `S_AXIS_TVALID` - data valid signal
* `S_AXIS_TLAST` - end of packet signal. Ignored in current implementation
* `S_AXIS_TREADY` - device might work with data and signaling of ability for receive data.

### SlaveSerial interface
**All signals in `CLK_SS` clock domain**
* `CCLK` - clock output to external fpga. clock period the same as CLK_SS, but inverted from CLK_SS
* `DIN` - bit output to external fpga, which corresponds bitstream. 
* `DONE` - input from external fpga, which signaling successful ending of programming when `DONE` = 1, or when `DONE` = 0 signaling about programming failed or not completed
* `INIT_B` - signal which used for response of beginning of program FPGA.
* `PROG_B` - signal for beginning of programming

## Constants 
1. `DATA_WIDTH` - width of data register in bits. With this parameter module perform calculations for fifo width and data bus width
2. `BIT_CNT_LIMIT` - limit for bit counter.  
3. `BIT_CNT_WIDTH` - width of bit counter, calculated from `BIT_CNT_LIMIT` constant.

## Registers
1. `r_in_dout_data` - this register perform bitshift. Most significant bit connected to output `DIN` for transmit data to external FPGA. 
2. `bit_cnt` - bit counter. Limit for counting depends on the word length
3. `clk_ss_sig` - clock signal same as `CLK_SS`. 
4. `prog_b_reg` - program_b register for transmit to external FPGA. 
5. `wait_abort_cnt` - counter for abortion wait for signal `DONE` in `WAIT_DONE_ST` state. 

## FSM description
this component include finite state machine. Following description of states:
1. `WAIT_PROG_ST` - state when fsm wait for input valid data from fifo. If fifo is empty, no transition on fsm. otherwise, if fifo is not empty, fsm goes to `RESET_FPGA_ST`
2. `RESET_FPGA_ST` - state where fsm perform reset on fpga through `PROG_B` signal. Transition to next state perform when `INIT_B = 1`.
3. `WAIT_FOR_INITB_ST` - in this state fsm waiting for complete reset FPGA through analyze `INIT_B` signal. If `INIT_B` signal asserted, fsm goes to `PROG_FPGA_ST` state.
4. `PROG_FPGA_ST` - in this state fsm perform reading input fifo data, serializing its data to bitstream and transmit over `DIN` signal. If bitstream completely downloaded into extrenal fpga, and user sended signal `PROG_DONE`, state machine transit to `WAIT_DONE_ST` state. Otherwise, if input fifo is empty, finite state machine goes to `WAIT_DATA_ST` state. 
5. `WAIT_DATA_ST` - in this state FSM waiting for data in input fifo or wait for assertion `PROG_DONE` signal. If fifo is not empty, then fsm transit to `PROG_FPGA_ST`. if `PROG_DONE` asserted, fsm transit to `WAIT_DONE_ST`. 
6. `WAIT_DONE_ST` - in this state fsm wait for DONE signal from FPGA for some time, which declared in `WAIT_ABORT_LIMIT`.

## FSM diagram
FSM diagram with transitions presented in following picture
![fsm][logo1]

## Diagram

`r_in_dout_data` register structure and how its work presented in following picture 
![shifter][logo2]

normal programming cycle presented on following picture
![norm][logo3]


## Related modules
1. `fifo_in_sync_xpm` - syncronous fifo which holded only data (S_AXIS_TDATA + S_AXIS_TKEEP + S_AXIS_TLAST)
2. `fifo_in_async_xpm` - asyncronous fifo which holded only data (S_AXIS_TDATA + S_AXIS_TKEEP + S_AXIS_TLAST)
3. `rst_syncer` - for syncronization reset signal when `ASYNC_MODE` is true

## Change log
1. 25.09.2019 : *v1.0* - first version, which support 2 byte AXI-Stream only, ignore `TLAST` and `TKEEP` signals. 
2. 03.10.2019 : *v1.1* - add multiple bus widths support (1/2/4/8 bytes width), add support for axi-stream `TKEEP` signal, add syncronization unit for rst signal. Add inversion for CCLK signal


[logo0]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/axis_loader_ss_struct.png
[logo1]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/axis_loader_ss_fsm.png
[logo2]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/axis_loader_ss_rsh.png
[logo3]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/axis_loader_ss_normal.png