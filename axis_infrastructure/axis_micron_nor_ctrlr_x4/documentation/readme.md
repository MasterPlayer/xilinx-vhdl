# axis_micron_nor_ctrlr_x4

Компонент для работы с флеш-памятью Micron NOR MT25Q с поддержкой режима QuadSPI по четырем битам двунаправленной шины. Поддерживает операции чтения, программирования, стирания, запроса статуса. Поддерживает различные варианты стирания памяти. Работает на командах из мануала на флеш-память MT25Q. 
При конфигурации по умолчанию выполняется команда установки четырехбайтной адресации, так как изначально компонент проектировался под работу с Flash Micron NOR обьемом 1 Гбит, и режим адресации в четыре байта был необходим для возможности адресовать всю память. 

Другие варианты работы, кроме как QuadSPI недоступны.

Примечание: 1 сектор = 64 КБайт

## Список поддерживаемых команд
Команда | Коды команды | Описание  
--------|--------------|----------
Чтение | 0x0b, 0x6b, 0xEB, 0x0C, 0x6C, 0xEC | чтение данных с памяти флеш и выдача их через шину M_AXIS_TDATA. Ограничения на команду - нельзя считать размер данных больше чем сама Flash. Ограничение контролируется извне.
Программирование | 0x3E 0x12 0x34 0x02 0x32 0x38 | Программирование флеш-памяти. Ограничения на команду - запись идет Не более 256 байт данных на одну команду. 
Стирание сектора | 0xDC | Стирание сектора 64 КБайт
Стирание 4 КБайт | 0x21 | Стирание сабсектора 4 КБайт
Стирание 32 КБайт | 0x5c | Стирание сабсектора 32 КБайт
Стирание чипа | 0x4c | Стирание 512 МБит памяти


![axis_micron_nor_ctrlr_x4_struct][axis_micron_nor_ctrlr_x4_struct_link]

