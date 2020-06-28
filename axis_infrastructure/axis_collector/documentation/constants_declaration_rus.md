Данный файл содержит объявления констант, описание регистров и каким образом вычисляются их параметры. Может понадобиться в ту минуту, когда надо будет по-быстрому скорректировать компонент и вспомнить каким образом что-либо вычисляется

## Константы: 

Следующие параметры участвуют в вычислении размеров шин и зависят от generic-параметров
Название | Формула | Описание
---------|---------|---------
WORDA_WIDTH | `N_BYTES_IN*8` | Необходим для вычисления размера входного слова к памяти RAM
WORDB_WIDTH | `N_BYTES_OUT*8` | Необходим для вычисления размера выходного слова при чтении памяти RAM
ADDRA_WIDTH | `log2((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_IN)` | Необходим для вычисления разрядности адреса записи в RAM
ADDRB_WIDTH | `log2((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_OUT` | Необходим для вычисления разрядности адреса чтения в RAM 
SEG_CNT_WIDTH | `log2(SEGMENT_BYTE_SIZE/N_BYTES_IN)` | Разрядность регистра сегмента памяти
SEG_PART_LIMIT | `SEG_CNT_WIDTH - log2(SEGMENT_MAX_PKTS)` | предел счета для счетчика пакетов внутри одного сегмента
DIFF_CNT_PART | `SEG_CNT_WIDTH - SEG_PART_LIMIT` | Количество бит в регистре счетчика сегмента, который предназначен для сигнализации о наличии готового пакета 
ALL_ONES | `SEG_PART_LIMIT` | регистр для хранения всех единиц для сравнения с счетчиком адреса сегмента для сигнализации о наличии готовых пакетов
HI_ADDRA  | `ADDRA_WIDTH - SEG_PART_LIMIT` | разрядность регистра который предназначен для передачи на логику чтения
BYTES_PER_PKT | `SEGMENT_BYTE_SIZE/SEGMENT_MAX_PKTS` | количество байт на пакет внутри одного сегмента. Необходим для интерфейса чтения
CNTB_LIMIT | `BYTES_PER_PKT/N_BYTES_OUT` | предел счета для регистра CNTB, которые предназначен для чтения одного пакета из памяти
CNTB_WIDTH | `log2(CNTB_LIMIT)` | разрядность регистра CNTB
CNTB_LIMIT_VECTOR | CNTB_WIDTH | регистр для хранения единиц для сравнения адреса счетчика для завершения процесса чтения пакета
CMD_FIFO_WIDTH | `ADDRA_WIDTH - HI_ADDRA` | разрядность очереди FIFO для передачи между логикой записи и логикой чтения сегмента(или части сегмента, если сегмент хранит несколько пакетов), который необходимо вычитывать
FIFO_DEPTH | `SEGMENT_MAX_PKTS*N_CHANNELS` | глубина командной очереди 
CNTA_PART | `ADDRA_WIDTH - (S_AXIS_TID'length + S_AXIS_TUSER'length)` | количество бит счетчика адреса, который участвует в формировании адреса ADDRA. 


## Регистры 
Название | Назначение
---------|-----------
wea | write enable for memory 
addra | address bus for PORTA
dina | data register 
addrb | address bus for PORTB
doutb | data output from memory PORTB
addra_vector | array of counters for addressation in each segment of memory(when used `ADDR_USE = "high"`). For `ADDR_USE = "full"` this register count for input words, and used for determine where to write current packet.
event_compl_vector | register for indicating event of finished packet in segment
cntb | counter for segment for PORTB of RAM
