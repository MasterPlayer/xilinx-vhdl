# fifo_parametrized

Каталог содержит набор примитивов XPM. Эти примитивы содержат FIFO-очереди в различных конфигурациях для организации поддержки AXI-Stream.
Ниже представлен список ядер, и представлен список компонентов, которые их используют

1. [**fifo_out_async_xpm**] - асинхронная очередь для реализации в качестве Master AXI-Stream

используется : 

- [**axis_dump_gen**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen)


2. [**fifo_out_sync_xpm**] - синхронная очередь для реализации в качестве Master AXI-Stream

используется 

- [**axis_dump_gen**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen)
