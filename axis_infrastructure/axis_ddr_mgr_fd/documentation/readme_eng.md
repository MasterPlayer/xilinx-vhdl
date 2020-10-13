# axis_ddr_mgr_fd

Parametrizable component for realize ability read/write operations with memory over AXI-Stream bus. Memory must work with AXI-Full interface

Component Supports parametrization address width, data width and size of burst-transactions 

![axis_ddr_mgr_fd_struct][axis_ddr_mgr_fd_struct_reg]

[axis_ddr_mgr_fd_struct_reg]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_ddr_mgr_fd/documentation/axis_ddr_mgr_fd_struct.png

## generic parameters
Parameter | Type | Valid range | Description
---------|-----|-------------------|---------
ADDR_WIDTH | integer | >0 | Address width for AXI-Full interface
DATA_WIDTH | integer | >0 | Data bus width  for AXI-Stream/AXI-Full interface
BURST_LIMIT | integer | >0 | Maximal size BURST-transactions

## Ports 

### Clocks and resets 

Signal Name | Direction | Width | Description
------------|-----------|-------|-------------
CLK | input | 1 | Clock signal
RESET | input | 1 | Reset signal. Synced for CLK

Note : component doesnt support async mode. All signals clocked width CLK signal 

### Control signal 

Component supports only half-duplex mode. Simultaneous Reading and Writing Transactions are not possible

Signal Name | Direction | Width | Description
------------|-----------|-------|-------------
CMD_START_ADDRESS | input | ADDR_WIDTH | Start address of memory where perform reading or writing
CMD_SIZE | input | 64 | Size of data in bytes
CMD_MODE | input | 2 | Operation
CMD_VALID | input | 1 | Command valid signal  

### AXI-Stream 

Component works based on AXI-Stream 
Component presented as Slave AXI-Stream for write operation
Component presented as Master AXI-Stream for read operation
Component doesnt support TKEEP


#### AXI-Stream Slave

Needs only writing operation.

Signal Name | Direction | Width | Description
------------|-----------|-------|-------------
S_AXIS_TDATA | input | DATA_WIDTH | data signal for writing
S_AXIS_TVALID | input | 1 | data valid signal 
S_AXIS_TREADY | output | 1 | signal asserts when component can receive data for writing operation
S_AXIS_TLAST | input | 1 | last word in packet signal

#### AXI-Stream Master

Signal Name | Direction | Width | Description
------------|-----------|-------|-------------
M_AXIS_TDATA | output | DATA_WIDTH | data signal for reading operation
M_AXIS_TVALID | output | 1 | data valid signal 
M_AXIS_TREADY | input | 1 | signal asserts when other slave can receive data for reading data on bus
M_AXIS_TLAST | output | 1 | last word in packet signal 

### AXI-Full

Component supports AXI-Full interface

Компонент поддерживает интерфейс AXI-Full. 
Limitation for current realization is inability for reading and writing data in same time. 
It is due to fact that transactions sets for only one configuration bus, where selected operation to be done

Signal Name | Direction | Width | Description
------------|-----------|-------|-------------
M_AXI_AWADDR  | output | ADDR_WIDTH | Address bus for write operation
M_AXI_AWLEN   | output | 8 | Burst length 
M_AXI_AWSIZE  | output | 3 | Number of valid bytes. Selected according with data width
M_AXI_AWBURST | output | 2 | Burst type. Set as constant 0x01 (INCR burst type)
M_AXI_AWLOCK  | output | 1 | Unused signal 
M_AXI_AWCACHE | output | 4 | Unused signal 
M_AXI_AWPROT  | output | 3 | Unused signal 
M_AXI_AWVALID | output | 1 | signal for indicate valid address in bus
M_AXI_AWREADY | input  | 1 | signal which indicate that slave can receive address
M_AXI_WDATA   | output | DATA_WIDTH | data bus size
M_AXI_WSTRB   | output | DATA_WIDTH/8 | valid bytes in data bus. always in 1
M_AXI_WLAST   | output | 1 | end of burst transaction signal 
M_AXI_WVALID  | output | 1 | data valid signal 
M_AXI_WREADY  | input  | 1 | signal which indicate that slave can receive data
M_AXI_BRESP   | input  | 2 | response signal for write operation
M_AXI_BVALID  | input  | 1 | response signal valid for write operation
M_AXI_BREADY  | output | 1 | signal which indicates that master can read response
M_AXI_ARADDR  | output | ADDR_WIDTH | Address bus for read operation
M_AXI_ARLEN   | output | 8 | BURST-transaction length
M_AXI_ARSIZE  | output | 3 | number of valid bytes in word. selected according with data width
M_AXI_ARBURST | output | 2 | Burst type. Set as constant 0x01 (INCR burst type)
M_AXI_ARLOCK  | output | 1 | Unused signal 
M_AXI_ARCACHE | output | 4 | Unused signal 
M_AXI_ARPROT  | output | 3 | Unused signal 
M_AXI_ARVALID | output | 1 | signal for indicate valid address in bus for read operation
M_AXI_ARREADY | input  | 1 | signal which indicate that slave can receive address for read operation
M_AXI_RDATA   | input  | DATA_WIDTH | data signal from slave to master
M_AXI_RRESP   | input  | 2 | response signal for reading operation from slave to master
M_AXI_RLAST   | input  | 1 | end of packet(burst-transaction) signal 
M_AXI_RVALID  | input  | 1 | signal for data valid from slave
M_AXI_RREADY  | output | 1 | signal indicates that master can reseive data


