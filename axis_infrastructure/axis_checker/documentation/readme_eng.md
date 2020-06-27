# axis_checker

component for checking data. Works as slave AXI-Stream protocol with ability for configuration data bus

## Structure 
[axis_checker scheme][logo]

## generic parameters 
1) `N_BYTES` - parameter for  configure data bus width
2) `TIMER_LIMIT` - limit for counting current speed. This value must be established as clock signal in Hz value
3) `MODE` - select data pattern for checking input data stream. Currently supported three modes: 
`SINGLE` - input data stream presented as simple counter, which width is `N_BYTES` value.
`ZEROS` - input data stream presented as zeros
`BYTE` - input data stream presented as array of 8 bit counters, where number of counters is `N_BYTES` 

## PORTS

### AXI STREAM

Input bus supported next AXI-Stream signals : 
1) `S_AXIS_TDATA` - data signal. Size of data signal established with `N_BYTES` parameter.
2) `S_AXIS_TKEEP` - byte valid signal for data bus. In current version this signal ignored
3) `S_AXIS_TREADY` - signal indicates for ready to receive data. 
4) `S_AXIS_TLAST` - signal for last word in packet.
5) `S_AXIS_TVALID` - data valid signal.

### Inputs 

Inputs for configuration : 
1) `ENABLE` - enable/disable generator
2) `PACKET_SIZE` - number of words in packet. 1 word = N_BYTES bytes. Valid range is [0x00000000h..0xFFFFFFFFh]. For value 0x00000000h checker does not analyze packet size and ignore errors with packet size. 
3) `READY_LIMIT` - Number of clock periods which indicates the number of word, which must be received for current ready period. for 0 value component always receive the data
4) `NOT_READY_LIMIT` - number of clock periods which indicates for master AXI-Stream how long checker stayed in "not ready" state. for value = 0 we always ready to receive the data.

### Outputs 

1) `DATA_ERROR` - 32-bit counter for errors in data for current session. This register resetted when deassert ENABLE or RESET signal asserted.
2) `PACKET_ERROR` - 32-bit counter for errors in packet size for current session. this register resetted when deassert ENABLE or RESET signal asserted.
3) `DATA_SPEED` - 32-bit counter which indicates current speed for data in **byte per second**
4) `PACKET_SPEED` - 32-bit counter which incatates current packet speed in **packets per second**
5) `HAS_DATA_ERR` - error flaq in data bus. Asserts for every time when values between internal data generator and input data stream is unmatched. 
6) `HAS_PACKET_ERR` - error flaq for packet size. Asserts for every time when current packet size and internal packet size is unmatched. 

## The principles of work
- This component presented as AXI-Stream Slave component and can configure speed of input stream with using AXI-Stream signal `TREADY`
- If error in stream has detected, current value of external counter adjusts for current value in stream
- Session - the preiod of time, when `ENABLE` signal asserted. Deassertion with next assertion of `ENABLE` signal resets internal counters of data/packet errors and session has restarted.
- If `ENABLE` signal has asserted when data streaming is on (for example, if master AXI-Stream ignores `TREADY`), component adjusts for first valid value for start passing of checking
- Component can work with three data patterns in current revision. Data patterns not changed dynamically.
- `PACKET_SIZE` might not be the same as `READY_LIMIT`, because `PACKET_SIZE` affects only for packet size check, but `READY_LIMIT` affects for work component and other components, which connected to him over AXI-Stream bus

Stream speed controlled with signals `READY_LIMIT` and `NOT_READY_LIMIT` for next equation : 

**SPEED = (READY_LIMIT/(READY_LIMIT + NOT_READY_LIMIT)) * (N_BYTES * TIMER_LIMIT)**

where
`READY_LIMIT` - size of words which component can receive
`NOT_READY_LIMIT` - size of clock periods for signaling how long component is not ready to receive the data/ 
`N_BYTES` = byte size of data bus
`TIMER_LIMIT` - limit of counting clock_period counter for calculate current speed

## Change log : 

**1. 21.06.2020 v1.0 - first revision **
- allow works with three pattern of data
- supports axi_stream bus
- allow configure stream speed

[logo](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_checker/documentation/axis_checker.png)