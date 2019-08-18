# xilinx-vhdl

## AXIS Infrastructure

Include some modules with AXI-Stream interface
1. axis_arb_2_to_1
2. axis_arb_4_to_1
3. axis_dump_gen
4. axis_icmp_chksum_calc
5. axis_pkt_sw_4_to_1
6. axis_pkt_sw_5_to_1
7. axis_udp_pkg
8. axis_collector

## ETH parts

Include some modules which include parts for ethernet 
1. ipv4_chksum_calc_sync

## FIFO Parametrized
Include parametrized fifo, which realized with Xilinx Parametrized Macros
1. fifo_in_async_xpm
2. fifo_in_sync_xpm
3. fifo_in_pkt_xpm
4. fifo_out_async_xpm
5. fifo_out_sync_xpm
6. fifo_cmd_async_xpm
7. fifo_cmd_sync_xpm
8. fifo_out_sync_xpm_id


## Syncronizers
Data Syncronizers, reset syncronizers
1. rst_syncer
2. bit_syncer_fdre