# axis_pkt_sw_2_to_1

Parametrizable arbiter 2 to 1 with support AXI-Stream and packet accumulation ability

Perform transmissions of packets from two ports Slave AXI-Stream to Master AXI-Stream port. Inputs have equal priority. The principle of component work based upon packet commutation with accumulate packet. Component gets data from input, hold this data to internal queue, and when end of packets reveived, then write end of packet flaq into packet queue. Next, the state machine gets signal about packet fifo is not empty and perform reading data queue while end of packet is not reached. In this case, the packet transferred which entirely from internal queue. While packet not been writed to internal queue, his transmission over Master AXI-Stream is wont start.

![axis_pkt_sw_2_to_1_struct][axis_pkt_sw_2_to_1_struct_ref]

[axis_pkt_sw_2_to_1_struct_ref]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_struct.png


## generic-параметры

Name | Type | Value range | Description
-----|------|-------------|------------
N_BYTES | integer | >0 | Number of byte size width of data bus
FIFO_TYPE_DATA | string | "block", "distributed", "ultra", "auto" | fifo type for data queue
FIFO_TYPE_PKT | string | "block", "distributed", "ultra", "auto" | fifo type for packet queue
DATA_DEPTH_0 | integer | >15 | depth of data fifo queue of `S_AXIS_T*_0` port
DATA_DEPTH_1 | integer | >15 | depth of data fifo queue of  `S_AXIS_T*_1` port
PKT_DEPTH_0 | integer | >15 | depth of packet fifo queue of `S_AXIS_T*_0` port
PKT_DEPTH_1 | integer | >15 | depth of packet fifo queue of `S_AXIS_T*_1` port

## Ports

### AXI-Stream 

All components work based upon AXI-Stream

#### Slave AXI Stream 0

Name | Direction | Width | Description
-----|-----------|-------|------------
S00_AXIS_TDATA | вход | `N_BYTES*8` | data signal
S00_AXIS_TKEEP | вход | `N_BYTES` | valid of byte in data word signal 
S00_AXIS_TVALID | вход | 1 | data valid signal 
S00_AXIS_TREADY | выход | 1 | ready to receive signal from our component
S00_AXIS_TLAST | вход | 1 | end of packet signal


#### Slave AXI Stream 1 

Name | Direction | Width | Description
-----|-----------|-------|------------
S00_AXIS_TDATA | вход | `N_BYTES*8` | data signal
S00_AXIS_TKEEP | вход | `N_BYTES` | valid of byte in data word signal 
S00_AXIS_TVALID | вход | 1 | data valid signal 
S00_AXIS_TREADY | выход | 1 | ready to receive signal from our component
S00_AXIS_TLAST | вход | 1 | end of packet signal


#### Master AXI Stream 

Name | Direction | Width | Description
-----|-----------|-------|------------
M_AXIS_TDATA | выход | `N_BYTES*8` | data signal
M_AXIS_TKEEP | выход | `N_BYTES` | valid of byte in data word signal 
M_AXIS_TVALID | выход | 1 | data valid signal 
M_AXIS_TREADY | вход | 1 | ready to receive signal from Slave AXI-Stream external component
M_AXIS_TLAST | выход | 1 | end of packet signal

##Some principles of how component is work
- Must not transmit packets, whose length exceeds depth of port queue, where packet has been transmitted. In this case mechanism can broken
- There are no priority. Ports have equal priority. 
- It makes no sense to set the flaqs queue depth of finished packets more than data queue depth.
- if necessary, queue depths for two ports can differents, but not different of type this queue
- Async mode doesnt support. 
- in packet depth writed only flaqs of completely received packets. Packet size not writed

## Finite state machine

### Graph-chard of FSM

The structure of FSM presented on following picture

![axis_pkt_sw_2_to_1_fsm][logo_fsm]

[logo_fsm]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_fsm.png

### FSM states
Current state | Next State | Transition condition
--------------|------------|---------------------
CHK_0_ST      | TX_0_ST    | `out_awfull = 0 and in_empty_pkt_0 = 0`
CHK_0_ST      | CHK_1_ST   | `out_awfull = 0 and in_empty_pkt_0 = 1`
CHK_1_ST      | TX_1_ST    | `out_awfull = 0 and in_empty_pkt_1 = 0`
CHK_1_ST      | CHK_0_ST   | `out_awfull = 0 and in_empty_pkt_1 = 1`
TX_0_ST       | CHK_1_ST   | `out_awfull = 0 and in_dout_last_0 = 1`
TX_1_ST       | CHK_0_ST   | `out_awfull = 0 and in_dout_last_1 = 1`

### Transition diagram(example)

![axis_pkt_sw_2_to_1_fsm_work][logo_fsm_work]

[logo_fsm_work]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_fsm_work.png

## Required external component

Component name | Description
---------------|---------
[fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | fifo primitive for support Master AXI-Stream protocol
[fifo_in_pkt_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_pkt_xpm/fifo_in_pkt_xpm.vhd) | fifo primitive for accumulate flaqs of fully transmitted packets
[fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) | fifo primitive for hold data


## Change log

** 1. 19.09.2020 v1.0 - first version **