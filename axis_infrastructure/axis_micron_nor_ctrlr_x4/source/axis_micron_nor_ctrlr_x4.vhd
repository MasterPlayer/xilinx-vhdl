library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_Logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;

entity axis_micron_nor_ctrlr_x4 is
    generic (
        MODE                :           string := "STARTUPE"; -- "STARTUPE - connect to STARTUPE primitive, "DIRECT - connect to pins" 
        ASYNC               :           boolean := true  ;
        SWAP_NIBBLE         :           boolean := true   
    );
    port(
        S_AXIS_CLK          :   in      std_logic                           ;
        S_AXIS_RESET        :   in      std_logic                           ;

        S_AXIS_CMD          :   in      std_logic_Vector (  7 downto 0 )    ;
        S_AXIS_CMD_TSIZE    :   in      std_logic_vector ( 31 downto 0 )    ;
        S_AXIS_CMD_TADDR    :   in      std_logic_vector ( 31 downto 0 )    ;
        S_AXIS_CMD_TVALID   :   in      std_logic                           ;
        S_AXIS_CMD_TREADY   :   out     std_logic                           ;

        S_AXIS_TDATA        :   in      std_logic_vector (  7 downto 0 )    ;
        S_AXIS_TVALID       :   in      std_logic                           ;
        S_AXIS_TREADY       :   out     std_logic                           ;
        S_AXIS_TLAST        :   in      std_Logic                           ;

        M_AXIS_TVALID       :   out     std_Logic                           ;
        M_AXIS_TDATA        :   out     std_logic_Vector (  7 downto 0 )    ;
        M_AXIS_TREADY       :   in      std_logic                           ;
        M_AXIS_TLAST        :   out     std_logic                           ;

        SPI_CLK             :   in      std_logic                           ;

        FLASH_STATUS        :   out     std_Logic_vector (  7 downto 0 )    ;
        FLASH_STATUS_VALID  :   out     std_logic                           ;

        BUSY                :   out     std_logic                           ;

        C                   :   out     std_logic                           ;
        RESET_OUT           :   out     std_logic                           ;
        DQ_I                :   in      std_Logic_Vector ( 3 downto 0 )     ;
        DQ_T                :   out     std_Logic_Vector ( 3 downto 0 )     ;
        DQ_O                :   out     std_Logic_Vector ( 3 downto 0 )     ;

        S                   :   out     std_logic                           
    );
end axis_micron_nor_ctrlr_x4;



