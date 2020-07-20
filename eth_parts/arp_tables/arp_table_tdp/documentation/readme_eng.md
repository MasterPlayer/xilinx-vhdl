# arp_table_tdp

Parametrizable memory for using as table which stores ARP. Based upon true dual port RAM. Count of elements is set via parametrization. Table can work in other clock domains for different ports of true dual port bram. Its a simplest variant of realization table for store parameters IP, MAC, PORT.


## Structure 

![arp_table_struct][logo1]

[logo1]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/eth_parts/arp_tables/arp_table_tdp/documentation/arp_table_tdp.png

## generics

Name | Type | Value range | Description
-----|------|-------------|------------
N_ELEMENTS | integer | >0 | Number of elements
ADDR_WIDTH | integer | >0 | Address bus width
ASYNC | boolean | true или false | Asyncronous mode used for different clock domains for ports A and B

## Ports 

Component based upon dual-port bram with separation of PORTA and PORTB

### PORTA

Designed to configure the table from under the external interface

Name | Direction | width | Description
-----|-----------|-------|------------
CLKA             | input | 1 | Clock signal for PORTA
RSTA             | input | 1 | Reset signal for PORTA
CFG_ADDRA_IN     | input | ADDR_WIDTH | signal of address
CFG_DV_IN        | input | 1 | signal valid command
CFG_CMD_IN       | input | 1 | Signal of command. 0 - reading from table, 1 - writing to table
CFG_DST_MAC_IN   | input | 48 | data signal for writing destination MAC-Address. For reading operation has no effect
CFG_DST_IP_IN    | input | 32 | data signal for writing destination IP-address. FOr reading operation has no effect
CFG_DST_PORT_IN  | input | 16 | data signal for writing destination UDP port. For reading operation has no effect
CFG_SRC_IP_IN    | input | 32 | data signal for writing source IP-address. For reading operation has no effect
CFG_SRC_PORT_IN  | input | 16 | data signal for writing source UDP port. For reading operation has no effect
CFG_DST_MAC_OUT  | output | 48 | data signal for reading destination MAC-address. For writing operation must be ignored
CFG_DST_IP_OUT   | output | 32 | data signal for reading destination IP-address. For writing operation must be ignored
CFG_DST_PORT_OUT | output | 16 | data signal for reading destination UDP port. For writing operation must be ignored
CFG_SRC_IP_OUT   | output | 32 | data signal for reading source IP-address. For writing operation must be ignored
CFG_SRC_PORT_OUT | output | 16 | data signal for reading source UDP port. For writing operation must be ignored
CFG_DV_OUT       | output | 1 | signal valid for reading operation

### PORTB

Designed for data requests to the address under external component(for example, data packer)

Name | Direction | Width | Description
-----|-----------|-------|------------
CLKB           | input | 1 | Clock signal for PORTA
RSTB           | input | 1 | Reset signal for PORTB
ADDRB_IN       | input | ADDR_WIDTH | signal of address PORTB
ADDRB_IN_VALID | input | 1 | signal valid command for PORTB
DST_MAC_OUT    | output | 48 | data signal for reading destination MAC-address. Valid only when `DVO = 1`
DST_IP_OUT     | output | 32 | data signal for reading destination IP-address. Valid only when `DVO = 1`
DST_PORT_OUT   | output | 16 | data signal for reading destination UDP port. Valid only when `DVO = 1`
SRC_IP_OUT     | output | 32 | data signal for reading source IP-address. Valid only when `DVO = 1`
SRC_PORT_OUT   | output | 16 | data signal for reading source UDP port. Valid only when `DVO = 1`
DVO            | output | 1 | data valid signal 


## Some principles of how component is work
- PORTA is for configuring the table with ability to write and read
- PORTB is for reading operation
- PORTA and PORTB have ability work in async mode with different clock domain
- Latencies for reading operation configurable separately for each port and sets with constant READ_LATENCY_A for PORTA and READ_LATENCY_B for PORTB
- If entry in table is missing for any address, then reading to output is valid 


## Required external component
Component name | Description
--------------------|---------
[tdpram_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/ram_parametrized/tdpram_xpm/tdpram_xpm.vhd) | Примитив двухпортовой памяти

## Change log

**1. 14.02.2020 v1.0 - first version **
