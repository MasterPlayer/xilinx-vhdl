# axis_udp_pkg_prm

## Description

Parametrized component for package input traffic to udp packets with envelope MAC/IP/UDP headers


![structure of component][logo_struct]


output of this component is next format: 

![data format][logo_data_format]



## GENERIC

this component have next configurable parameters

1) `N_BYTES` - number of data bus width in bytes. Current version supports 4/8/32 bytes width
2) `HEAD_PART` - number of bytes of header part
3) `HEAD_CNT_LIMIT` - number of words for header(include half-word part for header)
4) `ASYNC_MODE` - use asyncronous mode of input fifo(`S_AXIS*`-bus a asyncronous to internal logic)

## PORTS


### AXI-Stream Slave interface

* `S_AXIS_CLK` - clock signal for `S_AXIS_` bus. 
* `S_AXIS_RESET` - reset signal for `S_AXIS_` bus
* `S_AXIS_TDATA` - Data signal from source. Configurable with parameter `N_BYTES`. 
* `S_AXIS_TVALID` - Data valid signal 
* `S_AXIS_TREADY` - Data ready signal to source. If internal fifo is full, this signal is '0', otherwise, this signal is '1'


### AXI-Stream Master interface

* `M_AXIS_CLK` - clock signal for `M_AXIS_` bus and all internal logic
* `M_AXIS_TDATA` - data signal, Width configurable with `N_BYTES` parameter.
* `M_AXIS_TKEEP` - signal for data present in vector. Width configurable width `N_BYTES` parameter.
* `M_AXIS_TVALID` - signal for data valid
* `M_AXIS_TREADY` - data ready signal from destination component. 
* `M_AXIS_TLAST` - signal for packet boundary.
    
### Inputs:


* `SIZE` - size of packet in words. Needed for generate `TLAST` signal, because input S_AXIS_* port doesn't have `TLAST` signal. Width 16 bit.
* `SRC_MAC` - source mac address, which used in MAC header. Bytes must be reversed. For example: if source mac have next address : `00:0a:35:01:02:03`, we must write him as `030201350a00`. Width 48 bit.
* `SRC_IP` - source IP-adrress which used in IP header and ipv4 checksum calculator. Bytes must be reversed. For example : if IP-address have address `192.168.0.100`(in decimal), we must write him as `6400a8c0` in hex format. Width 32 bit.
* `SRC_PORT` - source UDP-port, which used in UDP header. Bytes must be reversed. For example, if source udp-port presented as 5001 in decimal, we must write `8913` in hex format.
* `DST_MAC` - destination mac address, which used in MAC header. Bytes must be reversed. For example: if source mac have next address : `00:0a:35:01:02:03`, we must write him as `030201350a00`. Width 48 bit.
* `DST_IP` - destination IP-adrress which used in IP header and ipv4 checksum calculator. Bytes must be reversed. For example : if IP-address have address `192.168.0.100`(in decimal), we must write him as `6400a8c0` in hex format. Width 32 bit.
* `DST_PORT` - destination UDP-port, which used in UDP header. Bytes must be reversed. For example, if source udp-port presented as `5001` in decimal, we must write `8913` in hex format.
* `CNT_US` - 64-bit counter for usec. Used for addition header. Write him direct, no byte-swapped format.
* `DVI` - Data valid from tables. Used for start ipv4 checksum calculation.
* `PNUM_IN` - pnum value for insertion him to addition header. We must write this value directly without byte-swap. Width is 16 bit.

### Outputs

* `PNUM_WRITE` - signal for external component for increment pnum value after current value pnum inserted in header. 


## Constants


### Common 

* `SIZE_SHFT` - value for shifting SIZE register in vector for convert SIZE in words to size in bytes. Calculated as `ceil(log2(N_BYTES))`
* `DATA_WIDTH` - data width in bits. Calculated as `N_BYTES * 8`
* `HEAD_WIDTH` - head width in bits for last head word. Calculated as `HEAD_PART * 8`.
* `DELAYREG_WIDTH` - Width of delay register, which used for align data in vector. 
* `HEAD_CNT_LIMIT_LOGIC` - value for header presented in std_logic_vector format for correct work with head counter

### Ethernet

* `C_ETH_TYPE` - byte-swapped value for ethernet type (`0x0800`). Used in Ethernet header.
* `C_IPV4_IP_VER_LEN` - byte-swapped value of `IP_VERSION` and `IP_LENGTH`. Used in IP header.
* `C_IPV4_ID` - constant for IP Header. in current version is "0000".
* `C_IPV4_FLAGS` - flags in IP header. In current version is "0000".
* `C_IPV4_TTL` - Time-to-live for IP Header. in current version defines as maximal value.
* `C_IPV4_PROTO` - IP PROTOCOL field which used in IP header. For UDP packets defined as "11" in hexadecimal presentation

### Size 

* `C_UDP_HEAD` - size of udp header. Current version defined this parameter as 8 bytes(standart UDP header).
* `C_IP_HEAD` - size of IP header. Current version defined this parameter as 20 bytes(standart IP header).
* `C_DUMP_HEAD` - size of dump(additional header). Current version defined this parameter as 12 bytes.

## Registers 

- `head_cnt` - register which used as counter for head part(ETH/IP/UDP/Addition header).
- `current_state` : finite state machine signal.
- `last_cnt` - register for counting packet size for generate TLAST signal.

## FSM description

There are Finite state machine presented. The FSM include the next states :

1) `IDLE_ST` - in this state we wait for new data for packaging with headers. Transition to `WRITE_HEADER_ST` is allowed when output fifo isn't full, input fifo isn't empty, and ipv4 calculator completely calculate checksum.
2) `READ_FIRST_ST` - in this state we read first word from input fifo for realize realignment in data vector.
3) `WRITE_HEADER_ST` - in this state we insert headers in stream. Next transition is `READ_FIRST_ST` when head_cnt reaches `HEAD_CNT_LIMIT_LOGIC` value.
4) `WRITE_LAST_ST` - in this state we insert tlast signal and write last word according last_cnt. Next transition is `IDLE_ST` when output fifo isn't almost full.
5) `WRITE_DATA_ST` - in this state we insert data from input fifo and write to output fifo until we read tlast signal from input fifo. Next valid transition is `WRITE_LAST_ST` when we read tlast siganl from input fifo.

## Diagram 

![finite state machine diag][logo_fsm]

## Related modules 

[source of fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) - syncronous fifo minimal size with support `TKEEP, TREADY, TLAST` signal. Used when `ASYNC_MODE = "false"`.
[source of fifo_in_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_async_xpm/fifo_in_async_xpm.vhd) - asyncronous fifo minimal size with support `TKEEP, TREADY, TLAST` signal. Used when `ASYNC_MODE = "true"`.
[source of fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) - output fifo minimal size for support AXI-Stream. Supports `TKEEP, TLAST, TREADY` signals.
[source of rst_syncer](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/syncronizers/rst_syncer.vhd) - reset syncronization unit used when `ASYNC_MODE = "true"`.
[source of ipv4_chksum_calc_sync](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/eth_parts/ipv4_chksum_calc_sync.vhd) - ethernet ipv4 checksum calculator.


## Change log

1. 17.11.2019 : v1.0 - first version


[logo_fsm]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_udp_pkg_prm/axis_udp_pkg_prm_fsm.png
[logo_struct]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_udp_pkg_prm/axis_udp_pkg_prm_struct.png
[logo_data_format]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_udp_pkg_prm/axis_udp_pkg_prm_format.png