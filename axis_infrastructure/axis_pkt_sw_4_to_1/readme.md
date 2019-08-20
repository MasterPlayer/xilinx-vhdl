# axis_pkt_sw_4_to_1

![component scheme][logo0]

##Description

Packet switch component for transmission from 4 inputs to 1 output
All inputs have equal priority level

Packet from each input accumulated in internal fifo, which presented as Xilinx Parametrized Fifo. 

When packet holded in internal fifo fully(S_AXIS_TLAST event), then do generate signal to packet fifo, which holded flags of completely ready packets to transmission. 
Finite state machine analyze packet fifos from all inputs, and if they have data(not-empty fifo), current state switch to transmission one packet from data fifo. 
Transmission finalize only when TLAST signal fifo was readed from fifo. 
After that, finite state machine switch current state to analyze other packet fifo. 
1. Be sure what packets from inputs do not exceeded maximum size of data fifo. Control the size of input packets
2. Be sure what number of packets, which holded in data fifo do not overload packet fifo. 

Switching for analyze ready state for packets from other inputs going only when current packet will be transmitted
This block supports AXI-Stream interface. If internal data memory is full, S_AXIS_TREADY_* is low. 

Fifo depths configured individually for each input. Memory Types configured for all fifo.

##Generic parameters
1. `N_BYTES` - Number of bytes of data bus (`*_AXIS_TDATA_*). 
2. `FIFO_TYPE_DATA` - Type of data fifo, which intended for holding data words. Now available next types:
* "block" - use BRAM memory for data fifo
* "distributed" - use distributed memory for data fifo
* "auto" - allow synthesis tool to choose type of memory
* "ultra" - ultra RAM
3. `FIFO_TYPE_PKT` - Type of fifo, which designed for storing packet flags. Now available next types
* "block" - use BRAM memory for data fifo
* "distributed" - use distributed memory for data fifo
* "auto" - allow synthesis tool to choose type of memory
* "ultra" - ultra RAM
4. `DATA_DEPTH_0` - Number of words of data fifo for channel S_AXIS_*_0;
5. `DATA_DEPTH_1` - Number of words of data fifo for channel S_AXIS_*_1;
6. `DATA_DEPTH_2` - Number of words of data fifo for channel S_AXIS_*_2;
7. `DATA_DEPTH_3` - Number of words of data fifo for channel S_AXIS_*_3;
8. `PKT_DEPTH_0` - Number of words of packet fifo for channel S_AXIS_*_0;
9. `PKT_DEPTH_1` - Number of words of packet fifo for channel S_AXIS_*_1;
10. `PKT_DEPTH_2` - Number of words of packet fifo for channel S_AXIS_*_2;
11. `PKT_DEPTH_3` - Number of words of packet fifo for channel S_AXIS_*_3;

When choosing a size of packet fifo (`PKT_DEPTH_*`) proceed from minimal packet size. For example, if your minimal packet size (MIN_PKT_SIZE) is 16, and size of data fifo is 1024 words, your minimal fifo size calculated for following rule : 

`DATA_DEPTH/MIN_PKT_SIZE`

according this equation, for current example minimal packet_fifo depth must be more than 64.
because you must avoid situations, when packet_fifo overloaded, but data fifo isn't full and new data might to be written to data fifo, but packet_fifo ignore current packet. 

## Port desctiption

**All signals works in CLK clock domain**
### AXI-Stream Slave interface
* `S_AXIS_TDATA_*` - input data bus. Data width configured with `N_BYTES*8` parameter 
* `S_AXIS_TKEEP_*` - input bus which indicate valid bytes in word. Width configured with `N_BYTES` parameter
* `S_AXIS_TVALID_*` - input port for indicate valid data on bus
* `S_AXIS_TREADY_*` - output port for signaling ability to receive data 
* `S_AXIS_TLAST_*` - input signal for indicates the boundary of packet
### AXI-Stream Master interface
* `M_AXIS_TDATA_*` - output data bus. Data width configured with `N_BYTES*8` parameter 
* `M_AXIS_TKEEP_*` - output bus which indicate valid bytes in word. Width configured with `N_BYTES` parameter
* `M_AXIS_TVALID_*` - output port for indicate valid data on bus
* `M_AXIS_TREADY_*` - input port for signaling ability slave (external device) for receive data 
* `M_AXIS_TLAST_*` - output signal for indicates the boundary of packet


## FSM
This component contains Finite State machine. Following desctiption of states

1. `CHK_0_ST` - Analyze packet fifo for channel 0. If packet fifo isn't empty, next state will be `TX_0_ST`. Otherwise, next state will be `CHK_1_ST`.
2. `CHK_1_ST` - Analyze packet fifo for channel 1. If packet fifo isn't empty, next state will be `TX_1_ST`. Otherwise, next state will be `CHK_2_ST`.
3. `CHK_2_ST` - Analyze packet fifo for channel 2. If packet fifo isn't empty, next state will be `TX_2_ST`. Otherwise, next state will be `CHK_3_ST`.
4. `CHK_3_ST` - Analyze packet fifo for channel 3. If packet fifo isn't empty, next state will be `TX_3_ST`. Otherwise, next state will be `CHK_0_ST`.
5. `TX_0_ST` - Transmit data from fifo channel 0. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_1_ST`
6. `TX_1_ST` - Transmit data from fifo channel 0. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_2_ST`
7. `TX_2_ST` - Transmit data from fifo channel 0. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_3_ST`
8. `TX_3_ST` - Transmit data from fifo channel 0. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_0_ST`

Next figure show Finite state machine transition diagram

![fsm][logo0]

## Change log
1. *v1.0* - first release


## Related components
1. fifo_in_sync_xpm
2. fifo_in_pkt_xpm
3. fifo_out_sync_xpm




[logo0]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_4_to_1/axis_pkt_sw_4_to_1_struct.png
[logo1]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_4_to_1/axis_pkt_sw_4_to_1_fsm.png