## Some principles how component works

- Component works with two finite state machine (FSM): first FSM perform write operation, second FSM perform read operation
- FSM for read operation depends on FSM for write operation
- supports multiplicity for word on bus only. For example, if data bus have size 4 bytes, then we cant read 1 byte of data. 
- supports AXI4 burst transactions, 256 transmissions maximal
- supports TREADY signals. Lost of data is impossible
- Component cannot analyze the border address space of memory. Thus, when trying to read / write data from an address that goes beyond the boundaries of the address space, the result will be unpredictable and correct operation is not guaranteed.
- Consists of two component for realize AXI-Stream (Master and Slave) interface 
- Control for max burst assigned for developer
- Supports next operation modes 
- 

MODE | Operation | Description
-----|-----------|------------
0x00 | no op | Reserved
0x01 | Read | Reading N bytes from memory and transmit this data over `M_AXIS`
0x10 | Write | Writing N bytes from `S_AXIS` bus  to memory 
0x11 | Write and followed read | Performing write operation for N bytes and reading N bytes with using same start address for two cases

## Finite state machine for read operation

Work of component based upon two FSM, which of them perform one operation : read or write

### FSM for read operation

#### FSM diagram

![read_fsm_diag][read_fsm_diagram]

[read_fsm_diagram]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_ddr_mgr_fd/documentation/read_fsm_diag.png

#### States and transitions of readFSM 

current state | next state | transition condition | description
--------------|------------|----------------------|------------
IDLE_ST | WAIT_FOR_WRITE_ST | CMD_VALID = 1 & CMD_MODE = 11 | if component receives "write with followed read", then transit to state for waiting when write FSM is ending work
IDLE_ST | READ_ST | CMD_VALID = 1 & CMD_MODE = 01 | if component receives "read" mode signal then tranit to reading state
WAIT_FOR_WRITE_ST | READ_ST | current_state_write = IDLE_ST | if FSM for write ends work, then go to read state 
READ_ST | IDLE_ST | RVALID = 1 & RREADY = 1 RLAST = 1 and word_counter_read = 0 | if byte counter sets as 0 then go to idle state
READ_ST | WAIT_FOR_FIFO_ABILITY_RCV_ST | RVALID = 1 & RREADY = 1 & RLAST = 1 & out_pfull = 1 | if output fifo is full and cannot receive current portion of data, go to state where waiting for fifo free process
WAIT_FOR_FIFO_ABILITY_ST | READ_ST | out_pfull = 0 | if queue free size allows to receive current portion of data, then go to read data from memory

### Finite state machine for write operation

#### FSM diagram

![write_fsm_diag][write_fsm_diagram]

[write_fsm_diagram]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_ddr_mgr_fd/documentation/write_fsm_diag.png

#### States and transitions of WriteFSM

current state | next state | transition condition | description
--------------|------------|----------------------|------------
IDLE_ST | WAIT_FOR_DATA_ST | CMD_VALID = 1 & CMD_MODE(1) = 1 | if component receives write op then go to wait for data is writed to internal queue
WAIT_FOR_DATA_ST | WRITE_ST | in_empty = 0 & word_counter_write < (BURST_LIMIT-1) & (fifo_word_count >= word_counter_write or fifo_word_count >= BURST_LIMIT) | if internal queue having needed data, then go to write state
WRITE_ST | WRITE_WAIT_BRESP_ST | wvalid = 1 & wready = 1 & wlast = 1 | when burst transaction is finalized, go to wait for response from slave device
WRITE_WAIT_BRESP_ST | IDLE_ST | BVALID = 1 & BREADY = 1 & has_bresp_flaq = 1 & word_counter_write = 0 | if all data was writed, go to idle state
WRITE_WAIT_BRESP_ST | WRITE_ST | in_empty = 0 & word_counter_write < BURST_LIMIT & (fifo_word_count => word_counter_write or fifo_word_count => BURST_LIMIT) | if internal queue having data for perform burst, and not all data is writed, go to write state

### Required external components

Component | Description
----------|------------
[fifo_in_sync_counted_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_counted_xpm/fifo_in_sync_counted.vhd) | Syncronous FIFO queue width support Slave AXI-Stream with calculation actual data size in queue for correct work with burst-transaction. 
[fifo_out_pfull_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_pfull_sync_xpm/fifo_out_pfull_sync_xpm.vhd) | Syncronous FIFO queue with support Master AXI-Stream with pfull flaq asserion 

## Change log

**1. 22.07.2020 : v1.0 - First version**
- First release of component

**2. 13.10.2020 : v1.1 - Add description**
