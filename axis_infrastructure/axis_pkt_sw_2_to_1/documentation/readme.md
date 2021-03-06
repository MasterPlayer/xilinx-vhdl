# axis_pkt_sw_2_to_1

Параметризуемый арбитр 2 в 1 с поддержкой AXI-Stream и возможностью накопления пакета

Производит передачу пакетов с двух портов Slave AXI-Stream в один порт Master AXI-Stream. Входы имеют одинаковый приоритет. Принцип работы компонента основан на попакетной коммутации с накоплением пакета. Компонент получает данные со входа, складывает эти данные во внутреннюю очередь, и когда придет конец этого пакета, то записывает флаг конца пакета в пакетную очередь. Далее конечный автомат видит, что пакетная очередь не пуста, и производит вычитывание очереди данных до конца пакета. В таком случае, передаваться будет пакет, который полностью лежит во внутренней очереди. До тех пор, пока пакет не будет записан во внутреннюю очередь полностью, его передача через Master AXI-Stream не начнется. 


![axis_pkt_sw_2_to_1_struct][axis_pkt_sw_2_to_1_struct_ref]

[axis_pkt_sw_2_to_1_struct_ref]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_struct.png


## generic-параметры
Название | Тип | Диапазон значений | Описание
---------|-----|-------------------|---------
N_BYTES | integer | >0 | размер шины данных в байтах
FIFO_TYPE_DATA | string | "block", "distributed", "ultra", "auto" | тип фифо для очереди данных
FIFO_TYPE_PKT | string | "block", "distributed", "ultra", "auto" | тип фифо для очереди готовых пакетов
DATA_DEPTH_0 | integer | >15 | глубина очереди данных порта `S_AXIS_T*_0`
DATA_DEPTH_1 | integer | >15 | глубина очереди данных порта `S_AXIS_T*_1`
PKT_DEPTH_0 | integer | >15 | глубина очереди пакетов порта `S_AXIS_T*_0`
PKT_DEPTH_1 | integer | >15 | глубина очереди пакетов порта `S_AXIS_T*_1`

## порты 

### AXI-Stream 

Вся работа компонента основывается на поддержке AXI-Stream

#### Slave AXI Stream 0

Название | направление | Разрядность | Назначение
---------|-------------|-------------|-----------
S00_AXIS_TDATA | вход | `N_BYTES*8` | порт данных
S00_AXIS_TKEEP | вход | `N_BYTES` | порт валидности байт внутри слова
S00_AXIS_TVALID | вход | 1 | сигнал валидности
S00_AXIS_TREADY | выход | 1 | сигнал готовности к приему данных со стороны компонента
S00_AXIS_TLAST | вход | 1 | сигнал конца пакета


#### Slave AXI Stream 1 

Название | направление | Разрядность | Назначение
---------|-------------|-------------|-----------
S00_AXIS_TDATA | вход | `N_BYTES*8` | порт данных
S00_AXIS_TKEEP | вход | `N_BYTES` | порт валидности байт внутри слова
S00_AXIS_TVALID | вход | 1 | сигнал валидности
S00_AXIS_TREADY | выход | 1 | сигнал готовности к приему данных со стороны компонента
S00_AXIS_TLAST | вход | 1 | сигнал конца пакета


#### Master AXI Stream 

Название | направление | Разрядность | Назначение
---------|-------------|-------------|-----------
M_AXIS_TDATA | выход | `N_BYTES*8` | порт данных
M_AXIS_TKEEP | выход | `N_BYTES` | порт валидности байт внутри слова
M_AXIS_TVALID | выход | 1 | сигнал валидности
M_AXIS_TREADY | вход | 1 | сигнал готовности к приему данных со стороны устройства, принимающего поток с компонента
M_AXIS_TLAST | выход | 1 | сигнал конца пакета

## Некоторые принципы работы компонента
- Нельзя подавать пакеты, длина которых превышает глубину очереди порта, куда будет приходить этот пакет. В таком случае механизм может сломаться
- Приоритет отсутствует и опрос наличия готовых пакетов во внутренних очередях идет поочередно
- Не имеет смысла задавать очередь флагов готовых пакетов больше чем глубина самих данных
- В случае необходимости размеры очередей для одного порта и для другого могут отличаться, но не может отличаться тип этих очередей между портами. 
- Асинхронный режим не поддерживается. Все сигналы тактируются по CLK
- в пакетную очередь записываются **только флаги готовых пакетов**. Размер пакета при этом не пишется. 

## Конечный автомат

### Граф-схема автомата

Структура конечного состояния представлена на рисунке ( условия переходов не показаны )

![axis_pkt_sw_2_to_1_fsm][logo_fsm]

[logo_fsm]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_fsm.png

### Состояния конечного автомата
Текущее состояние | Следующее состояние | Условие перехода
------------------|---------------------|-----------------
CHK_0_ST          | TX_0_ST             | `out_awfull = 0 and in_empty_pkt_0 = 0`
CHK_0_ST          | CHK_1_ST            | `out_awfull = 0 and in_empty_pkt_0 = 1`
CHK_1_ST          | TX_1_ST             | `out_awfull = 0 and in_empty_pkt_1 = 0`
CHK_1_ST          | CHK_0_ST            | `out_awfull = 0 and in_empty_pkt_1 = 1`
TX_0_ST           | CHK_1_ST            | `out_awfull = 0 and in_dout_last_0 = 1`
TX_1_ST           | CHK_0_ST            | `out_awfull = 0 and in_dout_last_1 = 1`

### Диаграмма переходов(пример)

![axis_pkt_sw_2_to_1_fsm_work][logo_fsm_work]

[logo_fsm_work]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_pkt_sw_2_to_1/documentation/axis_pkt_sw_2_to_1_fsm_work.png

## Необходимые внешние компоненты
Название компонент | Описание
-------------------|---------
[fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | примитив очереди для данных на отправку для реализации Master AXI-Stream
[fifo_in_pkt_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_pkt_xpm/fifo_in_pkt_xpm.vhd) | Примитив очереди для накопления флагов готовых пакетов
[fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_in_sync_xpm/fifo_in_sync_xpm.vhd) | Примитив очереди для накопления данных


## Лог изменений

** 1. 19.09.2020 v1.0 - первая версия **