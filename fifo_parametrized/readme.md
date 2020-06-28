# fifo_parametrized

Каталог содержит набор примитивов XPM. Эти примитивы содержат FIFO-очереди в различных конфигурациях для организации поддержки AXI-Stream.
Ниже представлен список ядер, и представлен список компонентов, которые их используют

Название | описание | используется 
---------|----------|-------------
[fifo_out_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_async_xpm/fifo_out_async_xpm.vhd) | асинхронная очередь для реализации в качестве Master AXI-Stream | [**axis_dump_gen**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen)
[fifo_out_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm/fifo_out_sync_xpm.vhd) | синхронная очередь для реализации в качестве Master AXI-Stream | [**axis_dump_gen**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen)
[fifo_out_sync_xpm_id](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_out_sync_xpm_id/fifo_out_sync_xpm_id.vhd) | синхронная очередь для реализации в качестве Master AXI-Stream с поддержкой поля TID | [**axis_collector**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_collector)
[fifo_cmd_async_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_async_xpm/fifo_cmd_async_xpm.vhd) | асинхронная очередь для поддержки команд | [**axis_collector**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_collector)
[fifo_cmd_sync_xpm](https://github.com/MasterPlayer/xilinx-vhdl/blob/master/fifo_parametrized/fifo_cmd_sync_xpm/fifo_cmd_sync_xpm.vhd) | синхронная очередь для поддержки команд | [**axis_collector**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_collector)