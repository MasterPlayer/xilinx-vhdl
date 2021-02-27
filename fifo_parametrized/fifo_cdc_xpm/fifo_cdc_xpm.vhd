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


entity fifo_cdc_xpm is
    generic(
        DATA_WIDTH      :           integer         :=  256                         ;
        CDC_SYNC        :           integer         :=  4                           ;
        MEMTYPE         :           String          :=  "block"                     ;
        DEPTH           :           integer         :=  16                           
    );
    port(
        S_AXIS_CLK      :   in      std_logic                                       ;
        S_AXIS_RESET    :   in      std_logic                                       ;        
        S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
        S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
        S_AXIS_TVALID   :   in      std_logic                                       ;
        S_AXIS_TLAST    :   in      std_logic                                       ;
        S_AXIS_TREADY   :   out     std_logic                                       ;

        M_AXIS_CLK      :   in      std_logic                                       ;
        M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
        M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
        M_AXIS_TVALID   :   out     std_logic                                       ;
        M_AXIS_TLAST    :   out     std_logic                                       ;
        M_AXIS_TREADY   :   in      std_logic                                        
    );
end fifo_cdc_xpm;



architecture fifo_cdc_xpm_arch of fifo_cdc_xpm is

    constant FIFO_WIDTH :           integer := DATA_WIDTH + ((DATA_WIDTH/8) + 1);
    constant FIFO_DATA_COUNT_W  :   integer := integer(ceil(log2(real(DEPTH))));

    ATTRIBUTE X_INTERFACE_INFO  : STRING;
    ATTRIBUTE X_INTERFACE_INFO of S_AXIS_RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of S_AXIS_RESET: SIGNAL is "POLARITY ACTIVE_HIGH";
    
    signal  din         :           std_logic_vector ( FIFO_WIDTH-1 downto 0 ) := (others => '0')   ;
    signal  wren        :           std_logic                                  := '0'               ;
    signal  full        :           std_logic                                                       ;

    signal  dout        :           std_logic_vector ( FIFO_WIDTH-1 downto 0 )                      ;
    signal  rden        :           std_logic                                  := '0'               ;
    signal  empty       :           std_logic                                                       ;

begin

    din     <= S_AXIS_TLAST & S_AXIS_TKEEP & S_AXIS_TDATA;
    wren    <= '1' when full = '0' and S_AXIS_TVALID = '1' else '0';


    rden    <= '1' when empty = '0' and M_AXIS_TREADY = '1' else '0';
   
    M_AXIS_TDATA <= dout( DATA_WIDTH-1 downto 0 ) ;
    M_AXIS_TKEEP <= dout( ((DATA_WIDTH + (DATA_WIDTH/8))-1) downto DATA_WIDTH );
    M_AXIS_TLAST <= dout( DATA_WIDTH + (DATA_WIDTH/8));
    M_AXIS_TVALID <= not (empty)    ;

    S_AXIS_TREADY <= not(full);

    fifo_cdc_xpm_inst : xpm_fifo_async
        generic map (
            CDC_SYNC_STAGES         =>  CDC_SYNC                    ,   -- DECIMAL
            DOUT_RESET_VALUE        =>  "0"                         ,   -- String
            ECC_MODE                =>  "no_ecc"                    ,   -- String
            FIFO_MEMORY_TYPE        =>  MEMTYPE                     ,   -- String
            FIFO_READ_LATENCY       =>  0                           ,   -- DECIMAL
            FIFO_WRITE_DEPTH        =>  DEPTH                       ,   -- DECIMAL
            FULL_RESET_VALUE        =>  1                           ,   -- DECIMAL
            PROG_EMPTY_THRESH       =>  10                          ,   -- DECIMAL
            PROG_FULL_THRESH        =>  10                          ,   -- DECIMAL
            RD_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W           ,   -- DECIMAL
            READ_DATA_WIDTH         =>  FIFO_WIDTH                  ,   -- DECIMAL
            READ_MODE               =>  "fwft"                      ,   -- String
            RELATED_CLOCKS          =>  0                           ,   -- DECIMAL
            USE_ADV_FEATURES        =>  "0000"                      ,   -- String
            WAKEUP_TIME             =>  0                           ,   -- DECIMAL
            WRITE_DATA_WIDTH        =>  FIFO_WIDTH                  ,   -- DECIMAL
            WR_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W               -- DECIMAL
        )
        port map (
            almost_empty            =>  open                        ,
            almost_full             =>  open                        ,
            data_valid              =>  open                        ,
            dbiterr                 =>  open                        ,
            dout                    =>  dout                        ,
            empty                   =>  empty                       ,
            full                    =>  full                        ,
            overflow                =>  open                        ,
            prog_empty              =>  open                        ,
            prog_full               =>  open                        ,
            rd_data_count           =>  open                        ,
            rd_rst_busy             =>  open                        ,
            sbiterr                 =>  open                        ,
            underflow               =>  open                        ,
            wr_ack                  =>  open                        ,
            wr_data_count           =>  open                        ,
            wr_rst_busy             =>  open                        ,
            din                     =>  din                         ,
            injectdbiterr           =>  '0'                         ,
            injectsbiterr           =>  '0'                         ,
            rd_clk                  =>  M_AXIS_CLK                  ,
            rd_en                   =>  rden                        ,
            rst                     =>  S_AXIS_RESET                ,
            sleep                   =>  '0'                         ,
            wr_clk                  =>  S_AXIS_CLK                  ,
            wr_en                   =>  wren                     
        );



end fifo_cdc_xpm_arch;
