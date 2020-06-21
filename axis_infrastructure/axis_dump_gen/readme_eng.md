# axis_dump_gen

Simple data generator for AXI-Stream bus with ability for configuration data bus and work in CDC mode

## Structure
[]

## Generic-parameters
1) `N_BYTES` - data bus width with 8 bit multiplicity
2) `ASYNC` - parameter for ability works in CDC or not CDC
3) `MODE` - parameter for data pattern, support next modes : 
- `SINGLE` - data bus presented as simple counter for all width
- `ZEROS` - data bus presented only zero values
- `BYTE` - generate array of 8 bit counters for all data bus width

## Ports

### AXI-Stream
Output bus presented as Master AXI-Stream bus with support next signals : 
1) `M_AXIS_TDATA` - data signal, width configurable with N_BYTES generic parameter
2) `M_AXIS_TKEEP` - byte valid signal for data bus. Always set is 1. Width configurable with N_BYTES generic parameter
3) `M_AXIS_TREADY` - input from receiver signalize about ready to receive current data
4) `M_AXIS_TLAST` - packet boundary signal
5) `M_AXIS_TVALID` - data valid signal.

### Inputs
Configuration inputs:
1) `WORD_LIMIT` - Number of words in packet ( where 1 word = N_BYTES bytes). Valid range is [0x00000001h..ffffffffh]. Value 0x00000000 is prohibited, and work of generator is stop if we write this value for next time, while we not change input value from 0x00000000h to other value. 
2) `PAUSE` - size of pause between the packets. Supported value is [0x00000000h-0xFFFFFFFFh]. If we set the 0x00000000h value, data generator establish data on bus without pause. 
3) `ENABLE` - enable/disable generator.

Work principles : 
- if generator started, we can stop this only when current packet fully transferred
- if generator started and we deassert `ENABLE` signal in moment transition of packet, then generator completes transmit current packet and go to idle state
- if in work process we change `WORD_LIMIT` in generator, then generator change size of packet only when current packet is fully transmitted
- if in pause state we change `PAUSE` parameter, new pause is apply only when current pause is ended
- if generator stayed in pause state, and we deassert `ENABLE` signal, then generator make one packet and stops

`M_AXIS_TKEEP` always sets is "1", because byte mode in axi_stream is not supported for current version on generator

Current speed of generator (if TREADY always is set '1') following next rule : 
**SPEED = (WORD_LIMIT/(WORD_LIMIT + PAUSE)) x (N_BYTESx8) x CLK_PERIOD**
где `SPEED` - speed in bit per second
`WORD_LIMIT` - number of words in packet
`PAUSE` - size of pause in clock periods
`N_BYTES` - size of data bus in bytes
`CLK_PERIOD` - clock period in Hz

## Required external components:
1) [fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) if used `ASYNC_MODE = false`
2) [fifo_out_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_xpm/fifo_out_async_xpm.vhd) if used `ASYNC_MODE = true`

## Change Log:

1. 11.08.2019 v1.0 - first version
- Works only with array on 8-bit counters, which distributed in N_BYTES bus
- Supports AXI-Stream bus
- Supports CDC mode

2. 17.11.2019 v1.1 - update changes, no logic changes

3. 14.02.2020 v1.2 - changes on generator
- Add mode when counter = N_BYTES width and counter presented as single counter in data bus

4. 26.03.2020 v1.2 - changes on generator:
- Add mode when output data presented as zeros
- limits of component :
1) PAUSE = 0 is not supported
2) not recommended transit from big size packets to smaller size packets
3) WORD_LIMIT and PAUSE must be set less by one from actual packet_size and pause_size respectively. For example : for generate 8192 bytes packets if N_BYTES = 8, we need set generator WORD_LIMIT as 0x000003FFh(1023 in decimal)

5. 18.06.2020 v1.3 - changes on generator
- add support for PAUSE = 0
- Add support for reduce packet size in some moment
- Changes of generic : all three modes select with one generic parameter `MODE`, not two.
- add testbench file for testing component rapidly
- update description

[logo]: https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_dump_gen/documentation/axis_dump_gen.png