architecture axis_micron_nor_ctrlr_x4_arch of axis_micron_nor_ctrlr_x4 is

    component fifo_cmd_sync_xpm
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
    end component;

    component fifo_cmd_async_xpm
        generic(
            DATA_WIDTH      :           integer         :=  64                          ;
            CDC_SYNC        :           integer         :=  4                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK_WR          :   in      std_logic                                       ;
            RESET_WR        :   in      std_logic                                       ;
            CLK_RD          :   in      std_logic                                       ;
            
            DIN             :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )      ;
            WREN            :   in      std_logic                                       ;
            FULL            :   out     std_logic                                       ;
            DOUT            :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            RDEN            :   IN      std_logic                                       ;
            EMPTY           :   out     std_logic                                        

        );
    end component;

    signal  cmd_full        :           std_logic                                           ;
    signal  cmd_dout        :           std_logic_Vector ( 71 downto 0 )                    ;
    signal  cmd_rden        :           std_logic                                  := '0'   ;
    signal  cmd_empty       :           std_logic                                           ;

    signal  cmd_size        :           std_Logic_Vector ( 31 downto 0 )                    ;
    signal  cmd_addr        :           std_Logic_Vector ( 31 downto 0 )                    ;
    signal  cmd             :           std_Logic_Vector (  7 downto 0 )                    ;


    component fifo_in_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  32                          ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            
            S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            S_AXIS_TVALID   :   in      std_logic                                       ;
            S_AXIS_TLAST    :   in      std_logic                                       ;
            S_AXIS_TREADY   :   out     std_logic                                       ;

            IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            IN_DOUT_LAST    :   out     std_logic                                       ;
            IN_RDEN         :   in      std_logic                                       ;
            IN_EMPTY        :   out     std_logic                                   
        );
    end component;

    component fifo_in_async_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            CDC_SYNC        :           integer         :=  4                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            S_AXIS_CLK      :   in      std_logic                                       ;
            S_AXIS_RESET    :   in      std_logic                                       ;
            M_AXIS_CLK      :   in      std_logic                                       ;
            
            S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            S_AXIS_TVALID   :   in      std_logic                                       ;
            S_AXIS_TLAST    :   in      std_logic                                       ;
            S_AXIS_TREADY   :   out     std_logic                                       ;

            IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            IN_DOUT_LAST    :   out     std_logic                                       ;
            IN_RDEN         :   in      std_logic                                       ;
            IN_EMPTY        :   out     std_logic                                   
        );
    end component;

    signal  in_dout_data    :           std_logic_Vector ( 7 downto 0 ) := (others => '0')  ;
    signal  in_dout_last    :           std_logic                       := '0'              ;
    signal  in_rden         :           std_logic                       := '0'              ;
    signal  in_empty        :           std_logic                                           ;

    component fifo_out_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            
            OUT_DIN_DATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP    :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_LAST    :   in      std_logic                                       ;
            OUT_WREN        :   in      std_logic                                       ;
            OUT_FULL        :   out     std_logic                                       ;
            OUT_AWFULL      :   out     std_logic                                       ;
            
            M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TVALID   :   out     std_logic                                       ;
            M_AXIS_TLAST    :   out     std_logic                                       ;
            M_AXIS_TREADY   :   in      std_logic                                        
        );
    end component;

    component fifo_out_async_xpm
        generic(
            DATA_WIDTH      :           integer         :=  256                         ;
            CDC_SYNC        :           integer         :=  4                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;        
            OUT_DIN_DATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP    :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_LAST    :   in      std_logic                                       ;
            OUT_WREN        :   in      std_logic                                       ;
            OUT_FULL        :   out     std_logic                                       ;
            OUT_AWFULL      :   out     std_logic                                       ;

            M_AXIS_CLK      :   in      std_logic                                       ;
            M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TVALID   :   out     std_logic                                       ;
            M_AXIS_TLAST    :   out     std_logic                                       ;
            M_AXIS_TREADY   :   in      std_logic                                        

        );
    end component;

    signal  out_din_data    :           std_logic_Vector ( 7 downto 0 ) := (others => '0')      ;
    signal  out_din_last    :           std_logic                       := '0'                  ;
    signal  d_out_din_last  :           std_logic                       := '0'                  ;
    signal  out_wren        :           std_logic                       := '0'                  ;
    signal  d_out_wren      :           std_logic                       := '0'                  ;
    signal  out_full        :           std_logic                                               ;
    signal  out_awfull      :           std_logic                                               ;

    type fsm is (
        RST_ST                          ,

        V_CFG_REG_WE_CMD_ST             ,
        V_CFG_REG_WE_STUB_ST            ,
        V_CFG_REG_CMD_ST                ,
        V_CFG_REG_DATA_ST               ,

        ENABLE_FOUR_BYTE_PREPARE_ST     ,
        ENABLE_FOUR_BYTE_CMD_ST         ,

        IDLE_ST                         ,

        READ_ID_CMD_ST                  ,
        READ_ID_DATA_ST                 ,

        READ_CMD_ST                     ,
        READ_ADDRESS_ST                 ,
        READ_DUMMY_ST                   ,
        READ_DATA_ST                    ,
        READ_DATA_WAIT_ABILITY_ST       ,

        PROGRAM_WE_CMD_ST               ,
        PROGRAM_WE_STUB_ST              ,
        PROGRAM_CMD_ST                  , --0x34h
        PROGRAM_ADDR_ST                 ,
        PROGRAM_DATA_ST                 ,
        PROGRAM_DATA_STUB_ST            , 

        READ_STATUS_CMD_ST              ,
        READ_STATUS_DATA_ST             ,
        READ_STATUS_STUB_ST             ,
        READ_STATUS_CHK_ST              ,

        ERASE_WE_CMD_ST                 ,
        ERASE_WE_STUB_ST                ,
        ERASE_CMD_ST                    , -- Full erase
        ERASE_ADDR_ST                   ,
        ERASE_STUB_ST                   ,

        FINALIZE_ST                     ,
        NO_CMD_AVAIL_ST                 

    );

    signal  current_state           :       fsm                                 := RST_ST           ;

    signal  word_cnt                :       std_logic_Vector ( 31 downto 0 )    := (others => '0')  ;

    signal  dq_t_reg                :       std_Logic_Vector (  3 downto 0 )    := (others => '0')  ;
    signal  dq_o_reg                :       std_Logic_Vector (  3 downto 0 )    := (others => '0')  ;

    signal  s_reg                   :       std_Logic                           := '0'              ;

    signal  reset_out_reg           :       std_logic                           := '0'              ;

    signal  nv_reg_value            :       std_Logic_vector ( 15 downto 0 )    := (others => '1')  ; 

    signal  shift_data_reg          :       std_logic_vector ( 39 downto 0 )    := (others => '0')  ; -- cmd & address 

    signal  size_reg                :       std_Logic_Vector ( 31 downto 0 )    := (others => '0')  ; -- for control how many data readed or writed

    signal  allow_fifo_write        :       std_logic                           := '0'              ; -- allow out_wren signal for data from flash to user 
    signal  allow_status_write      :       std_Logic                           := '0'              ;

    signal  flash_status_reg        :       std_Logic_vector (  7 downto 0 )    := (others => '0')  ;
    signal  flash_status_valid_reg  :       std_logic := '0'                                        ;
    
    signal  spi_reset               :       std_logic                                               ;

    component rst_syncer
        generic(
            INIT_VALUE              :           bit             := '1'                                  
        );
        port(
            CLK                     :   in      std_logic                                           ;
            RESET                   :   in      std_logic                                           ;
            RESET_OUT               :   out     std_logic                                           
        );
    end component;

    signal  busy_reg                :           std_logic := '0'                          ;

    signal  s_axis_tready_sig       :           std_Logic                                   ;

