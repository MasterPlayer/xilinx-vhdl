# axis_collector

Component for collection, store (and accumulate) and transmission data from several channels. Stream is presented as data, which incoming from other channels randomly. Component collects this data depending on the identification of channel to segments, ordering data and transmit fully completed packets of data. 

Fully completed packet calculated as : 

**SEGMENT_BYTE_SIZE/SEGMENT_MAX_PKTS**

The component parametrizable by various parameters, such as Input/output widths, sync/async modes, number of segments, size of each segments and number of packets which can stored in one segment.

Component supports asymetric widths when input and output widths is different


## Structure

![axis collector][logo]

[logo]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_collector/documentation/axis_collector.png "Logo Title Text 2"

## generic-parameters

Component consists of some parameters for flexibility configuration

### generic list

№ | parameter | type | limitations | description
--|----------|-----|-------------|---------
1 | N_CHANNELS | integer | > 1 | Number of channels on which the memory is segmented
2 | N_CHANNELS_W | integer | >log2(N_CHANNELS) | TID port width
3 | SEGMENT_BYTE_SIZE | integer | >0( см.**1**) | size of each segment which store the data
4 | N_BYTES_IN | integer | >0 | input data width in bytes
5 | N_BYTES_OUT | integer | >0 | output data width in bytes
6 | ASYNC_MODE | boolean | true или false | Async mode allow works in different clock domains
7 | SEGMENT_MAX_PKTS | integer | >0 | Number of packets inside one segment
8 | ADDR_USE | string | "full" или "high" | Parameter for addressation type 
9 | TUSER_WIDTH | integer | >=1(см.**2**) | TUSER signal width

**1** Depending on the ADDR_USE parameter the following conditions are used:
- On `ADDR_USE = high` parameter must satisfy the next conditions :

SEGMENT_BYTE_SIZE >= N_BYTES_IN 
SEGMENT_BYTE_SIZE >= N_BYTES_OUT

Otherwise, generation is not possible

- On `ADDR_USE = full` parameter must satisfy the next conditions :

SEGMENT_BYTE_SIZE >= N_BYTES_IN + TUSER width
SEGMENT_BYTE_SIZE >= N_BYTES_IN + TUSER width

This with 

`N_BYTES_IN = 1` 

`N_BYTES_OUT = 1`

`TUSER = 1`

`SEGMENT_BYTE_SIZE` cannot be less than 2

**2** If `ADDR_USE = high` is used, then size of TUSER does not affect operation

## Ports

### AXI-Stream 

**Warning**
> Component have ability for work in different clock domains between S_AXIS and M_AXIS buses, including the internal logic. in case `ASYNC_MODE = false` ports `S_AXIS_CLK` and `M_AXIS_CLK` connects to the same clock signal, and ports `S_AXIS_RESET` and `M_AXIS_RESET` connects to the same reset signal

#### Slave AXI-Stream 
Name | Direction | Width | Definition
---------|-------------|------------|-----------
S_AXIS_CLK | input | 1 | clock signal for S_AXIS-infrastructure
S_AXIS_RESET | input | 1 | Reset signal for S_AXIS-infrastructure
S_AXIS_TDATA | input | N_BYTES_IN*8 | port for input data stream
S_AXIS_TID | input | N_CHANNELS | segment identification port for addressation to memory
S_AXIS_TUSER | input | TUSER_WIDTH | port for ordering data inside one segment. Involved in addressing as a low order. For `ADDR_USE = high` not used and no affect. 
S_AXIS_TVALID| input | 1 | data valid port

#### Master AXI-Stream
Name | Direction | Width | Definition
---------|-------------|-------------|-----------
S_AXIS_CLK | input | 1 | clock signal for M_AXIS-infrastructure
S_AXIS_RESET | input | 1 | Reset signal for M_AXIS-infrastructure
M_AXIS_TDATA | output | N_BYTES_OUT*8 | Data output port
M_AXIS_TID | output | N_CHANNELS | Number of segment. Can needs for other devices for commutation
M_AXIS_TVALID | output | 1 | data valid port
M_AXIS_TREADY | input | 1 | receiver is ready signal

## Some principles of how component is work
- Component collects inputs stream and splits it into segments and writes to internal memory depending on the segment number. Segment number defines with signal `S_AXIS_TID`.
- Component can work only with words. Byte mode inside one word is not supported ( `TKEEP` signal not presented) 
- Component designed to work in which several low-speed data streams arrived at is input, and work of component is separating and ordering data inside one packe. `TREADY` not supported.
- Low speed stream is stream, which has specific `TID`.
- if using `ADDR_USE = "full"` then address forming involved TUSER-signal, which width configurable. The need to use `TUSER` field arose because the data that came in was interfering within the same packet.
- If Master AXI-Stream data stream speed less than Slave AXI-Stream data, this may overwrite the data with loss of part of the already recorded data inside the memory. It is possible without signalizing of losses.
- In practice `TID` field is number of narrowbamd signal, and `TUSER` - number of ADC. In this case, after filtering, the ADC numbers was changed their order, but we needed to save the stream structure in the format which was originally.
- If using `ADDR_USE = "high"`, then address to memory formed with internal counter and `S_AXIS_TID` field for segment addressation. `S_AXIS_TUSER` field is not used for this case.
- Packet of data puts from Master AXI-Stream without TLAST-signal but with channel number.
- Size of packet must be a multiple `N_BYTES_IN` and `N_BYTES_OUT`. Work, when width of input data bus is 24 and output data bus width is 16 not guaranteed and not checking for this cases.

The structure of address formation for write (`ADDRA`) and reading (`ADDRB`) for various modes presented in a pic:

![addra structure][logo1]
![addrb structure][logo2]

[logo1]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_collector/documentation/addra_reg.png "Logo Title Text 2"

[logo2]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_collector/documentation/addrb_reg.png "Logo Title Text 2"

## Required external components:

Name | Description
--------------------|---------
[sdpram_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/ram_parametrized/sdpram_xpm/sdpram_xpm.vhd) | RAM primitive for storage data
[fifo_cmd_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_async_xpm/fifo_cmd_async_xpm.vhd) | fifo primitive for holding requests for ready-to-send packets with using `ASYNC_MODE = "true"`
[fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | fifo primitive for holding requests for ready-to-send packets with using `ASYNC_MODE = "false"`
[fifo_out_sync_xpm_id](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm_id/fifo_out_sync_xpm_id.vhd) | fifo primitive for data for support AXI-Stream interface.
[axis_dump_gen](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen) | Required for simulation. 

## Change log

**1. 18.08.2019 v1.0 - first version**

**2. 27.08.2019 v1.1 - changes on component**
- Add TUSER field support
- Add Addressation mode support
1) "full" - address forms with using TUSER-signal 
2) "high" - address forms without using TUSER-signal

**3. 28.06.2020 v1.2 - changes on component**
- Add condition checking for generic parameters
- Changes catalog structure
- Add component description