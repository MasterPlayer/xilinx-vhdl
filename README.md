# xilinx-vhdl
This repository includes some code sources

## Syncronizers 
Includes examples for syncronization elements, which needed in current projects. 

1. **bit_syncer_fdre** - component for sync data which is presented std_logic or std_logic_vector .
Created according xilinx UG949 and UG906 documents

2. **rst_syncer** - component for syncronize reset signal (direct polarity). 
Created according xilinx UG949 and UG906 documents

## AXIS_infrastructure
Includes components for AXI-Stream infrastructure. 

1. **axis_arb_2_to_1** - parametrizable arbiter 2 to 1 for transmit packets from 2 inputs to 1 output.

2. **axis_dump_gen** - parametrizable data generator. Data vector consists of arrays of byte counters.

3. **axis_icmp_chksum_calc** - icmp checksum calculator for input stream for calculate checksum for answer for 256 bit input stream

4. **axis_pkt_sw_4_to_1** - parametrizable packet switch for 4 inputs to 1 output. 

5. **axis_udp_pkg** - parametrizable component for packing input stream to output with ETH/IP/UDP header
