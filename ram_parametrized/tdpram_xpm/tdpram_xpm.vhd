library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

Library xpm;
    use xpm.vcomponents.all;


library UNISIM;
    use UNISIM.VComponents.all;


entity tdpram_xpm is
    generic(
        ADDR_WIDTH  :           integer :=   5                              ;
        DATA_WIDTH  :           integer := 144                              ; 
        ASYNC       :           boolean := false                            ;
        MEMORY_PRIM :           string  := "block"                          ;
        READ_LATENCY_A : integer := 2               ;
        READ_LATENCY_B : integer := 2
    );
    port(
        CLKA        :   in      std_logic                                   ;
        RSTA        :   in      std_logic                                   ;
        ADDRA       :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )  ;
        DINA        :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )  ;
        WEA         :   in      std_logic                                   ;
        DOUTA       :   out     std_logic_vector ( DATA_WIDTH-1 downto 0 )  ;
        CLKB        :   in      std_logic                                   ;
        RSTB        :   in      std_logic                                   ;
        ADDRB       :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )  ;
        DINB        :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )  ;
        WEB         :   in      std_logic                                   ;
        DOUTB       :   out     std_logic_vector ( DATA_WIDTH-1 downto 0 )  
    );
end tdpram_xpm;



architecture tdpram_xpm_arch of tdpram_xpm is

    constant    DEPTH        :  integer         := 2**ADDR_WIDTH;
    constant    MEMORY_SIZE  :  integer         := DATA_WIDTH * DEPTH;


