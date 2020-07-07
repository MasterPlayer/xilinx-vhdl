# axis_loader_ss

Parametrizable copmponent for programming external FPGA over SlaveSerial mode. Supports AXI-Stream protocol. Component performs serialization of bit stream according with description from foloowong guides : 

* ug470_7Series_Config
* xapp583

Component supports different speeds for programming, and can work in sync/async mode. The width of `S_AXIS_TDATA` bus have some widths for choice. Component havent manual configuration compared with previous implementation. 

![axis_loader_ss_struct][axis_loader_ss_struct_reg]

[axis_loader_ss_struct_reg]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/documentation/axis_loader_ss_struct.png

## generic parameters
Parameter | Type | Valid range | Description
----------|------|-------------|------------
N_BYTES  | integer | 1,2,4,8,16,32 | width of data bus AXI-Stream
ASYNC_MODE | boolean | "true" or "false" | Asyncronous mode
WAIT_ABORT_LIMIT | integer | 0 - 2^31 | Timeout limit

## Ports

### AXI-Stream 

Component works based on AXI-Stream protocol, where component presented as Slave AXI-Stream. Signals of group `S_AXIS_*` are syncronous for signal `CLK` and `RESET`

Signal Name | Direction | Width | Description
------------|-----------|-------|------------
S_AXIS_TDATA | input | N_BYTES * 8 | data signal 
S_AXIS_TKEEP | input | N_BYTES | data byte valid signal 
S_AXIS_TVALID | input | 1 | data valid signal 
S_AXIS_TREADY | output | 1 | signal indicates for ready to receive the data from master
S_AXIS_TLAST | input | 1 | end of packet signal

### Signal for clocking and resetting

The signals CLK and CLK_SS can be connected to one source of CLK signal. In this case set `ASYNC_MODE = false`

Signal name | Direction | Width | Description
------------|-----------|-------|------------
CLK | input | 1 | clock signal for `S_AXIS_*` bus 
RESET | input | 1 | reset signal syncronous for `CLK` signal 
CLK_SS | input | 1 | clock signal for internal logic and SlaveSerial bus. With this signal data on SlaveSerial bus is clocked, and clock signal transferred from CLK_SS source without division

### Status signals

Signal name | Direction | Width | Description
------------|-----------|-------|------------
STS_PROG_GOOD | output | 1 | programming is completed successfully because external FPGA assert `DONE` signal.
STS_PROG_FAIL | output | 1 | programming is completed with error because external FPGA not assert `DONE` signal for `WAIT_ABORT_LIMIT` interval

### SlaveSerial signals

Name | Direction | width | Description
---------|-------------|-------------|-----------
CCLK | output | 1 | clock signal for external FPGA. The source of this signal is inverted `CLK_SS`
DIN | output | 1 | data signal of bitstream file for external FPGA. Obtained by serializing of the input stream
DONE | input | 1 | signal which indicates about external FPGA finishing programming process without errors
INIT_B | input | 1 | signal which indicates about external FPGA ready to be programmable
PROG_B | output | 1 | reset signal for external FPGA with following programing process

## The principles of work
- Component supports AXI-Stream
- Component allow upload bitstream to FPGA under clock domain which different from domain for AXI-Stream bus
- Component ignores `S_AXIS_TLAST` signal. It allows to download bitstream for several transactions of AXI-Stream.
- The completion of transaction is either a timeout (accompainied by the flaq `STS_PROG_FAIL`), or signal `DONE = 1` (accompanied by the flaq `STS_PROG_GOOD`);
- Component supports `S_AXIS_TKEEP` signal
- Component perform simple serialization of data to single bit stream
- Pause over packets, when bitstream fragmented over several AXI-Stream transactions, should not exceed `WAIT_ABORT_LIMIT` value in clocks
- Component establish `CCLK` only when transmitting data. `CCLK` is taken from the inverse on the `CLK_SS` signal. 
- Component allows programming FPGA as fast as it possible for CLK_SS. No internal delays. `CLK_SS` is not divided for establish as `CCLK` signal
- if no data in AXI-Stream bus, component transit to wait state(if firmware is not upload fully), or waiting signal `DONE = 1`.
- Input stream was swapped for bytes. 
- Component works based upon internal finite state machine(FSM)

### Swap byte illustration

![axis_loader_rsh_fsm][axis_loader_ss_rsh_ref]

[axis_loader_ss_rsh_ref]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/documentation/axis_loader_ss_rsh.png

## Finite state machine

## FSM graph

Structure of finite state machine presented on following picture

![axis_loader_ss_fsm][axis_loader_ss_fsm_ref]

[axis_loader_ss_fsm_ref]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/documentation/axis_loader_ss_fsm.png

### FSM states

Current state | Next state | Transition condition
------------------|---------------------|-----------------
WAIT_PROG_ST      | RESET_FPGA_ST       | in_empty = 0 (input queue is not empty)
RESET_FPGA_ST     | WAIT_FOR_INITB_ST   | INIT_B = 0 (external FPGA allows programming)
WAIT_FOR_INITB_ST | PROG_FPGA_ST        | INIT_B = 1 (external FPGA allows upload bitstream)
PROG_FPGA_ST      | WAIT_DATA_ST        | bit_cnt = cnt_limit_reg and in_empty = 1 (limit of bit counter exceeded and input queue is empty)
WAIT_DATA_ST      | WAIT_PROG_ST        | DONE = 1 (received signal from external FPGA about successful upload firmare)
WAIT_DATA_ST      | PROG_FPGA_ST        | in_empty = 0(input queue is not empty)
WAIT_DATA_ST      | WAIT_PROG_ST        | wait_abort_cnt = WAIT_ABORT_LIMIT

### Timing diagram for visualize signals of SlaveSerial group

The diagram of normal work of component is presented on following picture

![axis_loader_ss_normal][axis_loader_ss_normal_ref]

[axis_loader_ss_normal_ref]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_loader_ss/documentation/axis_loader_ss_normal.png

### Required external components

Component name | Description
-------------------|---------
[fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) | syncronous fifo queue primitive for support Slave AXI-Stream protocol
[fifo_in_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_async_xpm/fifo_in_async_xpm.vhd) | Asyncronous fifo queue primitive for support Slave AXI-Stream protocol
[rst_syncer](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/syncronizers/rst_syncer.vhd) | Reset syncronization unit for `ASYNC_MODE = true`


## Change log

**1. 25.09.2019 : v1.0 - first version**
- Support for 2-byte AXI-Stream bus,  `S_AXIS_TLAST` and `S_AXIS_TKEEP` ignored

**2. 03.10.2019 : v1.1 - changes for component**
- Add support (1/2/4/8 bytes) for data bus 
- Add support `S_AXIS_TKEEP`
- Add sync primitive for reset signal if `ASYNC_MODE = true`

**3. 03.07.2020 : v1.2 - changes for component**
- Remove manual control for transit to `IDLE_ST` (signal `PROG_DONE`)
- Optimize FSM, remove state `WAIT_DONE_ST`
- Add status ports (`STS_PROG_GOOD` and `STS_PROG_FAIL`)
- Corrected description and catalog structure
- Add support for 16/32 bytes for data bus