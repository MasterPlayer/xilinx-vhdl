# axis_data_delayer

Parametrizable component for removing data gaps inside packet after cdc transmission from slowest to fast clock domain without accumulating the packet and changing stream behaviour. 

Component structure:

![axis_data_delayer_structure][axis_data_delayer_structure_reg]

[axis_data_delayer_structure_reg]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_data_delayer/documentation/axis_data_delayer_struct.png


Diagram showing how component works:

![axis_data_delayer_beh][axis_data_delayer_beh_reg]

[axis_data_delayer_beh_reg]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_data_delayer/documentation/axis_data_delayer_behave.png


## generic
Param | Type | Valid range | Description
------|------|-------------|------------
DW | integer | >0 | Data width
DELAY | integer | >0 | Delay value from input to output
MEMTYPE | string | "auto"/"distributed"/"block" | Type of used memory for primitives
MAX_PKT_SIZE | integer | >16 | Max packet size

## Ports

### Clock and reset signals

Name | Direction | Width | Description
-----|-----------|-------|------------
CLK | input | 1 | Clock signal
RESET | input | 1 | Reset signal 

Note : component doesnt support async mode (cdc), all logic works in one clock domain

### Debug signals

signals for debugging, can be unused

Param | Direction | Width | Description
------|-----------|-------|------------
DBG_OVERLOAD_DATA | output | 1 | overload data fifo queue
DBG_OVERLOAD_TIMER | output | 1 | overload time samples fifo queue

### AXI-Stream 

Component works based on AXI-Stream protocol, but no support tready signal

#### AXI-Stream Slave

Param | Direction | Width | Description
------|-----------|-------|-----------
S_AXIS_TDATA | input | DW | data signal  
S_AXIS_TKEEP | input | DW/8 | data byte valid
S_AXIS_TVALID | input | 1 | valid signal 
S_AXIS_TLAST | input | 1 | packet boundary signal.

#### AXI-Stream Master

Param | Direction | Width | Description
------|-----------|-------|-----------
M_AXIS_TDATA | output | DW | data signal  
M_AXIS_TKEEP | output | DW/8 | data byte valid
M_AXIS_TVALID | output | 1 | valid signal 
M_AXIS_TLAST | output | 1 | packet boundary signal.


## Some principles how component works

- component includes two queues, one of which is intended for storing data, the other for storing meter readings
- Component works according finite state machine (FSM) and two counters. The purpose of first counter(timer_cnt_0) - write timestamp of the moment the first word arrives at the input (S_AXIS_). The purpose of second counter is designed to pause for `DELAY` value to read data. When second counter value is equal with stored in queue first counter value, transmission has started over `M_AXIS_` bus. 
- The order of operation `timer_cnt_0` : when the first word arrives on `S_AXIS_`, write him to time sample queue
- The order of operation `timer_cnt_1` : after reset the counter wait while `timer_cnt_0` < `DELAY`, if else, then counting
- Size of `DELAY` calculated according maximal packet size(`MAX_PKT_SIZE`) and number of clock periods how long this packet lasts in time(in ticks). For example : 
if maximal packet size is 1024 words, then `DELAY` doesnt can less than maximal size. If before component has cdc from slow(ex:50 Mhz) to fast(ex:156.25 MHz) clock domain, then `DELAY` parameter calculated for next equation : 

![delay_eqn_field][delay_eqn_field_reg]

[delay_eqn_field_reg]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_data_delayer/documentation/delay_eqn.png

For this case `DELAY` can be 3200 for fine transmission

- Size of queues sets according `MAX_PKT_SIZE`
- Interpacket pause must be 1 clock period or more 
- Component doesnt support TREADY signal 
- Component doesnt change data
- Component not holded data. 
- Data width is configurable
- Memtype might be set as `block`, `distributed` or `auto`

## FSM

### Граф-схема автомата 

![fsm_diag][fsm_diagram]

[fsm_diagram]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_data_delayer/documentation/fsm_diag.png

### FSM states 

Current state | Next State | Transition condition | Description
------------------|---------------------|------------------|----------
WAIT_ST | READ | timer_empty = 0 and timer_cnt_1 = timer_dout | if timestamp queue has data and second timer equal the first value in fifo queue, then go to transmission data state
READ | WAIT_ST | data_dout_last = 1 and timer_cnt_1 /= timer_dout | if end of packet transmitted, go to `WAIT_ST`


### required external components

Component name | Description
-------------------|---------
[fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) | Sync fifo queue with Slave AXI-Stream support. Main purpose - delaying data from input for pause = `DELAY`
[fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | Sync fifo queue for holding timestamps


## Change log

**1. 14.10.2020 : v1.0 - first version**
