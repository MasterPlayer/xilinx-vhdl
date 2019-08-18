library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

library UNISIM;
    use UNISIM.VComponents.all;

Library xpm;
    use xpm.vcomponents.all;



entity fifo_cmd_sync_xpm is
    generic(
        DATA_WIDTH      :           integer         :=  64                          ;
        MEMTYPE         :           String          :=  "block"                     ;
        DEPTH           :           integer         :=  16                           
    );
    port(
        CLK             :   in      std_logic                                       ;
        RESET           :   in      std_logic                                       ;
        
        DIN             :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )      ;
        WREN            :   in      std_logic                                       ;
        FULL            :   out     std_logic                                       ;
        DOUT            :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
        RDEN            :   IN      std_logic                                       ;
        EMPTY           :   out     std_logic                                        

    );
end fifo_cmd_sync_xpm;



architecture fifo_cmd_sync_xpm_arch of fifo_cmd_sync_xpm is
    
    constant FIFO_DATA_COUNT_W  :   integer := integer(ceil(log2(real(DEPTH))));

begin


    xpm_cmd_fifo_sync_inst : xpm_fifo_sync
        generic map (
            DOUT_RESET_VALUE        =>  "0"                 ,
            ECC_MODE                =>  "no_ecc"            ,
            FIFO_MEMORY_TYPE        =>  MEMTYPE             ,
            FIFO_READ_LATENCY       =>  0                   ,
            FIFO_WRITE_DEPTH        =>  DEPTH               ,
            FULL_RESET_VALUE        =>  1                   ,
            PROG_EMPTY_THRESH       =>  10                  ,
            PROG_FULL_THRESH        =>  10                  ,
            RD_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   ,   -- DECIMAL
            READ_DATA_WIDTH         =>  DATA_WIDTH          ,
            READ_MODE               =>  "fwft"              ,
            USE_ADV_FEATURES        =>  "0000"              ,
            WAKEUP_TIME             =>  0                   ,
            WRITE_DATA_WIDTH        =>  DATA_WIDTH          ,
            WR_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W       -- DECIMAL
        )
        port map (
            almost_empty            =>  open                ,
            almost_full             =>  open                ,
            data_valid              =>  open                ,
            dbiterr                 =>  open                ,
            dout                    =>  DOUT                ,
            empty                   =>  EMPTY               ,
            full                    =>  FULL                ,
            overflow                =>  open                ,
            prog_empty              =>  open                ,
            prog_full               =>  open                ,
            rd_data_count           =>  open                ,
            rd_rst_busy             =>  open                ,
            sbiterr                 =>  open                ,
            underflow               =>  open                ,
            wr_ack                  =>  open                ,
            wr_data_count           =>  open                ,
            wr_rst_busy             =>  open                ,
            din                     =>  DIN                 ,
            injectdbiterr           =>  '0'                 ,
            injectsbiterr           =>  '0'                 ,
            rd_en                   =>  RDEN                ,
            rst                     =>  RESET               ,
            sleep                   =>  '0'                 ,
            wr_clk                  =>  CLK                 ,
            wr_en                   =>  WREN                 
        );

end fifo_cmd_sync_xpm_arch;