begin

    SYNC_MODE_GEN : if ASYNC = false generate 
        xpm_memory_tdpram_sync_inst : xpm_memory_tdpram
            generic map (
                ADDR_WIDTH_A                =>  ADDR_WIDTH          ,
                ADDR_WIDTH_B                =>  ADDR_WIDTH          ,
                AUTO_SLEEP_TIME             =>  0                   ,
                BYTE_WRITE_WIDTH_A          =>  DATA_WIDTH          ,
                BYTE_WRITE_WIDTH_B          =>  DATA_WIDTH          ,
                --CASCADE_HEIGHT              =>  0                   ,
                CLOCKING_MODE               =>  "common_clock"      ,
                ECC_MODE                    =>  "no_ecc"            ,
                MEMORY_INIT_FILE            =>  "none"              ,
                MEMORY_INIT_PARAM           =>  "0"                 ,
                MEMORY_OPTIMIZATION         =>  "true"              ,
                MEMORY_PRIMITIVE            =>  MEMORY_PRIM         ,
                MEMORY_SIZE                 =>  MEMORY_SIZE         ,
                MESSAGE_CONTROL             =>  0                   ,
                READ_DATA_WIDTH_A           =>  DATA_WIDTH          ,
                READ_DATA_WIDTH_B           =>  DATA_WIDTH          ,
                READ_LATENCY_A              =>  READ_LATENCY_A      ,
                READ_LATENCY_B              =>  READ_LATENCY_B      ,
                READ_RESET_VALUE_A          =>  "0"                 ,
                READ_RESET_VALUE_B          =>  "0"                 ,
                RST_MODE_A                  =>  "SYNC"              ,
                RST_MODE_B                  =>  "SYNC"              ,
                --SIM_ASSERT_CHK              =>  0                   ,
                USE_EMBEDDED_CONSTRAINT     =>  0                   ,
                USE_MEM_INIT                =>  1                   ,
                WAKEUP_TIME                 =>  "disable_sleep"     ,
                WRITE_DATA_WIDTH_A          =>  DATA_WIDTH          ,
                WRITE_DATA_WIDTH_B          =>  DATA_WIDTH          ,
                WRITE_MODE_A                =>  "read_first"       ,
                WRITE_MODE_B                =>  "read_first"         
            )
            port map (
                dbiterra                    =>  open                ,
                dbiterrb                    =>  open                ,
                douta                       =>  DOUTA               ,
                doutb                       =>  DOUTB               ,
                sbiterra                    =>  open                ,
                sbiterrb                    =>  open                ,
                addra                       =>  ADDRA               ,
                addrb                       =>  ADDRB               ,
                clka                        =>  CLKA                ,
                clkb                        =>  CLKB                ,
                dina                        =>  DINA                ,
                dinb                        =>  DINB                ,
                ena                         =>  '1'                 ,
                enb                         =>  '1'                 ,
                injectdbiterra              =>  '0'                 ,
                injectdbiterrb              =>  '0'                 ,
                injectsbiterra              =>  '0'                 ,
                injectsbiterrb              =>  '0'                 ,
                regcea                      =>  '1'                 ,
                regceb                      =>  '1'                 ,
                rsta                        =>  RSTA                ,
                rstb                        =>  RSTB                ,
                sleep                       =>  '0'                 ,
                wea(0)                      =>  WEA                 ,
                web(0)                      =>  WEB                  
             );
    end generate SYNC_MODE_GEN;

    ASYNC_MODE_GEN : if ASYNC = true generate 
        xpm_memory_tdpram_async_inst : xpm_memory_tdpram
            generic map (
                ADDR_WIDTH_A                =>  ADDR_WIDTH          ,
                ADDR_WIDTH_B                =>  ADDR_WIDTH          ,
                AUTO_SLEEP_TIME             =>  0                   ,
                BYTE_WRITE_WIDTH_A          =>  DATA_WIDTH          ,
                BYTE_WRITE_WIDTH_B          =>  DATA_WIDTH          ,
                --CASCADE_HEIGHT              =>  0                   ,
                CLOCKING_MODE               =>  "independent_clock" ,
                ECC_MODE                    =>  "no_ecc"            ,
                MEMORY_INIT_FILE            =>  "none"              ,
                MEMORY_INIT_PARAM           =>  "0"                 ,
                MEMORY_OPTIMIZATION         =>  "true"              ,
                MEMORY_PRIMITIVE            =>  MEMORY_PRIM         ,
                MEMORY_SIZE                 =>  MEMORY_SIZE         ,
                MESSAGE_CONTROL             =>  0                   ,
                READ_DATA_WIDTH_A           =>  DATA_WIDTH          ,
                READ_DATA_WIDTH_B           =>  DATA_WIDTH          ,
                READ_LATENCY_A              =>  READ_LATENCY_A      ,
                READ_LATENCY_B              =>  READ_LATENCY_B      ,
                READ_RESET_VALUE_A          =>  "0"                 ,
                READ_RESET_VALUE_B          =>  "0"                 ,
                RST_MODE_A                  =>  "SYNC"              ,
                RST_MODE_B                  =>  "SYNC"              ,
                --SIM_ASSERT_CHK              =>  0                   ,
                USE_EMBEDDED_CONSTRAINT     =>  0                   ,
                USE_MEM_INIT                =>  1                   ,
                WAKEUP_TIME                 =>  "disable_sleep"     ,
                WRITE_DATA_WIDTH_A          =>  DATA_WIDTH          ,
                WRITE_DATA_WIDTH_B          =>  DATA_WIDTH          ,
                WRITE_MODE_A                =>  "read_first"        ,
                WRITE_MODE_B                =>  "read_first"         
            )
            port map (
                dbiterra                    =>  open                ,
                dbiterrb                    =>  open                ,
                douta                       =>  DOUTA               ,
                doutb                       =>  DOUTB               ,
                sbiterra                    =>  open                ,
                sbiterrb                    =>  open                ,
                addra                       =>  ADDRA               ,
                addrb                       =>  ADDRB               ,
                clka                        =>  CLKA                ,
                clkb                        =>  CLKB                ,
                dina                        =>  DINA                ,
                dinb                        =>  DINB                ,
                ena                         =>  '1'                 ,
                enb                         =>  '1'                 ,
                injectdbiterra              =>  '0'                 ,
                injectdbiterrb              =>  '0'                 ,
                injectsbiterra              =>  '0'                 ,
                injectsbiterrb              =>  '0'                 ,
                regcea                      =>  '1'                 ,
                regceb                      =>  '1'                 ,
                rsta                        =>  RSTA                ,
                rstb                        =>  RSTB                ,
                sleep                       =>  '0'                 ,
                wea(0)                      =>  WEA                 ,
                web(0)                      =>  WEB                  
             );
    end generate ASYNC_MODE_GEN;



end tdpram_xpm_arch;