begin

    S_AXIS_TREADY <= s_axis_tready_sig;
 
    DQ_T        <= dq_t_reg      ;
    DQ_O        <= dq_o_reg      ;
    S           <= s_reg         ;
    RESET_OUT   <= reset_out_reg ;
    BUSY        <= busy_reg      ;

    FLASH_STATUS <= flash_status_reg;
    FLASH_STATUS_VALID <= flash_status_valid_reg;

    rst_syncer_inst_spi_reset : rst_syncer
        generic map (
            INIT_VALUE  => '1'      
        )
        port map (
            CLK         =>  SPI_CLK         ,
            RESET       =>  S_AXIS_RESET    ,
            RESET_OUT   =>  spi_reset
        );

    reset_out_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if spi_reset = '1' then 
                reset_out_reg <= '0';
            else
                case current_state is
                    
                    when others => 
                        reset_out_reg <= '1';

                end case;
            end if;
        end if;
    end process;

    STARTUPE_MODE_GEN : if MODE = "STARTUPE" generate

        bufgce_inst : BUFGCE
            generic map (
                CE_TYPE         => "SYNC",     -- ASYNC, HARDSYNC, SYNC
                IS_CE_INVERTED  => '0', -- Programmable inversion on CE
                IS_I_INVERTED   => '1'   -- Programmable inversion on I
            )
            port map (
                O               =>  C,   -- 1-bit output: Buffer
                CE              =>  '1', -- 1-bit input: Buffer enable
                I               =>  SPI_CLK    -- 1-bit input: Buffer
            );

    end generate;

    DIRECT_MODE_GEN : if MODE = "DIRECT" generate
        
        oddre1_inst : ODDRE1
            generic map (
                IS_C_INVERTED   => '0'              , -- Optional inversion for C
                IS_D1_INVERTED  => '0'              , -- Unsupported, do not use
                IS_D2_INVERTED  => '0'              , -- Unsupported, do not use
                SIM_DEVICE      => "ULTRASCALE"     , -- Set the device version (ULTRASCALE)
                SRVAL           => '0'                -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
            )
            port map (
                Q               =>  C               , -- 1-bit output: Data output to IOB
                C               =>  SPI_CLK         , -- 1-bit input: High-speed clock input
                D1              =>  '0'             ,
                D2              =>  '1'             ,
                SR              =>  '0'               -- 1-bit input: Active High Async Reset
            );

    end generate;


    SYNC_TRUE_GEN : if ASYNC = false generate

        fifo_cmd_sync_xpm_inst : fifo_cmd_sync_xpm
            generic map (
                DATA_WIDTH      =>  72                                                  ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  16                                                   
            )
            port map (
                CLK             =>  SPI_CLK                                             ,
                RESET           =>  spi_reset                                           ,
                DIN             =>  S_AXIS_CMD & S_AXIS_CMD_TADDR & S_AXIS_CMD_TSIZE    ,
                WREN            =>  S_AXIS_CMD_TVALID                                   ,
                FULL            =>  cmd_full                                            ,
                DOUT            =>  cmd_dout                                            ,
                RDEN            =>  cmd_rden                                            ,
                EMPTY           =>  cmd_empty                                            
            );

        fifo_out_sync_xpm_inst : fifo_out_sync_xpm
            generic map (
                DATA_WIDTH      =>  8                                                   ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  16                                                  
            )
            port map (
                CLK             =>  SPI_CLK                                             ,
                RESET           =>  spi_reset                                           ,
                
                OUT_DIN_DATA    =>  out_din_data                                        ,
                OUT_DIN_KEEP    =>  (others => '0')                                     ,
                OUT_DIN_LAST    =>  d_out_din_last                                      ,
                OUT_WREN        =>  d_out_wren                                          ,
                OUT_FULL        =>  out_full                                            ,
                OUT_AWFULL      =>  out_awfull                                          ,
                
                M_AXIS_TDATA    =>  M_AXIS_TDATA                                        ,
                M_AXIS_TKEEP    =>  open                                                ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID                                       ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST                                        ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY                                        
            );

        fifo_in_sync_xpm_inst : fifo_in_sync_xpm
            generic map (
                DATA_WIDTH      =>  8                                                   ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  256                                                  
            )
            port map (
                CLK             =>  SPI_CLK                                             ,
                RESET           =>  spi_reset                                           ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA                                        ,
                S_AXIS_TKEEP    =>  (others => '0')                                     ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                                        ,
                S_AXIS_TREADY   =>  s_axis_tready_sig                                   ,

                IN_DOUT_DATA    =>  in_dout_data                                        ,
                IN_DOUT_KEEP    =>  open                                                ,
                IN_DOUT_LAST    =>  in_dout_last                                        ,
                IN_RDEN         =>  in_rden                                             ,
                IN_EMPTY        =>  in_empty                                             
            );

    end generate;


    ASYNC_TRUE_GEN : if ASYNC = true generate

        fifo_cmd_async_xpm_inst : fifo_cmd_async_xpm
            generic map (
                DATA_WIDTH      =>  72                                                  ,
                CDC_SYNC        =>  4                                                   ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  16                                                   
            )
            port map (
                CLK_WR          =>  S_AXIS_CLK                                          ,
                RESET_WR        =>  S_AXIS_RESET                                        ,
                CLK_RD          =>  SPI_CLK                                             ,
                DIN             =>  S_AXIS_CMD & S_AXIS_CMD_TADDR & S_AXIS_CMD_TSIZE    ,
                WREN            =>  S_AXIS_CMD_TVALID                                   ,
                FULL            =>  cmd_full                                            ,
                DOUT            =>  cmd_dout                                            ,
                RDEN            =>  cmd_rden                                            ,
                EMPTY           =>  cmd_empty                                            
            );

        fifo_in_async_xpm_inst : fifo_in_async_xpm
            generic map (
                DATA_WIDTH      =>  8                                                   ,
                CDC_SYNC        =>  5                                                   ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  256                                                 
            )
            port map (
                S_AXIS_CLK      =>  S_AXIS_CLK                                          ,
                S_AXIS_RESET    =>  S_AXIS_RESET                                        ,
                M_AXIS_CLK      =>  SPI_CLK                                             ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA                                        ,
                S_AXIS_TKEEP    =>  (others => '1')                                     ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                                        ,
                S_AXIS_TREADY   =>  s_axis_tready_sig                                   ,

                IN_DOUT_DATA    =>  in_dout_data                                        ,
                IN_DOUT_KEEP    =>  open                                                ,
                IN_DOUT_LAST    =>  in_dout_last                                        ,
                IN_RDEN         =>  in_rden                                             ,
                IN_EMPTY        =>  in_empty                                             
            );

        fifo_out_async_xpm_inst : fifo_out_async_xpm
            generic map (
                DATA_WIDTH      =>  8                                                   ,
                CDC_SYNC        =>  5                                                   ,
                MEMTYPE         =>  "distributed"                                       ,
                DEPTH           =>  256                                                 
            )
            port map (
                CLK             =>  SPI_CLK                                             ,
                RESET           =>  spi_reset                                           ,
                OUT_DIN_DATA    =>  out_din_data                                        ,
                OUT_DIN_KEEP    =>  (others => '0')                                     ,
                OUT_DIN_LAST    =>  d_out_din_last                                      ,
                OUT_WREN        =>  d_out_wren                                          ,
                OUT_FULL        =>  out_full                                            ,
                OUT_AWFULL      =>  out_awfull                                          ,

                M_AXIS_CLK      =>  S_AXIS_CLK                                             ,
                M_AXIS_TDATA    =>  M_AXIS_TDATA                                        ,
                M_AXIS_TKEEP    =>  open                                                ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID                                       ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST                                        ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY                                        

            );

    end generate;


    cmd_rden_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is

                when IDLE_ST => 
                    --if cmd_empty = '0' then 
                    --    cmd_rden <= '1';
                    --else
                    --    cmd_rden <= '0';
                    --end if;
                        if cmd_empty = '0' then 
                            case cmd is 

                                when x"0B" | x"6B" | x"EB" | x"0C" | x"6c" | x"EC" => 
                                    if out_awfull = '0' then 
                                        cmd_rden <= '1';
                                    else
                                        cmd_rden <= '0';
                                    end if;

                                when x"3E" | x"12" | x"34" | x"02" | x"32" | x"38" => 
                                    if in_empty = '0' then -- input fifo for data isn't empty
                                        cmd_rden <= '1';
                                    else
                                        cmd_rden <= '0';
                                    end if;

                                when x"C4" | x"DC" | x"21" | x"5c" => 
                                    cmd_rden <= '1';

                                when others => 
                                    cmd_rden <= '1';

                            end case;

                        else
                            cmd_rden <= '0';
                        end if;


                when others => 
                    cmd_rden <= '0';

            end case;
        end if;
    end process;

    busy_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is
                when IDLE_ST => 
                    busy_reg <= '0';

                when others => 
                    busy_reg <= '1';

            end case;
        end if;
    end process;

    S_AXIS_CMD_TREADY <= not cmd_full;

    cmd_size <= cmd_dout( 31 downto  0 );
    cmd_addr <= cmd_dout( 63 downto 32 );
    cmd      <= cmd_dout( 71 downto 64 );

    size_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is
                when IDLE_ST => 
                    size_reg <= (cmd_size( 30 downto 0 ) & '0') - 1;

                when others => 
                    size_reg <= size_reg;
            end case;
        end if;
    end process;

    shift_data_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is

                -- READ, ERASE, PROGRAM operations required cmd & address for accessing to flash 
                when IDLE_ST => 
                    if cmd_empty = '0' then 
                        shift_data_reg <= cmd & cmd_addr;
                    else
                        shift_data_reg <= shift_data_reg;                        
                    end if;

                when PROGRAM_WE_CMD_ST | PROGRAM_WE_STUB_ST | ERASE_WE_CMD_ST | ERASE_WE_STUB_ST => 
                    shift_data_reg <= shift_data_reg;

                when PROGRAM_ADDR_ST => 
                    if word_cnt < 7 then 
                        shift_data_reg <= shift_data_reg(shift_data_reg'length-5 downto 0 ) & "0000";
                    else
                        shift_data_reg(shift_data_reg'length-1 downto shift_data_reg'length-8) <= in_dout_data;
                    end if;

                when PROGRAM_DATA_ST => 
                    if in_rden = '1' then 
                        shift_data_reg(shift_data_reg'length-1 downto shift_data_reg'length-8) <= in_dout_data;
                    else
                        shift_data_reg <= shift_data_reg(shift_data_reg'length-5 downto 0 ) & "0000";
                    end if;

                when others => 
                    shift_data_reg <= shift_data_reg(shift_data_reg'length-5 downto 0) & "0000";

            end case;
        end if;
    end process;

    current_state_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if spi_reset = '1' then 
                current_state <= RST_ST;
            else
                case current_state is
                    when RST_ST => 
                        if word_cnt < 1000 then 
                            current_state <= current_state;
                        else
                            current_state <= V_CFG_REG_WE_CMD_ST;
                        end if;

                    when IDLE_ST => 
                        if cmd_empty = '0' then 
                            case cmd is 

                                when x"0B" | x"6B" | x"EB" | x"0C" | x"6c" | x"EC" => 
                                    if out_awfull = '0' then 
                                        current_state <= READ_CMD_ST;
                                    else
                                        current_state <= current_state;    
                                    end if;

                                when x"3E" | x"12" | x"34" | x"02" | x"32" | x"38" => 
                                    if in_empty = '0' then -- input fifo for data isn't empty
                                        current_state <= PROGRAM_WE_CMD_ST;
                                    else
                                        current_state <= current_state;
                                    end if;

                                when x"C4" | x"DC" | x"21" | x"5c" => 
                                    current_state <= ERASE_WE_CMD_ST;

                                when others => 
                                    current_state <= NO_CMD_AVAIL_ST;

                            end case;
                        else
                            current_state <= current_state;                            
                        end if;

                    when NO_CMD_AVAIL_ST => 
                        current_state <= IDLE_ST;

                    when V_CFG_REG_WE_CMD_ST => 
                        if word_cnt < 7 then
                            current_state <= current_state;
                        else
                            current_state <= V_CFG_REG_WE_STUB_ST; 
                        end if;

                    when V_CFG_REG_WE_STUB_ST => 
                        current_state <= V_CFG_REG_CMD_ST;

                    when V_CFG_REG_CMD_ST => 
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            current_state <= V_CFG_REG_DATA_ST;
                        end if;

                    when V_CFG_REG_DATA_ST => 
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            current_state <= ENABLE_FOUR_BYTE_PREPARE_ST;
                        end if;

                    when ENABLE_FOUR_BYTE_PREPARE_ST => 
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            current_state <= ENABLE_FOUR_BYTE_CMD_ST;
                        end if;

                    when ENABLE_FOUR_BYTE_CMD_ST => 
                        if word_cnt < 1 then
                            current_state <= current_state;
                        else
                            current_state <= FINALIZE_ST;
                        end if; 



                    when READ_ID_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_ID_DATA_ST;
                        end if;

                    when READ_ID_DATA_ST => 
                        if word_cnt < 39 then 
                            current_state <= current_state;
                        else
                            current_state <= FINALIZE_ST;
                        end if;

                    when READ_CMD_ST     =>
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_ADDRESS_ST;
                        end if;

                    when READ_ADDRESS_ST =>
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_DUMMY_ST;
                        end if;

                    when READ_DUMMY_ST   =>
                        if word_cnt < 9 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_DATA_ST;
                        end if;

                    when READ_DATA_ST =>
                        if out_awfull = '0' then 
                            if word_cnt < size_reg then 
                                current_state <= current_state;
                            else
                                current_state <= FINALIZE_ST;
                            end if;
                        else
                            current_state <= READ_DATA_WAIT_ABILITY_ST;                            
                        end if;

                    when READ_DATA_WAIT_ABILITY_ST =>
                        if out_awfull = '0' then 
                            current_state <= READ_CMD_ST;
                        else
                            current_state <= current_state;
                        end if; 

                    when PROGRAM_WE_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= PROGRAM_WE_STUB_ST;
                        end if;

                    when PROGRAM_WE_STUB_ST => 
                        if in_empty = '0' then 
                            current_state <= PROGRAM_CMD_ST;
                        else
                            current_state <= current_state;    
                        end if;

                    when PROGRAM_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= PROGRAM_ADDR_ST;
                        end if;

                    when PROGRAM_ADDR_ST => 
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            current_state <= PROGRAM_DATA_ST;
                        end if;

                    when PROGRAM_DATA_ST => 
                        if word_cnt < size_reg then 
                            current_state <= current_state;
                        else
                            current_state <= PROGRAM_DATA_STUB_ST;
                        end if;

                    when PROGRAM_DATA_STUB_ST => 
                        current_state <= READ_STATUS_CMD_ST;

                    when READ_STATUS_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_STATUS_DATA_ST;
                        end if;

                    when READ_STATUS_DATA_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= READ_STATUS_STUB_ST;
                        end if;

                    when READ_STATUS_STUB_ST =>
                        current_state <= READ_STATUS_CHK_ST;

                    when READ_STATUS_CHK_ST =>
                        if flash_status_reg(7) = '0' then 
                            current_state <= READ_STATUS_CMD_ST;
                        else
                            current_state <= FINALIZE_ST;
                        end if;

                    when ERASE_WE_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= ERASE_WE_STUB_ST;
                        end if;

                    when ERASE_WE_STUB_ST => 
                        current_state <= ERASE_CMD_ST;

                    when ERASE_CMD_ST => 
                        if word_cnt < 1 then 
                            current_state <= current_state;
                        else
                            current_state <= ERASE_ADDR_ST;
                        end if;

                    when ERASE_ADDR_ST => 
                        if word_cnt < 7 then 
                            current_state <= current_state;
                        else
                            --current_state <= FINALIZE_ST; -- change to read status for analyze busy
                            --current_state <= READ_STATUS_CMD_ST;
                            current_state <= ERASE_STUB_ST;
                        end if;

                    when ERASE_STUB_ST => 
                        current_state <= READ_STATUS_CMD_ST;

                    when FINALIZE_ST => 
                        current_state <= IDLE_ST;

                    when others => 
                        current_state <= IDLE_ST;
                end case;
            end if;
        end if;
    end process;


    word_cnt_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 

            if spi_reset = '1' then 
                word_cnt <= (others => '0');
            else

                case current_state is
                    when RST_ST => 
                        if word_cnt < 1000 then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when IDLE_ST =>
                        word_cnt <= (others => '0');
                    


                    when READ_ID_CMD_ST | 
                    READ_CMD_ST         |
                    PROGRAM_WE_CMD_ST   | 
                    PROGRAM_CMD_ST      | 
                    READ_STATUS_CMD_ST  | 
                    ERASE_WE_CMD_ST     | 
                    ERASE_CMD_ST        |
                    READ_STATUS_DATA_ST |
                    ENABLE_FOUR_BYTE_CMD_ST  => 
                        if word_cnt < 1 then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when READ_ID_DATA_ST => 
                        if word_cnt < 39 then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when READ_DUMMY_ST => 
                        if word_cnt < 9 then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when READ_DATA_ST | PROGRAM_DATA_ST=>
                        if word_cnt < size_reg then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when READ_DATA_WAIT_ABILITY_ST => 
                        word_cnt <= word_cnt;


                    when ERASE_ADDR_ST  | 
                        PROGRAM_ADDR_ST     | 
                        READ_ADDRESS_ST     | 
                        V_CFG_REG_WE_CMD_ST | 
                        V_CFG_REG_CMD_ST    | 
                        V_CFG_REG_DATA_ST   | 
                        ENABLE_FOUR_BYTE_PREPARE_ST => 
                        if word_cnt < 7 then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= (others => '0');
                        end if;

                    when others => 
                        word_cnt <= (others => '0');
                end case;
            end if;
        end if;
    end process;
    -- 0000 - outputs
    -- 1111 - inputs for reading data
    dq_t_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if spi_reset = '1' then 
                dq_t_reg <= "1110";
            else
                case current_state is

                    when RST_ST => 
                        dq_t_reg <= "1110";

                    when IDLE_ST | FINALIZE_ST =>
                        dq_t_reg <= "0000";

                    when READ_ID_DATA_ST | READ_DATA_ST | READ_STATUS_DATA_ST => 
                        dq_t_reg <= "1111";

                    when V_CFG_REG_WE_CMD_ST | V_CFG_REG_WE_STUB_ST | V_CFG_REG_CMD_ST | V_CFG_REG_DATA_ST => 
                        dq_t_reg <= "1110";

                    when others => 
                        dq_t_reg <= "0000";

                end case;
            end if;
        end if;
    end process;
    
    GEN_NO_SWAP_DQ_O : if SWAP_NIBBLE = false generate

        dq_o_reg_processing : process(SPI_CLK)
        begin
            if SPI_CLK'event AND SPI_CLK = '1' then 
                if spi_reset = '1' then 
                    dq_o_reg <= (others => '1');
                else
                    case current_state is
                        
                        when RST_ST => 
                            dq_o_reg <= (others => '1');

                        when IDLE_ST =>    
                            dq_o_reg <= (others => '1');

                        when PROGRAM_DATA_ST => 
                            if in_rden = '0' then 
                                dq_o_reg <= in_dout_data(7 downto 4) ;
                            else
                                dq_o_reg <= in_dout_data(3 downto 0) ;
                            end if;

                        when PROGRAM_WE_CMD_ST | ERASE_WE_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"0";
                                when others => dq_o_reg <= x"6";
                            end case;

                        when READ_STATUS_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"7";
                                when others => dq_o_reg <= x"0";
                            end case;

                        when ENABLE_FOUR_BYTE_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"B";
                                when others => dq_o_reg <= x"7";
                            end case;


                        when V_CFG_REG_WE_CMD_ST => 
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 1 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 2 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 3 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 4 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 5 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 6 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 7 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when others => dq_o_reg <= dq_o_reg;
                            end case;


                        when V_CFG_REG_CMD_ST =>    
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 1 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 2 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 3 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 4 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 5 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 6 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 7 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when others => dq_o_reg <= dq_o_reg;
                            end case;

                        when V_CFG_REG_DATA_ST =>    
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000"; -- 7 
                                when 1 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000"; -- 6
                                when 2 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 5
                                when 3 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 4
                                when 4 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 3
                                when 5 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 2
                                when 6 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 1
                                when 7 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 0
                                when others => dq_o_reg <= dq_o_reg;
                            end case;

                        when others => dq_o_reg <= shift_data_reg(shift_data_reg'length-1 downto shift_data_reg'length-4);
                    
                    end case;
                end if;
            end if;
        end process;

    end generate;



    GEN_SWAP_DQ_O : if SWAP_NIBBLE = true generate
    
        dq_o_reg_processing : process(SPI_CLK)
        begin
            if SPI_CLK'event AND SPI_CLK = '1' then 
                if spi_reset = '1' then 
                    dq_o_reg <= (others => '1');
                else
                    case current_state is
                        
                        when RST_ST => 
                            dq_o_reg <= (others => '1');

                        when IDLE_ST =>    
                            dq_o_reg <= (others => '1');

                        when PROGRAM_DATA_ST => 
                            if in_rden = '0' then 
                                dq_o_reg <= in_dout_data(3 downto 0) ;
                            else
                                dq_o_reg <= in_dout_data(7 downto 4) ;
                            end if;

                        when PROGRAM_WE_CMD_ST | ERASE_WE_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"0";
                                when others => dq_o_reg <= x"6";
                            end case;

                        when READ_STATUS_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"7";
                                when others => dq_o_reg <= x"0";
                            end case;

                        when ENABLE_FOUR_BYTE_CMD_ST => 
                            case conv_integer(word_cnt) is
                                when 0      => dq_o_reg <= x"B";
                                when others => dq_o_reg <= x"7";
                            end case;


                        when V_CFG_REG_WE_CMD_ST => 
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 1 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 2 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 3 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 4 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 5 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 6 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 7 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when others => dq_o_reg <= dq_o_reg;
                            end case;


                        when V_CFG_REG_CMD_ST =>    
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 1 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 2 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when 3 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 4 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 5 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 6 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000";
                                when 7 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000";
                                when others => dq_o_reg <= dq_o_reg;
                            end case;

                        when V_CFG_REG_DATA_ST =>    
                            case conv_integer(word_cnt) is 
                                when 0 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000"; -- 7 
                                when 1 => dq_o_reg(0) <= '0'; dq_o_reg(3 downto 1) <= "000"; -- 6
                                when 2 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 5
                                when 3 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 4
                                when 4 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 3
                                when 5 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 2
                                when 6 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 1
                                when 7 => dq_o_reg(0) <= '1'; dq_o_reg(3 downto 1) <= "000"; -- 0
                                when others => dq_o_reg <= dq_o_reg;
                            end case;

                        when others => dq_o_reg <= shift_data_reg(shift_data_reg'length-1 downto shift_data_reg'length-4);
                    
                    end case;
                end if;
            end if;
        end process;

    end generate;


    s_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if spi_reset = '1' then 
                s_reg <= '1';
            else
                case current_state is


                    when READ_ID_CMD_ST | 
                    READ_ID_DATA_ST     | 
                    READ_CMD_ST         | 
                    READ_ADDRESS_ST     | 
                    READ_DUMMY_ST       | 
                    READ_DATA_ST        | 
                    
                    PROGRAM_WE_CMD_ST   |
                    PROGRAM_CMD_ST      | 
                    PROGRAM_ADDR_ST     | 
                    PROGRAM_DATA_ST     | 

                    READ_STATUS_CMD_ST  | 
                    READ_STATUS_DATA_ST | 
                    
                    ERASE_WE_CMD_ST     | 
                    ERASE_CMD_ST        | 
                    ERASE_ADDR_ST       |
                    
                    V_CFG_REG_WE_CMD_ST | 
                    V_CFG_REG_CMD_ST    |
                    V_CFG_REG_DATA_ST   |

                    ENABLE_FOUR_BYTE_CMD_ST => 
                        s_reg <= '0';

                    when others => 
                        s_reg <= '1';

                end case;
            end if;
        end if;     
    end process;

    allow_fifo_write_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is
                when READ_DATA_ST => 
                    allow_fifo_write <= not allow_fifo_write;

                when others => 
                    allow_fifo_write <= '0';
            end case;
        end if;
    end process;

    in_rden_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is

                when PROGRAM_DATA_ST => 
                    in_rden <= not in_rden;

                when others =>  
                    in_rden <= '0';

            end case;
        end if;
    end process;

    GEN_NO_SWAP_OUT_DIN_DATA : if SWAP_NIBBLE = false generate
        out_din_data_processing : process(SPI_CLK)
        begin   
            if SPI_CLK'event AND SPI_CLK = '1' then 
                out_din_data <= out_din_data( 3 downto 0 ) & DQ_I;
            end if;
        end process;
    end generate;

    GEN_SWAP_OUT_DIN_DATA : if SWAP_NIBBLE = true generate
        out_din_data_processing : process(SPI_CLK)
        begin   
            if SPI_CLK'event AND SPI_CLK = '1' then 
                out_din_data <= DQ_I & out_din_data( 7 downto 4 );
            end if;
        end process;
    end generate;

    d_out_din_last_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then
            d_out_din_last <= out_din_last; 
        end if;
    end process;

    d_out_wren_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event anD SPI_CLK = '1' then 
            d_out_wren <= out_wren;
        end if;
    end process;

    out_din_last_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if word_cnt = size_reg then 
                out_din_last <= '1';    
            else
                out_din_last <= '0';
            end if;
        end if;
    end process;

    out_wren_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            if allow_fifo_write = '1' then 
                out_wren <= '1';
            else
                out_wren <= '0';
            end if;
        end if;
    end process;

    allow_status_write_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is
                when READ_STATUS_DATA_ST => 
                    allow_status_write <= '1';

                when others => 
                    allow_status_write <= '0';
            end case;            
        end if;
    end process;

    flash_status_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then
            if allow_status_write = '1' then 
                flash_status_reg <= flash_status_reg(3 downto 0) & DQ_I;
            else
                flash_status_reg <= flash_status_reg;
            end if;
        end if;
    end process;

    flash_status_valid_reg_processing : process(SPI_CLK)
    begin
        if SPI_CLK'event AND SPI_CLK = '1' then 
            case current_state is
                when READ_STATUS_STUB_ST =>
                    flash_status_valid_reg <= '1';

                when others => 
                    flash_status_valid_reg <= '0';

            end case;   
        end if;
    end process;

end axis_micron_nor_ctrlr_x4_arch;

