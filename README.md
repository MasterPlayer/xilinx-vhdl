# xilinx-vhdl
This repository includes some code sources

## Syncronizers 
Includes examples for syncronization elements, which needed in current projects. 

1. **bit_syncer_fdre**
component for sync data which is presented std_logic or std_logic_vector .
Created according xilinx UG949 and UG906 documents

2. **rst_syncer** 
component for syncronize reset signal (direct polarity). 
Created according xilinx UG949 and UG906 documents

## AXIS_infrastructure
Includes components for AXI-Stream infrastructure. 

1. **axis_arb_2_to_1**
    Parametrizable arbiter 2 to 1 for transmit packets from 2 inputs to 1 output. 
    Packet transmission for other input starting when current packet from current input ended. No priority for inputs.
    Component include one parametrized fifo (xilinx parametrized macros(XPM)) with minimal size for output fifo
    Tested for xilinx UltraScale Architecture, Xilinx 7 Series Architecture.
    Generic parameters : 
        - N_BYTES : count of bytes in a word. Minimal value is 2. Lower values not tested.


2. **axis_dump_gen**
Parametrizable data generator. Data vector consists of arrays of byte counters.
Inputs :
- ENABLE - enable/disable data generator.
- PAUSE - Pause between packets, 32 bit.
- WORD_LIMIT - number of words in packet. 
Generic parameters :
- N_BYTES : count of bytes in a word. Minimal value is 2. Lower values not tested
- ASYNC : Asyncronous FIFO used. 
1) true - M_AXIS_* bus in M_AXIS_CLK clock domain, ENABLE, PAUSE, WORD_LIMIT and internal logic in CLK clock domain
2) false - M_AXIS_* bus and internal logic in one clock domain.
Some information available in document.
    

3. **axis_icmp_chksum_calc**
    

4. **axis_pkt_sw_4_to_1**


5. **axis_udp_pkg**

