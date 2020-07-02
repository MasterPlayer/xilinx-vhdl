# axis_infrastructure

№ | Название | Описание 
--|------|------------
1 | [**axis_dump_gen**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_dump_gen) | генератор данных с поддержкой AXI-Stream, конфигурацией размера пакета, пауз, возможностью старта и остановки. Разрядность шины конфигурируема
2 | [**axis_checker**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_checker) | Блок проверки значений с генератора данных с поддержкой AXI-Stream. Компонент работает как Slave AXI-Stream. Разрядность конфигурируемая.
3 | [**axis_collector**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_collector) | Компонент для сбора, хранения, упорядочивания и передачи данных, поступающих с разных каналов. 
4 | [**axis_arb_2_to_1**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_arb_2_to_1) | арбитр 2 в 1 с равным приоритетом и опросом по кольцу
5 | [**axis_pkt_sw_2_to_1**](https://github.com/MasterPlayer/xilinx-vhdl/tree/master/axis_infrastructure/axis_pkt_sw_2_to_1) | арбитр 2 в 1 с равным приоритетом, опросом по кольцу. Арбитр копит входные пакеты, и передает на выход только полностью готовые пакеты.