[axis_micron_nor_ctrlr_x4_struct_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_init.png

## generic-параметры
Параметр | Тип | Диапазон значений | описание
---------|-----|-------------------|---------
MODE | string | "STARTUPE" или "DIRECT" | выбор каким образом контроллер подключается к FLASH : STARTUPE - через примитив STARTUPE (устанавливается снаружи) или напрямую к двунаправленным буферам(устанавливается снаружи)
ASYNC | boolean | true или false | Возможность работы S_AXIS_CLK и SPI_CLK в разных частотных доменах
SWAP_NIBBLE | boolean | true или false | какой полубайт передавать первым: при `SWAP_NIBBLE=true` передается сначала младший байт, при `SWAP_NIBBLE=false` сначала передается старший байт.

## 1. Порты 

### 1.1. AXI-Stream 

Компонент содержит Slave и Master AXI-Stream порты

#### 1.1.1. Slave AXI-Stream 

Тактируется от S_AXIS_CLK

Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
S_AXIS_TDATA | in | 8 | сигнал данных на запись во FLASH
S_AXIS_TVALID | in | 1 | сигнал валидности данных на шине
S_AXIS_TLAST | in | 1 | сигнал конца пакета
S_AXIS_TREADY | out | 1 | сигнал готовности компонента принимать данные

#### 1.1.2. Master AXI-Stream 

Тактируется от S_AXIS_CLK

Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
M_AXIS_TDATA | out | 8 | сигнал данных, читаемых с FLASH
M_AXIS_TVALID | out | 1 | сигнал валидности читаемых данных с FLASH
M_AXIS_TLAST | out | 1 | сигнал конца пакета 
M_AXIS_TREADY | in | 1 | сигнал готовности к приему данных(формируется со стороны пользовательской логики)


### 1.2. Сигналы тактирования и сброса 

При ASYNC = true сигналы входы сигналов S_AXIS_CLK, SPI_CLK имеют общий источник

Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
S_AXIS_CLK | in | 1 | Сигнал тактирования для шин S_AXIS_*, M_AXIS_*, *S_AXIS_CMD_*
S_AXIS_RESET | in | 1 | сигнал сброса компонента. Сбрасывает все очереди и пользовательскую логику
SPI_CLK | in | 1 | сигнал тактирования пользовательской логики
C | out | 1 | сигнал тактирования на SPI. Получается путем инверсии SPI_CLK

### 1.3. Сигналы управления 

Управление контроллером идет через шину `S_AXIS_CMD_*`. Протокол обмена - Slave AXI-Stream.


Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
S_AXIS_CMD | in | 8 | команда, которую надо выполнить. Поддерживаемый список команд представлен наверху данного документа. Все остальные команды игнорируются
S_AXIS_CMD_TSIZE | in | 32 | количество байт для обозначения сколько считывать/записывать данных на память.
S_AXIS_CMD_TADDR | in | 32 | начальный адрес 
S_AXIS_CMD_TVALID | in | 1 | валидность команды
S_AXIS_CMD_TREADY | out | 1 | сигнал готовности компонента 

### 1.4. Сигналы статуса

Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
FLASH_STATUS | out | 8 | текущий статус FLASH. необходим для понимания в каком статусе находится FLASH, валиден при `FLASH_STATUS_VALID=1`
FLASH_STATUS_VALID | out | 1 | сигнал валидности статуса
BUSY | out | 1 | флаг занятости конечного автомата. Когда автомат не занят выполнением операции, сигнал равен нулю

### 1.5. Сигналы группы QuadSPI

Название | Направление | Разрядность | Назначение
---------|-------------|-------------|-----------
C | out | 1 | сигнал тактирования на FLASH память. Получается через инверсию SPI_CLK
RESET_OUT | out | 1 | сигнал сброса FLASH. 
DQ_I | in | 4 | сигнал данных от FLASH
DQ_T | out | 4 | сигнал управления tri-state буфером
DQ_O | out | 4 | сигнал данных на FLASH
S | out | 1 | сигнал разрешения работы FLASH (CHIP_SELECT). при нуле - флеш работает. 


## 2. некоторые принципы работы компонента.
- В начальный момент времени флеш должна быть без предустановки работы в режиме QuadSPI, в противном случае не гарантируется корректная работа 
- У компонента есть начальная фаза инициализации, при которой устанавливается режим работы с адресом 4 байта, режим QuadSPI
- Установка конфигурации происходит посредством записи в Volatile-регистр FLASH через последовательный интерфейс (Extended SPI)
- Установка режима адреса 4 байт происходит через команду `ENABLE_FOUR_BYTE_ADDRESS_MODE` (0xB7)
- Компонент умеет читать всю FLASH за одну команду. 
- Компонент умеет стирать FLASH за одну команду(вернее ее половину, в случае если размер флеш = 1 гбит)
- Компонент умеет записывать не более 256 байт за одну команду, контроль размера данных компонент не делает
- При программировании флеш сначала **подаются данные, потом команда**. В противном случае запись на флеш отработает, но данные могут быть искажены. 
- Компонент при выполнении операции записи/стирания сам контролирует занятость FLASH через считывание регистра статуса. Когда FLASH освобождается, компонент переходит в состояние IDLE, опуская при этом BUSY в ноль. Пользователю, таким образом, нужно только контролировать флаг BUSY или порт FLASH_STATUS
- Компонент поддерживает два режима подключения: через примитив STARTUPE (`MODE=STARTUPE`) или напрямую к пинам (`MODE=DIRECT`). Компонент STARTUPE не представлен внутри текущего компонента, он ставится снаружи. При подключении в режиме `MODE=DIRECT` снаружи ставятся двунаправленные буферы ввода-вывода. Ниже нарисован примерный порядок подключения
- Компонент имеет возможность работы в асинхронном режиме. При `ASYNC=true` шины `S_AXIS_*`, `M_AXIS_*`, `S_AXIS_CMD` тактируются от `S_AXIS_CLK`, вся внутренняя логика при этом работает от `SPI_CLK`. Такая конфигурация позволяет достигать удобной интеграции в проект, в котором шины интерфейсов AXI-Stream могут работать на высоких частотах, а интерфейс между FLASH и компонентом при этом работают на более медленных скоростях. 
- Сигнал сброса может отсутствовать в интерфейсе на FLASH
- Сигнал тактирования подается всегда, вне зависимости от того выполняется команда на компоненте или нет. 
- Сигнал CS активен при нуле. При выполнении операций сигнал CS устанавливается в ноль. При простое, когда никакая команда не выполняется, сигнал CS=1. 
- Если при чтении данных, пользовательская логика не может принять текущую порцию данных, то конечный автомат переходит в состояние ожидания возможности передачи данных. При этом FLASH-память, возможно, не переходит в состояние ожидания. Вероятно, данный механизм нужно модифицировать. 

### 2.1 Подключение компонента при MODE=STARTUPE

![axis_micron_nor_ctrlr_x4_startupe][axis_micron_nor_ctrlr_x4_startupe_link]

[axis_micron_nor_ctrlr_x4_startupe_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_startupe.png

### 2.2 Подключение компонента при MODE=DIRECT

![axis_micron_nor_ctrlr_x4_direct][axis_micron_nor_ctrlr_x4_direct_link]

[axis_micron_nor_ctrlr_x4_direct_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_direct.png


## 3. Конечный автомат

Ввиду большого количества состояний, и разделения функций компонента, конечный автомат будет представлен для каждой выполняемой операции отдельно. 

### 3.1 Процесс инициализации 

![axis_micron_nor_ctrlr_x4_fsm_init][axis_micron_nor_ctrlr_x4_fsm_init_link]

[axis_micron_nor_ctrlr_x4_fsm_init_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_init.png

#### 3.1.1 Состояния конечного автомата процесса инициализации

Текущее состояние | Действия | Следующее состояние | Условие перехода
------------------|----------|---------------------|-----------------
RST_ST | Выдаем сигнал сброса наружу 1000 тактов после собственного сброса | W_CFG_REG_WE_CMD_ST | счетчик сброса досчитал до 1000
W_CFG_REG_WE_CMD_ST | Отправляет команду разрешения записи | V_CFG_REG_WE_STUB_ST | Команда полностью передача на устройство (8 отсчетов)
V_CFG_REG_WE_STUB_ST | Ждем паузу между командами 1 такт | V_CFG_REG_CMD_ST | безусловный переход
V_CFG_REG_CMD_ST | Отправляем команду 0x61 (`WRITE ENHANCED VOLATILE CONFIGURATION REGISTER`) на устройство | V_CFG_REG_DATA_ST | Команда полностью передана на устройство (8 отсчетов)
V_CFG_REG_DATA_ST | Отправляем новое значение, которое запишется в регистр | ENABLE_FOUR_BYTE_PREPARE | Данные переданы на устройство
ENABLE_FOUR_BYTE_PREPARE | Выжидаем паузу 8 тактов | ENABLE_FOUR_BYTE_CMD_ST | Пауза 8 тактов прошла
ENABLE_FOUR_BYTE_CMD_ST | Отправляем команду 0xB7 | FINALIZE_ST | счетчик слов = 1(оба полубайта переданы)
FINALIZE_ST | Окончание команды | INIT_ST | Безусловный переход 
IDLE_ST | Ничего не делаем | IDLE_ST | Не представлено здесь

#### 3.1.2. Диаграмма процесса инициализации

![axis_micron_nor_ctrlr_x4_init][axis_micron_nor_ctrlr_x4_init_link]

[axis_micron_nor_ctrlr_x4_init_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_init.png


### 3.2 Операция записи 

![axis_micron_nor_ctrlr_x4_fsm_program][axis_micron_nor_ctrlr_x4_fsm_program_link]

[axis_micron_nor_ctrlr_x4_fsm_program_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_program.png

#### 3.2.1. Состояния конечного автомата операции записи

Текущее состояние | Действия | Следующее состояние | Условие перехода
------------------|----------|---------------------|-----------------
IDLE_ST | Ждем валидную команду на запись | PROGRAM_WE_CMD_ST | Входная очередь команд не пуста и выходные данные совпадают с командой программирования 
PROGRAM_WE_CMD_ST | Отправляем разрешение на программирование | PROGRAM_WE_STUB_ST | Команда полностью передана на устройство
PROGRAM_WE_STUB_ST | Проверяем наличие данных на входе | PROGRAM_CMD_ST | Если во входной FIFO есть данные, то переходим
PROGRAM_CMD_ST | Отправляем команду PROGRAM На FLASH | PROGRAM_ADDR_ST | Команда полностью передана на устройство
PROGRAM_ADDR_ST | Отправка адреса на устройство | PROGRAM_DATA_ST | Адрес полностью передан на устройство 
PROGRAM_DATA_ST | Отправка данных на устройство | PROGRAM_DATA_STUB | Весь обьем данных записан на FLASH
PROGRAM_DATA_STUB_ST | Ждем 1 такт | READ_STATUS_ST | Безусловный переход 
READ_STATUS_CMD_ST | Отправка команды READ_STATUS (0x70) | READ_STATUS_DATA_ST | Команда отправлена полностью 
READ_STATUS_DATA_ST | Чтение статуса с флеш | READ)STATUS_STUB_ST | Статус полностью прочитан (2 такта, 1 байт)
READ_STATUS_STUB_ST | Ждем 1 такт | READ_STATUS_CHK_ST | Безусловный переход
READ_STATUS_CHK_ST | Проверяем статус | READ_STATUS_CMD_ST | Если статус FLASH = занят(`bit7=0`), то переходим к новому запросу статуса с флеш
READ_STATUS_CHK_ST | Проверяем статус | FINALIZE_ST | Если статус FLASH = свободен(`bit7=1`), то переходим к завершению команды
FINALIZE_ST | Завершаем команду | IDLE_ST | Безусловный

#### 3.2.2 Диаграмма процесса записи 

Начало

![axis_micron_nor_ctrlr_x4_programstart][axis_micron_nor_ctrlr_x4_programstart_link]

[axis_micron_nor_ctrlr_x4_programstart_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_programstart.png

Конец

![axis_micron_nor_ctrlr_x4_programend][axis_micron_nor_ctrlr_x4_programend_link]

[axis_micron_nor_ctrlr_x4_programend_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_programend.png

### 3.3 Операция стирания

![axis_micron_nor_ctrlr_x4_fsm_erase][axis_micron_nor_ctrlr_x4_fsm_erase_link]

[axis_micron_nor_ctrlr_x4_fsm_erase_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_erase.png

#### 3.3.1. Состояния конечного автомата операции стирания 


Текущее состояние | Действия | Следующее состояние | Условие перехода
------------------|----------|---------------------|-----------------
IDLE_ST | Ждем валидную команду на стирание | ERASE_WE_CMD_ST | Входная очередь команд не пуста и выходные данные совпадают с командой стирания
ERASE_WE_CMD_ST | Отправляем разрешение стирания | ERASE_WE_STUB_ST | Команда передана полностью
ERASE_WE_STUB_ST | Ждем 1 такт | ERASE_CMD_ST | Безусловный переход 
ERASE_CMD_ST | отправляем команду стирания на устройство | ERASE_ADDR_ST | Команда передана полностью
ERASE_ADDR_ST | Отправляем начальный адрес на устройство | ERASE_STUB_ST | Адрес передан полностью 
ERASE_STUB_ST | Ждем 1 такт | READ_STATUS_CMD_ST | Безусловный переход 
READ_STATUS_CMD_ST | Отправка команды READ_STATUS (0x70) | READ_STATUS_DATA_ST | Команда отправлена полностью 
READ_STATUS_DATA_ST | Чтение статуса с флеш | READ)STATUS_STUB_ST | Статус полностью прочитан (2 такта, 1 байт)
READ_STATUS_STUB_ST | Ждем 1 такт | READ_STATUS_CHK_ST | Безусловный переход
READ_STATUS_CHK_ST | Проверяем статус | READ_STATUS_CMD_ST | Если статус FLASH = занят(`bit7=0`), то переходим к новому запросу статуса с FLASH
READ_STATUS_CHK_ST | Проверяем статус | FINALIZE_ST | Если статус FLASH = свободен(`bit7=1`), то переходим к завершению команды
FINALIZE_ST | Завершаем команду | IDLE_ST | Безусловный

### 3.4 Операция чтения 

Внимание: состояние READ_DATA_WAIT_ABILITY не будут отрабатывать корректно, необходимо внесение изменений

![axis_micron_nor_ctrlr_x4_fsm_read][axis_micron_nor_ctrlr_x4_fsm_read_link]

[axis_micron_nor_ctrlr_x4_fsm_read_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_read.png

Текущее состояние | Действия | Следующее состояние | Условие перехода
------------------|----------|---------------------|-----------------
IDLE_ST | Ждем валидную команду на чтение | READ_CMD_ST | входная очередь команд не пуста и выходные данные очереди совпадают с командой чтения 
READ_CMD_ST | Передача команды чтения | READ_ADDRESS_ST | Команда передана полностью 
READ_ADDRESS_ST | Передача начального адреса | READ_DUMMY_ST | Адрес передан полностью 
READ_DUMMY_ST | Ждем 10 тактов согласно документу на память | READ_DATA_ST | Счетчик досчитал нужное количество тактов сколько нужно ждать 
READ_DATA_ST | Читаем данные с FLASH и передаем их в выходную очередь данных | READ_DATA_WAIT_ABILITY | Выходная очередь заполнилась
READ_DATA_WAIT_ABILITY | Ждем освобождения выходной очереди | READ_DATA_ST | выходная очередь освободилась
READ_DATA_ST | Читаем данные с FLASH и передаем их в выходную очередь данных | FINALIZE_ST | Количество считанных байт достигнуто
FINALIZE_ST | Завершаем команду | IDLE_ST | Безусловный 

### 3.5 Отсутствие валидной команды

Возникает когда записанные данные не содержат в своем составе команды из списка

![axis_micron_nor_ctrlr_x4_fsm_nocmd][axis_micron_nor_ctrlr_x4_fsm_nocmd_link]

[axis_micron_nor_ctrlr_x4_fsm_nocmd_link]:https://github.com/MasterPlayer/xilinx-vhdl/blob/master/axis_infrastructure/axis_micron_nor_ctrlr_x4/documentation/axis_micron_nor_ctrlr_x4_fsm_nocmd.png

## 4. Необходимые внешние компоненты 

Название компонент | Описание
-------------------|---------
[fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/ffifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | Входная очередь команд, используется когда `ASYNC=false`
[fifo_cmd_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_async_xpm/fifo_cmd_async_xpm.vhd) | Входная очередь команд, используется когда `ASYNC=true`
[fifo_in_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fififo_in_sync_xpm/fifo_in_sync_xpm.vhd) | Входная очередь данных, используется при выполнении операции записи на FLASH когда `ASYNC=false`
[fifo_in_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/ffifo_in_async_xpm/fifo_in_async_xpm.vhd) | Входная очередь данных, используется при выполнении операции записи на FLASH когда `ASYNC=true`
[fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/ffifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | Выходная очередь данных, используется при чтении данных с FLASH когда `ASYNC=false`
[fifo_out_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_xpm/fifo_out_async_xpm.vhd) | Выходная очередь данных, используется при чтении данных с FLASH когда `ASYNC=true`

## 5. Тестирование

### 5.1 Скорости

Компонент тестирован при работе с реальной FLASH-памятью `Micron NOR MT25Q`, объемом 1 Гбит. Сбоев в процессе работы не наблюдалось, при этом получились значения скорости следующие. 

При этом, надо понимать что время выполнения операций стирания/программирования зависит от характера самих данных. Это свойство самой флеш

Был написан внешний компонент который создавал запросы к текущему модулю и задавал процесс записи/стирания. Данные состояли из 32-битного счетчика. Для всех операций записи проводилась проверка путем чтения флеш и проверкой внешним компонентом. При стирании проводилась проверка на то, что все биты равны единице. В таблице будут указаны минимальные скорости. Простым языком - флеш записывалась от начала до конца, засекалось время, потом вычитывалась и проверялась, затем стиралась, и так несколько раз различными командами. 

Operation | Volume, Bytes | Speed, MB/s | Total Time, seconds
----------|---------------|-------------|--------------------
ERASE_DIE0 | 67108864 | 0.588 | 114 
ERASE_DIE1 | 67108864 | 0.583 | 115
ERASE_SECTOR | 134217728 | 0.571 | 235
ERASE_SUBSECTOR_32K | 134217728 | 0.415 | 324
ERASE_SUBSECTOR_4K | 134217728 | 0.251 | 534
PROGRAM | 134217728 | 1.29 | 104

### 5.2 Тайминги

Тайминги оценивались по простой схеме - засекалось количество тактов, сколько компонент находится в состоянии BUSY при выполнении каждой команды используя разные адреса и разные данные. Далее все результаты измерений заносились в таблицу, искали минимум и максимум, и вычисляли среднее значение выполнения команды. Результаты представлены ниже

Operation | Size, Bytes | Time AVG, sec | Time MIN, sec | Time MAX, sec
----------|-------------|---------------|---------------|--------------
ERASE | 65536 | 0.115 | 0.121 | 0.110
ERASE | 32768 | 0.080 | 0.123 | 0.076 
ERASE | 4096 | 0.017 | 0.023 | 0.016 
PROGRAM | 256 | 0.000190 | 0.0002 | 0.0001


## 6. Лог изменений

**1. 03.05.2021 : v1.0 - первая версия**
Добавлен компонент и документация к нему с рисунками и диаграммами

