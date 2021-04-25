# axis_threshold_ctrl

Компонент для управления скоростью канала данных для возможности понизить скорость данных. Позволяет работать в трех различных режимах, в разных частотных доменах для шин S_AXIS_*, M_AXIS_*. 

## generic-параметры
Название | Тип | Диапазон значений | Описание
---------|-----|-------------------|---------
N_BYTES | integer | >0 | Разрядность шин данных для TDATA
USER_WIDTH | integer | >0 | разрядность шины TUSER
DEPENDENCY | string | "COUNTER", "DATA", "PACKET" | От чего зависит задержка данных
ASYNC_CTRL | string | "FULL", "S_SIDE", "M_SIDE", "SYNC" | переходы CDC
DFLT_RDY_DRTN | integer | 0..((2^32)-1) | Сколько тактов будут передаваться данные после сброса (по умолчанию)
DFLT_BSY_DRTN | integer | 0..((2^32)-1) | Сколько тактов данные будут задерживаться после сброса (по умолчанию)
DEPTH | integer | > 16 | Глубина входной и выходной очередей

## порты 

### Control 

Название | Направление | Разрядность | Назначение 
---------|-------------|-------------|-----------
CLK | input | 1 | сигнал тактирования 
RESET | input | 1 | сигнал сброса, активен при 1
CMD_READY_DURATION | input | 32 | количество тактов, сколько передавать данные. 
CMD_BUSY_DURATION | input | 32 | количество тактов, сколько не передавать данные
CMD_VALID | input | 1 | сигнал подтверждения конфигурации

### AXI-Stream 

#### Slave AXI-Stream 

Название | Направление | Разрядность | Назначение 
---------|-------------|-------------|-----------
S_AXIS_CLK | input | 1 | сигнал тактирования шины S_AXIS_*
S_AXIS_TDATA | input | N_BYTES*8 | шина данных 
S_AXIS_TKEEP | input | N_BYTES | шина валидных байт
S_AXIS_TUSER | input | USER_WIDTH | шина для передачи пользовательского сигнала 
S_AXIS_TVALID | input | 1 | шина валидных данных на входе
S_AXIS_TREADY | output | 1 | шина готовности компонента принимать данные
S_AXIS_TLAST | input | 1 | сигнал конца пакета


#### Master AXI-Stream 

Название | Направление | Разрядность | Назначение 
---------|-------------|-------------|-----------
M_AXIS_CLK | input | 1 | сигнал тактирования шины S_AXIS_*
M_AXIS_TDATA | output | N_BYTES*8 | шина данных 
M_AXIS_TKEEP | output | N_BYTES | шина валидных байт
M_AXIS_TUSER | output | USER_WIDTH | шина для передачи пользовательского сигнала 
M_AXIS_TVALID | output | 1 | шина валидных данных на выходе
M_AXIS_TREADY | input | 1 | шина готовности принимать данные
M_AXIS_TLAST | output | 1 | сигнал конца пакета


## Некоторые принципы работы компонента
- компонент предусматривает три режима работы:
1) `COUNTER`: зависимость только от внутренних счетчиков и значений `CMD_READY_DURATION` и `CMD_BUSY_DURATION`, от потока данных зависимости нет. Классическая схема, при которой нам нет необходимости учитывать поведение потока данных. 
2) `DATA`: зависимость от внутренних счетчиков, которые зависят от наличия данных на входе(`S_AXIS_TVALID`), и возможность приема данных на выходе(`M_AXIS_TREADY`). Тут речь идет о зависимости от данных, при отсутствии данных на входе или возможности передать данные на выход, счетчики не считают. 
3) `PACKET`: внутренний счетчик `CMD_READY_DURATION` не функционирует, вместо него принцип передачи пакета следующий - передается текущий пакет до `S_AXIS_TLAST`, после этого компонент задерживает передачу данных на размер CMD_BUSY_DURATION значение или значение по умолчанию. Другими словами, эта схема позволяет выставить фиксированную паузу между пакетами данных, не учитывая при этом поведение сигналов `TVALID`/`TREADY` сигналов и размера пакета. 
- компонент предусматривает различные схемы синхронизации. Это позволяет более точно настроить скорость потока данных. Выбор режима осуществляется по `ASYNC_CTRL`-параметру. Тактирование каждого из режимов представим на рисунке.
1) `ASYNC` : Сигналы `S_AXIS_CLK`, `CLK`, `M_AXIS_CLK` асинхронны по отношению друг к другу. 
2) `SYNC` : сигналы `S_AXIS_CLK`, `CLK`, `M_AXIS_CLK` синхронны по отношению друг к другу.  
3) `S_SIDE` : `M_AXIS_CLK`, `CLK` - в одном тактовом домене, `S_AXIS_CLK` - в другом.
4) `M_SIDE` : `S_AXIS_CLK`, `CLK` - в одном тактовом домене, `M_AXIS_CLK` - в другом. 
- Разрядности данных поддерживаются кратные байту.
- При `CMD_READY_DURATION` = 0(или если значение `DFLT_RDY_DRTN = 0` по умолчанию), компонент не передает данные
- При `CMD_BUSY_DURATION` = 0(или если значение `DFLT_BSY_DRTN = 0` по умолчанию), компонент всегда передает данные 
- Внутри схемы сигналы сброса синхронизируются компонентом rst_syncer

## Необходимые внешние компоненты

Название компонент | Описание
-------------------|---------
[fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | Примитив для поддержки очереди команд, синхронный
[fifo_in_sync_user_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_user_xpm/fifo_in_sync_user_xpm.vhd) | Примитив входной синхронной очереди для поддержки Slave AXI-Stream
[fifo_in_async_user_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_async_user_xpm/fifo_in_async_user_xpm.vhd) | Примитив входной асинхронной очереди для поддержки Slave AXI-Stream
[fifo_out_sync_tuser_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_tuser_xpm/fifo_out_sync_tuser_xpm.vhd) | Примитив выходной синхронной очереди для поддержки Master AXI-Stream
[fifo_out_async_tuser_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_user_xpm/fifo_out_async_user_xpm.vhd) | Примитив выходной асинхронной очереди для поддержки Master AXI-Stream


## Лог изменений

**1. 16.04.2021 v1.0 - первая версия**