library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

Library xpm;
    use xpm.vcomponents.all;



entity fifo_in_sync_user_ae_xpm is
    generic(
        DATA_WIDTH      :           integer         :=  16                              ;
        USER_WIDTH      :           integer         :=  1                               ;
        MEMTYPE         :           String          :=  "block"                         ;
        DEPTH           :           integer         :=  16                              
    );
    port(
        CLK             :   in      std_logic                                               ;
        RESET           :   in      std_logic                                               ;
        
        S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
        S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )          ;
        S_AXIS_TUSER    :   in      std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
        S_AXIS_TVALID   :   in      std_logic                                               ;
        S_AXIS_TLAST    :   in      std_logic                                               ;
        S_AXIS_TREADY   :   out     std_logic                                               ;

        IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
        IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
        IN_DOUT_USER    :   out     std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
        IN_DOUT_LAST    :   out     std_logic                                               ;
        IN_RDEN         :   in      std_logic                                               ;
        IN_AEMPTY       :   out     std_logic                                               ;
        IN_EMPTY        :   out     std_logic                                                
    );
end fifo_in_sync_user_ae_xpm;



architecture fifo_in_sync_user_ae_xpm_arch of fifo_in_sync_user_ae_xpm is

    constant VERSION            :           string := "v1.0";

    constant FIFO_DATA_COUNT_W  :           integer := integer(ceil(log2(real(DEPTH))))                         ;
    constant FIFO_WIDTH         :           integer := ((DATA_WIDTH + (DATA_WIDTH/8)) + 1) + USER_WIDTH         ;

    signal  full                :           std_logic                                                           ;
    signal  din                 :           std_logic_vector ( FIFO_WIDTH-1 downto 0 )                          ;
    signal  dout                :           std_logic_vector ( FIFO_WIDTH-1 downto 0 )                          ;
    
    signal  wren                :           std_logic                                   := '0'                  ;

begin

    

    S_AXIS_TREADY <= not (full);
    wren <= '1' when full = '0' and S_AXIS_TVALID = '1' else '0' ;

    din <= S_AXIS_TUSER & S_AXIS_TLAST & S_AXIS_TKEEP & S_AXIS_TDATA;

    
    IN_DOUT_DATA <= dout( DATA_WIDTH-1 downto 0 ) ;
    IN_DOUT_KEEP <= dout( ((DATA_WIDTH + (DATA_WIDTH/8))-1) downto DATA_WIDTH );
    IN_DOUT_LAST <= dout( DATA_WIDTH + (DATA_WIDTH/8));
    IN_DOUT_USER <= dout(FIFO_WIDTH-1 downto (FIFO_WIDTH - USER_WIDTH));


    fifo_in_sync_xpm_isnt : xpm_fifo_sync
        generic map (
            DOUT_RESET_VALUE        =>  "0"                 ,
            ECC_MODE                =>  "no_ecc"            ,
            FIFO_MEMORY_TYPE        =>  MEMTYPE             ,
            FIFO_READ_LATENCY       =>  0                   ,
            FIFO_WRITE_DEPTH        =>  DEPTH               ,
            FULL_RESET_VALUE        =>  1                   ,
            PROG_EMPTY_THRESH       =>  10                  ,
            PROG_FULL_THRESH        =>  10                  ,
            RD_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   ,
            READ_DATA_WIDTH         =>  FIFO_WIDTH          ,
            READ_MODE               =>  "fwft"              ,
            --SIM_ASSERT_CHK          =>  0                   ,
            USE_ADV_FEATURES        =>  "0800"              ,
            WAKEUP_TIME             =>  0                   ,
            WRITE_DATA_WIDTH        =>  FIFO_WIDTH          ,
            WR_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   
        )
        port map (
            almost_empty            =>  IN_AEMPTY           ,
            almost_full             =>  open                ,
            data_valid              =>  open                ,
            dbiterr                 =>  open                ,
            dout                    =>  DOUT                ,
            empty                   =>  IN_EMPTY            ,
            full                    =>  full                ,
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
            din                     =>  din                 ,
            injectdbiterr           =>  '0'                 ,
            injectsbiterr           =>  '0'                 ,
            rd_en                   =>  IN_RDEN             ,
            rst                     =>  RESET               ,
            sleep                   =>  '0'                 ,
            wr_clk                  =>  CLK                 ,
            wr_en                   =>  wren                 
        );


            
end fifo_in_sync_user_ae_xpm_arch;
