# axis_collector

## DESCRIPTION
The component is designed to collect, store, transmit data from various channels. Data comes from different channels randomly. The component collects data from various channels, collects them by segments, and transmits only ready-made packets.

## GENERIC:
1) `N_CHANNELS` - Number of channels which do segmentation of RAM 
2) `N_CHANNELS_W` - Channel width ( must be >`log2(N_CHANNELS)`)
3) `SEGMENT_BYTE_SIZE` - Size of each segment for holding data from each received channel
4) `N_BYTES_IN` - Input width in bytes
5) `N_BYTES_OUT` - output width in bytes, can be assymetric
6) `ASYNC_MODE` - use asyncronous mode
7) `SEGMENT_MAX_PKTS` - Number of packets in each segment. 

## PORTS:
### Inputs :
1) `S_AXIS_TDATA` – input data bus. Width parametrized in next equation:

`N_BYTES_IN * 8`

2) `S_AXIS_TID` – input bus for indentification segment. Width parametrized in next equation: 

`N_CHANNELS_W`

3) `S_AXIS_TVALID` – input signal for signaling for valid data.

_S_AXIS_TREADY isn’t presented. Overflow data overwrite current holded data_


### Outputs :
1) `M_AXIS_TDATA` - output data bus. Width parametrized in equation : 

`N_BYTES_OUT * 8`

2) `M_AXIS_TID` - output bus with identification segment. Width parametrized

`N_CHANNELS_W`

3) `M_AXIS_TVALID` - output signal for valid data on bus
4) `M_AXIS_TREADY` - input signal for signaling ready of destination


## CONSTANTS: 

Next parameters calculated for parametrized registers/buses/components. 

1) `WORDA_WIDTH = N_BYTES_IN*8`
_This parameter needed for calculating input word width for memory (RAM)_
2) `WORDB_WIDTH = N_BYTES_OUT*8`
_This parameter needed for calculating output word width for memory (RAM)_
3) `ADDRA_WIDTH = log2((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_IN)`
_This parameter needed for calculating address bus for PORT A in memory_
**Example 1**
* SEGMENT_BYTE_SIZE = 2048
* N_CHANNELS = 32
* N_BYTES_IN = 4
* All memory size for all segments in bytes : 2048 * 32 = 65536 bytes;
* Number of words for all memory : 65536/4 = 16384;
* **Address bus for all memory(ADDRA_WIDTH) : log2(16384) = 14**
4) `ADDRB_WIDTH = log2((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_OUT)`
_This parameter needed for calculating address bus for PORT B in memory_
**Example 1:**
* SEGMENT_BYTE_SIZE = 2048
* N_CHANNELS = 32
* N_BYTES_OUT = 32
* All memory size for all segments in bytes: 2048 * 32 = 65536 bytes;
* Number of words for all memory : 65536/32 = 2048;
* **Address bus for all memory(ADDRB_WIDTH) : log2(2048) = 11**
5) `SEG_CNT_WIDTH = log2(SEGMENT_BYTE_SIZE/N_BYTES_IN)`
_width for register, which intended for segment addressation_
**Example 1:**
* SEGMENT_BYTE_SIZE = 1024
* N_BYTES_IN = 4
* Number of words in segment : 1024 / 4 = 256
* **Segment address counter width = log2(256) = 8**

6) `SEG_PART_LIMIT = SEG_CNT_WIDTH - log2(SEGMENT_MAX_PKTS)`
_cnt limit for packet which holded in one segment_
**Example 1:**
* SEG_CNT_WIDTH = 8;
* SEGMENT_MAX_PKTS = 2
* **SEG_PART_LIMIT = 8 - log2(2) = 7**

7) `DIFF_CNT_PART = SEG_CNT_WIDTH - SEG_PART_LIMIT`
_the number of bits in the segment counter, which is designed to signal the finished packet_
8) `ALL_ONES = width calculated as SEG_PART_LIMIT`
_register for hold all '1' for compare with segment address counter for signal the finished packets_
9) `HI_ADDRA = ADDRA_WIDTH - SEG_PART_LIMIT`
_width of register which intended for transmission to read part_
10) `BYTES_PER_PKT = SEGMENT_BYTE_SIZE/SEGMENT_MAX_PKTS`
_number of bytes in packet in segment. Needed for read interface(for counter CNTB)_
11) `CNTB_LIMIT = BYTES_PER_PKT/N_BYTES_OUT`
_Limit of counting for CNTB register, which intended for read one packet from memory_
12) `CNTB_WIDTH = log2(CNTB_LIMIT)`
_Width of CNTB register_
13) `CNTB_LIMIT_VECTOR = width calculated as CNTB_WIDTH`
_register for hold all '1' for compare with segment address counter for finished packets on read interface of memory_
14) `CMD_FIFO_WIDTH = ADDRA_WIDTH - HI_ADDRA`
_width for cmd fifo which intended for transmission from write to read part_
15) `FIFO_DEPTH = SEGMENT_MAX_PKTS * N_CHANNELS`
_Depth for CMD fifo. calculated based on the number of channels and packets in one segment_