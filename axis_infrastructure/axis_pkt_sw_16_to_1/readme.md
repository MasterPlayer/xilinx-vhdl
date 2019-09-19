# axis_pkt_sw_16_to_1

![component scheme][logo0]

##Description

Packet switch component for transmission from 16 inputs to 1 output
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
8. `DATA_DEPTH_4` - Number of words of data fifo for channel S_AXIS_*_4;
9. `DATA_DEPTH_5` - Number of words of data fifo for channel S_AXIS_*_5;
10. `DATA_DEPTH_6` - Number of words of data fifo for channel S_AXIS_*_6;
11. `DATA_DEPTH_7` - Number of words of data fifo for channel S_AXIS_*_7;
12. `DATA_DEPTH_8` - Number of words of data fifo for channel S_AXIS_*_8;
13. `DATA_DEPTH_9` - Number of words of data fifo for channel S_AXIS_*_9;
14. `DATA_DEPTH_A` - Number of words of data fifo for channel S_AXIS_*_A;
15. `DATA_DEPTH_B` - Number of words of data fifo for channel S_AXIS_*_B;
16. `DATA_DEPTH_C` - Number of words of data fifo for channel S_AXIS_*_C;
17. `DATA_DEPTH_D` - Number of words of data fifo for channel S_AXIS_*_D;
18. `DATA_DEPTH_E` - Number of words of data fifo for channel S_AXIS_*_E;
19. `DATA_DEPTH_F` - Number of words of data fifo for channel S_AXIS_*_F;
20. `PKT_DEPTH_0` - Number of words of packet fifo for channel S_AXIS_*_0;
21. `PKT_DEPTH_1` - Number of words of packet fifo for channel S_AXIS_*_1;
22. `PKT_DEPTH_2` - Number of words of packet fifo for channel S_AXIS_*_2;
23. `PKT_DEPTH_3` - Number of words of packet fifo for channel S_AXIS_*_3;
24. `PKT_DEPTH_4` - Number of words of packet fifo for channel S_AXIS_*_4;
25. `PKT_DEPTH_5` - Number of words of packet fifo for channel S_AXIS_*_5;
26. `PKT_DEPTH_6` - Number of words of packet fifo for channel S_AXIS_*_6;
27. `PKT_DEPTH_7` - Number of words of packet fifo for channel S_AXIS_*_7;
28. `PKT_DEPTH_8` - Number of words of packet fifo for channel S_AXIS_*_8;
29. `PKT_DEPTH_9` - Number of words of packet fifo for channel S_AXIS_*_9;
30. `PKT_DEPTH_A` - Number of words of packet fifo for channel S_AXIS_*_A;
31. `PKT_DEPTH_B` - Number of words of packet fifo for channel S_AXIS_*_B;
32. `PKT_DEPTH_C` - Number of words of packet fifo for channel S_AXIS_*_C;
33. `PKT_DEPTH_D` - Number of words of packet fifo for channel S_AXIS_*_D;
34. `PKT_DEPTH_E` - Number of words of packet fifo for channel S_AXIS_*_E;
35. `PKT_DEPTH_F` - Number of words of packet fifo for channel S_AXIS_*_F;

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
4. `CHK_3_ST` - Analyze packet fifo for channel 3. If packet fifo isn't empty, next state will be `TX_3_ST`. Otherwise, next state will be `CHK_4_ST`.
5. `CHK_4_ST` - Analyze packet fifo for channel 4. If packet fifo isn't empty, next state will be `TX_4_ST`. Otherwise, next state will be `CHK_5_ST`.
6. `CHK_5_ST` - Analyze packet fifo for channel 5. If packet fifo isn't empty, next state will be `TX_5_ST`. Otherwise, next state will be `CHK_6_ST`.
7. `CHK_6_ST` - Analyze packet fifo for channel 6. If packet fifo isn't empty, next state will be `TX_6_ST`. Otherwise, next state will be `CHK_7_ST`.
8. `CHK_7_ST` - Analyze packet fifo for channel 7. If packet fifo isn't empty, next state will be `TX_7_ST`. Otherwise, next state will be `CHK_8_ST`.
9. `CHK_8_ST` - Analyze packet fifo for channel 8. If packet fifo isn't empty, next state will be `TX_8_ST`. Otherwise, next state will be `CHK_9_ST`.
10. `CHK_9_ST` - Analyze packet fifo for channel 9. If packet fifo isn't empty, next state will be `TX_9_ST`. Otherwise, next state will be `CHK_A_ST`.
11. `CHK_A_ST` - Analyze packet fifo for channel A. If packet fifo isn't empty, next state will be `TX_A_ST`. Otherwise, next state will be `CHK_B_ST`.
12. `CHK_B_ST` - Analyze packet fifo for channel B. If packet fifo isn't empty, next state will be `TX_B_ST`. Otherwise, next state will be `CHK_C_ST`.
13. `CHK_C_ST` - Analyze packet fifo for channel C. If packet fifo isn't empty, next state will be `TX_C_ST`. Otherwise, next state will be `CHK_D_ST`.
14. `CHK_D_ST` - Analyze packet fifo for channel D. If packet fifo isn't empty, next state will be `TX_D_ST`. Otherwise, next state will be `CHK_E_ST`.
15. `CHK_E_ST` - Analyze packet fifo for channel E. If packet fifo isn't empty, next state will be `TX_E_ST`. Otherwise, next state will be `CHK_F_ST`.
16. `CHK_F_ST` - Analyze packet fifo for channel F. If packet fifo isn't empty, next state will be `TX_F_ST`. Otherwise, next state will be `CHK_0_ST`.
17. `TX_0_ST` - Transmit data from fifo channel 0. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_1_ST`
18. `TX_1_ST` - Transmit data from fifo channel 1. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_2_ST`
19. `TX_2_ST` - Transmit data from fifo channel 2. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_3_ST`
20. `TX_3_ST` - Transmit data from fifo channel 3. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_4_ST`
21. `TX_4_ST` - Transmit data from fifo channel 4. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_5_ST`
22. `TX_5_ST` - Transmit data from fifo channel 5. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_6_ST`
23. `TX_6_ST` - Transmit data from fifo channel 6. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_7_ST`
24. `TX_7_ST` - Transmit data from fifo channel 7. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_8_ST`
25. `TX_8_ST` - Transmit data from fifo channel 8. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_9_ST`
26. `TX_9_ST` - Transmit data from fifo channel 9. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_A_ST`
27. `TX_A_ST` - Transmit data from fifo channel A. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_B_ST`
28. `TX_B_ST` - Transmit data from fifo channel B. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_C_ST`
29. `TX_C_ST` - Transmit data from fifo channel C. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_D_ST`
30. `TX_D_ST` - Transmit data from fifo channel D. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_E_ST`
31. `TX_E_ST` - Transmit data from fifo channel E. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_F_ST`
32. `TX_F_ST` - Transmit data from fifo channel F. Transmission continues until the TLAST signal is read. If Tlast signal is read, next state will be `CHK_0_ST`

Next figure show Finite state machine transition diagram

![fsm][logo1]

## Change log
1. 19.09.2019 : *v1.0* - first release 

## Related components
1. fifo_in_sync_xpm
2. fifo_in_pkt_xpm
3. fifo_out_sync_xpm


[logo0]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_16_to_1/axis_pkt_sw_16_to_1_struct.png
[logo1]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_16_to_1/axis_pkt_sw_16_to_1_fsm.png
