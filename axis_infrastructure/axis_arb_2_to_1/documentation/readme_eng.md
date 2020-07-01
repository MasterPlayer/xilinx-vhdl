# axis_arb_2_to_1

parametrizable arbiter 2 to 1 with AXI-Stream support

makes commutation from two inputs Slave AXI-Stream to one Master AXI-Stream with equal priority. Works with packet mode commutation. if one of Slave AXI-Stream ports starts transmission, then internal logic switches to other Slave AXI-Stream ports only when current port ends transmit packet. Otherwise, finite state machine stays in current state 


## Structure 

![axis_arb_2_to_1][logo1]

[logo1]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_arb_2_to_1/documentation/axis_arb_2_to_1.png

## generic parameters
Name | Type | Value range | Description
---------|-----|-------------------|---------
N_BYTES | integer | >0 | width of data bus in bytes

## Ports 

### AXI-STREAM

All work of component based upon AXI-Stream support

#### Slave AXI Stream 0

Name | Direction | Width | Description
---------|-------------|-------------|-----------
S00_AXIS_TDATA | input | `N_BYTES*8` | data port
S00_AXIS_TKEEP | input | `N_BYTES` | valid of byte in data words
S00_AXIS_TVALID | input | 1 | valid signal
S00_AXIS_TREADY | output | 1 | ready-to-receive signal from component
S00_AXIS_TLAST | input | 1 | end of packet signal


#### Slave AXI Stream 1 

Name | Direction | Width | Description
---------|-------------|-------------|-----------
S00_AXIS_TDATA | input | `N_BYTES*8` | data port
S00_AXIS_TKEEP | input | `N_BYTES` | valid of byte in data words
S00_AXIS_TVALID | input | 1 | valid signal
S00_AXIS_TREADY | output | 1 | ready-to-receive signal from component
S00_AXIS_TLAST | input | 1 | end of packet signal


#### Master AXI Stream 

Name | Direction | Width | Description
---------|-------------|-------------|-----------
M_AXIS_TDATA | output | `N_BYTES*8` | data port
M_AXIS_TKEEP | output | `N_BYTES` | valid of byte in data words
M_AXIS_TVALID | output | 1 | valid signal
M_AXIS_TREADY | input | 1 | ready-to-receive signal from other slave component on bus
M_AXIS_TLAST | output | 1 | end of packet signal


## Some principles of how component is work
- if one of two ports S_AXIS beginning transmission data, and our component do receive process, then switch to another port possible only when current port says S_AXIS_TLAST signal
- There are no priority between two input ports. Finite state machine estimates that data is present between input ports with equal priority
- At the moment, when packets simultaneously arrive at the inputs on both ports, the packet will be transmitted from port whose status was analyzed at that moment.
- For ease organization of components there are no transmission additional fields. That is, on the output bus there is no way to evaluate from which specific port the data is coming. 
- Asyncronout mode not support in current realization


## Finite State Machine

### Graph-chart of FSM
The structure of FSM presented on following picture

![axis_arb_2_to_1_fsm][logo_fsm]

[logo_fsm]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_arb_2_to_1/documentation/axis_arb_2_to_1_fsm.png

### States 
Current state | Next State | Transition condition
-------------------|---------------------|-----------------
CH0_CHECK | CH0_TX | `S00_AXIS_TVALID = 1`
CH0_CHECK | CH1_CHECK | `S00_AXIS_TVALID = 0`
CH1_CHECK | CH1_TX | `S01_AXIS_TVALID = 1`
CH1_CHECK | CH0_CHECK | `S01_AXIS_TVALID = 0`
CH0_TX | CH1_CHECK | `out_awfull = 0 and S00_AXIS_TVALID = 1 and S00_AXIS_TLAST = 1`
CH1_TX | CH0_CHECK | `out_awfull = 0 and S01_AXIS_TVALID = 1 and S01_AXIS_TLAST = 1`


## Required external components :
Name | Description
--------------------|---------
[fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | the primitive of fifo for data for sending data with support Master AXI Stream 
[axis_dump_gen](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen) | Required for simulation. 


## Change log

**1. 11.08.2020 v1.0 - First version**

