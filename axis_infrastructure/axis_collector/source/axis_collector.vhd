library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

library UNISIM;
    use UNISIM.VComponents.all;


entity axis_collector is
    generic(
        N_CHANNELS              :           integer                          := 32              ; -- Number of channels which do segmentation of RAM 
        N_CHANNELS_W            :           integer                          := 5               ; -- Channel width ( must be > log2(N_CHANNELS))
        TUSER_WIDTH             :           integer                          := 6               ;
        SEGMENT_BYTE_SIZE       :           integer                          := 2048            ; -- Size of each segment for holding data from each received channel
        N_BYTES_IN              :           integer                          := 4               ; -- Input width in bytes
        N_BYTES_OUT             :           integer                          := 32              ; -- output width in bytes, can be assymetric
        ASYNC_MODE              :           boolean                          := true            ; -- use asyncronous mode
        SEGMENT_MAX_PKTS        :           integer                          := 2               ; -- Number of packets in each segment. 
        ADDR_USE                :           string                           := "full"            -- Address part using "full" or "high" 

    );
    port(
        S_AXIS_CLK              :   in      std_logic                                           ;
        S_AXIS_RESET            :   in      std_logic                                           ;
        S_AXIS_TDATA            :   in      std_logic_vector ( (N_BYTES_IN*8)-1 downto 0 )      ;
        S_AXIS_TVALID           :   in      std_logic                                           ;
        S_AXIS_TID              :   in      std_logic_Vector ( N_CHANNELS_W-1 downto 0 )        ;
        S_AXIS_TUSER            :   in      std_logic_vector ( TUSER_WIDTH-1 downto 0 )         ;
        M_AXIS_CLK              :   in      std_logic                                           ;
        M_AXIS_RESET            :   in      std_logic                                           ;
        M_AXIS_TDATA            :   out     std_logic_vector ( (N_BYTES_OUT*8)-1 downto 0 )     ;
        M_AXIS_TID              :   out     std_logic_Vector ( N_CHANNELS_W-1 downto 0 )        ;
        M_AXIS_TVALID           :   out     std_logic                                           ;
        M_AXIS_TREADY           :   in      std_logic                           
    );
end axis_collector;



architecture axis_collector_arch of axis_collector is

    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_INFO of S_AXIS_RESET: SIGNAL is "xilinx.com:signal:reset:1.0 S_AXIS_RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER of S_AXIS_RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    ATTRIBUTE X_INTERFACE_INFO of M_AXIS_RESET: SIGNAL is "xilinx.com:signal:reset:1.0 M_AXIS_RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER of M_AXIS_RESET: SIGNAL is "POLARITY ACTIVE_HIGH";


    constant VERSION            :           string  := "1.2";

    constant WORDA_WIDTH        :           integer :=  N_BYTES_IN*8;
    constant WORDB_WIDTH        :           integer :=  N_BYTES_OUT*8;
    constant ADDRA_WIDTH        :           integer :=  integer(ceil(log2(real((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_IN))));
    constant ADDRB_WIDTH        :           integer :=  integer(ceil(log2(real((SEGMENT_BYTE_SIZE*N_CHANNELS)/N_BYTES_OUT))));

    constant SEG_CNT_WIDTH      :           integer := integer(ceil(log2(real(SEGMENT_BYTE_SIZE/N_BYTES_IN))))     ;
    constant SEG_PART_LIMIT     :           integer := SEG_CNT_WIDTH - integer(ceil(log2(real(SEGMENT_MAX_PKTS))))     ;
    constant DIFF_CNT_PART      :           integer := SEG_CNT_WIDTH - SEG_PART_LIMIT;
    constant ALL_ONES           :           std_logic_Vector ( SEG_PART_LIMIT-1 downto 0 ) := (others => '1');
    constant CNTA_PART          :           integer := ADDRA_WIDTH - (S_AXIS_TID'length + S_AXIS_TUSER'length);

    constant HI_ADDRA           :           integer := ADDRA_WIDTH - SEG_PART_LIMIT; -- transmitted to fifo high part of address, which must be readed in read part logic

    constant BYTES_PER_PKT      :           integer := SEGMENT_BYTE_SIZE/SEGMENT_MAX_PKTS               ; --1024
    constant CNTB_LIMIT         :           integer := BYTES_PER_PKT/N_BYTES_OUT                        ;
    constant CNTB_WIDTH         :           integer := integer(ceil(log2(real(CNTB_LIMIT))))            ;
    constant CNTB_LIMIT_VECTOR  :           std_logic_VectoR ( CNTB_WIDTH-1 downto 0 ) := (others => '1')      ;

    constant CMD_FIFO_WIDTH     :           integer := ADDRA_WIDTH-HI_ADDRA;

    constant FIFO_DEPTH         :           integer := (SEGMENT_MAX_PKTS * N_CHANNELS);


    component sdpram_xpm
        generic(
            WORDA_WIDTH     :           integer                 := 32                   ; -- word width in bits
            WORDB_WIDTH     :           integer                 := 256                  ;
            SIZE_IN_BYTES   :           integer                 := 2048                 ; -- Size in bytes for one channel
            N_CHANNELS      :           integer                 := 32                   ; 
            ASYNC           :           boolean                 := true                 ;
            ADDRA_WIDTH     :           integer                 := 14                   ;
            ADDRB_WIDTH     :           integer                 := 11                   ;
            MEMTYPE         :           string                  := "distributed" -- block ultra
        );
        port(
            CLKA            :   in      std_logic                                       ;
            CLKB            :   in      std_logic                                       ;
            RESETB          :   in      std_logic                                       ;
            ADDRA           :   in      std_logic_Vector ( ADDRA_WIDTH-1 downto 0 )     ;
            DINA            :   in      std_logic_Vector ( WORDA_WIDTH-1 downto 0 )     ;
            WEA             :   in      std_logic                                       ;
            ADDRB           :   in      std_logic_Vector ( ADDRB_WIDTH-1 downto 0 )     ;
            DOUTB           :   out     std_logic_vector ( WORDB_WIDTH-1 downto 0 )     
        );
    end component;

    signal  wea             :           std_logic                                   := '0'                 ;
    signal  addra           :           std_logic_vector ( ADDRA_WIDTH-1 downto 0 ) := (others => '0')     ;
    signal  dina            :           std_logic_vector ( WORDA_WIDTH-1 downto 0 ) := (others => '0')     ;
    signal  addrb           :           std_logic_vector ( ADDRB_WIDTH-1 downto 0 ) := (others => '0')     ;
    signal  doutb           :           std_logic_vector ( WORDB_WIDTH-1 downto 0 )                        ;

    signal  addra_vector    :           std_logic_Vector ( (N_CHANNELS * SEG_CNT_WIDTH)-1 downto 0 ) := (others => '0')       ;
    signal  event_compl_vector       :           std_logic_Vector ( N_CHANNELS-1 downto 0 )  := (others => '0')     ;

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


    signal  fifo_cmd_din    :           std_logic_vector ( HI_ADDRA-1 downto 0 ) := (others => '0')    ;
    signal  fifo_cmd_wren   :           std_logic                         := '0'                ;
    signal  fifo_cmd_rden   :           std_logic                         := '0'                ;
    signal  fifo_cmd_dout   :           std_logic_vector ( HI_ADDRA-1 downto 0 )                       ;
    signal  fifo_cmd_full   :           std_logic                                               ;
    signal  fifo_cmd_empty  :           std_logic                                               ;

    type fsm is (
        IDLE_ST     ,
        TX_OUT_ST   ,
        WAIT_ST      
    );

    signal  current_state : fsm := IDLE_ST;

    signal  cntb                :           std_logic_Vector ( CNTB_WIDTH-1 downto 0 ) := (others => '0')    ;



    component fifo_out_sync_xpm_id
        generic(
            DATA_WIDTH          :           integer         :=  16                          ;
            MEMTYPE             :           String          :=  "block"                     ;
            DEPTH               :           integer         :=  16                          ;
            ID_WIDTH            :           integer         :=  5                           ;
            PROG_FULL_THRESH    :           integer         :=  10                           
        );
        port(
            CLK                 :   in      std_logic                                       ;
            RESET               :   in      std_logic                                       ;
            
            OUT_DIN_DATA        :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP        :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_ID          :   in      std_logic_Vector ( ID_WIDTH-1 downto 0 )        ;
            OUT_DIN_LAST        :   in      std_logic                                       ;
            OUT_PROG_FULL       :   out     std_logic                                       ;
            OUT_WREN            :   in      std_logic                                       ;
            OUT_FULL            :   out     std_logic                                       ;
            OUT_AWFULL          :   out     std_logic                                       ;
            
            M_AXIS_TDATA        :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP        :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TID          :   out     std_logic_Vector ( ID_WIDTH-1 downto 0 )        ;
            M_AXIS_TVALID       :   out     std_logic                                       ;
            M_AXIS_TLAST        :   out     std_logic                                       ;
            M_AXIS_TREADY       :   in      std_logic                                        

        );
    end component;


    signal  out_din_data        :           std_logic_Vector ( WORDB_WIDTH-1 downto 0 )      := (others => '0');
    signal  out_din_keep        :           std_logic_Vector ( ( WORDB_WIDTH/8)-1 downto 0 ) := (others => '1');
    signal  out_din_id          :           std_logic_Vector ( N_CHANNELS_W-1 downto 0 )     := (others => '0');
    signal  out_din_last        :           std_logic                                        := '0'  ;
    signal  out_prog_full       :           std_logic                                       ;
    signal  out_wren            :           std_logic                                       ;
    signal  out_full            :           std_logic                                       ;
    signal  out_awfull          :           std_logic                                       ;

    signal  out_din_id_vector           :           std_logic_Vector ( (N_CHANNELS_W*3)-1 downto 0 ) := (others => '0') ;
    signal  valid_data_vector         :             std_logic_Vector ( 3 downto 0 ) := (others => '0');
    --signal  last_vector : std_logic_Vector ( 3 downto 0 ) := (others => '0')    ;



begin



    ADDRA_VECTOR_GENERATE : for i in 0 to N_CHANNELS-1 generate
        addra_vector_processing : process(S_AXIS_CLK)
        begin
            if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
                if S_AXIS_TVALID = '1' and S_AXIS_TID = conv_std_logic_Vector (i, S_AXIS_TID'length) then 
                    addra_vector( (((i+1)*SEG_CNT_WIDTH)-1) downto (i*seg_cnt_width)) <= addra_vector( (((i+1)*SEG_CNT_WIDTH)-1) downto (i*seg_cnt_width)) + 1;
                end if;
            end if;
        end process;
    end generate ADDRA_VECTOR_GENERATE;

    EVENT_COMPL_GENERATE : for i in 0 to N_CHANNELS-1 generate
        event_compl_vector_processing : process(S_AXIS_CLK)
        begin
            if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
                if S_AXIS_TVALID = '1' and S_AXIS_TID = conv_std_logic_Vector(i, S_AXIS_TID'length) then 
                    if addra_vector( ((((i+1)*SEG_CNT_WIDTH)-1)-DIFF_CNT_PART) downto (i*seg_cnt_width)) = ALL_ONES then 
                        event_compl_vector(i) <= '1';    
                    else
                        event_compl_vector(i) <= '0';    
                    end if;
                else
                    event_compl_vector(i) <= '0';    
                end if;
            end if;
        end process;
    end generate EVENT_COMPL_GENERATE;

    wea_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_RESET = '1' then 
                wea <= '0';
            else
                if S_AXIS_TVALID = '1' then 
                    wea <= '1';
                else
                    wea <= '0';
                end if;
            end if;
        end if;
    end process;

    GEN_HIGH_ADDR_USE : if ADDR_USE = "high" generate

        addra_processing : process(S_AXIS_CLK)
        begin
            if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
                if S_AXIS_TVALID = '1' then 
                    addra <= S_AXIS_TID & addra_vector( ((((conv_integer (S_AXIS_TID))+1)*SEG_CNT_WIDTH)-1) downto ((conv_integer(S_AXIS_TID))*SEG_CNT_WIDTH) );
                else
                    addra <= addra;
                end if;
            end if;
        end process;

    end generate;


    GEN_FULL_ADDR_USE : if ADDR_USE = "full" generate

        addra_processing : process(S_AXIS_CLK)
        begin
            if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
                if S_AXIS_TVALID = '1' then 
                    addra <= S_AXIS_TID & addra_vector(  ((((conv_integer (S_AXIS_TID))+1)*SEG_CNT_WIDTH)-1) downto (((((conv_integer (S_AXIS_TID))+1)*SEG_CNT_WIDTH)-1)-(CNTA_PART-1) ) ) & S_AXIS_TUSER;
                else
                    addra <= addra;
                end if;
            end if;
        end process;

    end generate;


    dina_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_TVALID = '1' then 
                dina <= S_AXIS_TDATA;
            else
                dina <= dina;
            end if;
        end if;
    end process;

    sdpram_xpm_inst : sdpram_xpm
        generic map (
            WORDA_WIDTH     =>  WORDA_WIDTH                                             ,
            WORDB_WIDTH     =>  WORDB_WIDTH                                             ,
            SIZE_IN_BYTES   =>  SEGMENT_BYTE_SIZE                                       ,
            N_CHANNELS      =>  N_CHANNELS                                              ,
            ASYNC           =>  true                                                    ,
            ADDRA_WIDTH     =>  ADDRA_WIDTH                                             ,
            ADDRB_WIDTH     =>  ADDRB_WIDTH                                             ,
            MEMTYPE         =>  "block"                                            
        )
        port map (
            CLKA            =>  s_axis_clk                                              ,
            CLKB            =>  m_axis_clk                                              ,
            RESETB          =>  m_axis_reset                                            ,
            ADDRA           =>  addra                                                   ,
            DINA            =>  dina                                                    ,
            WEA             =>  wea                                                     ,
            ADDRB           =>  addrb                                                   ,
            DOUTB           =>  doutb                                                    
        );

    GEN_ASYNC : if ASYNC_MODE = true generate

        FIFO_MIN_DEPTH_EXTEND_GEN : if FIFO_DEPTH < 16 generate 

            fifo_cmd_async_xpm_inst : fifo_cmd_async_xpm 
                generic map (
                    DATA_WIDTH      =>  HI_ADDRA                                                ,
                    CDC_SYNC        =>  4                                                       ,
                    MEMTYPE         =>  "distributed"                                           ,
                    DEPTH           =>  16                                                       
                )
                port map (
                    CLK_WR          =>  S_AXIS_CLK                                              ,
                    RESET_WR        =>  S_AXIS_RESET                                            ,
                    CLK_RD          =>  M_AXIS_CLK                                              ,
                    DIN             =>  fifo_cmd_din                                            ,
                    WREN            =>  fifo_cmd_wren                                           ,
                    FULL            =>  fifo_cmd_full                                           ,
                    DOUT            =>  fifo_cmd_dout                                           ,
                    RDEN            =>  fifo_cmd_rden                                           ,
                    EMPTY           =>  fifo_cmd_empty                                           
                );

        end generate;


        FIFO_DEPTH_NORMAL : if FIFO_DEPTH >= 16 generate 

            fifo_cmd_async_xpm_inst : fifo_cmd_async_xpm 
                generic map (
                    DATA_WIDTH      =>  HI_ADDRA                                                ,
                    CDC_SYNC        =>  5                                                       ,
                    MEMTYPE         =>  "distributed"                                           ,
                    DEPTH           =>  FIFO_DEPTH                                               
                )
                port map (
                    CLK_WR          =>  S_AXIS_CLK                                              ,
                    RESET_WR        =>  S_AXIS_RESET                                            ,
                    CLK_RD          =>  M_AXIS_CLK                                              ,
                    DIN             =>  fifo_cmd_din                                            ,
                    WREN            =>  fifo_cmd_wren                                           ,
                    FULL            =>  fifo_cmd_full                                           ,
                    DOUT            =>  fifo_cmd_dout                                           ,
                    RDEN            =>  fifo_cmd_rden                                           ,
                    EMPTY           =>  fifo_cmd_empty                                           
                );

        end generate;



    end generate;


    GEN_SYNC : if ASYNC_MODE = false generate

        FIFO_MIN_DEPTH_EXTEND_GEN : if FIFO_DEPTH < 16 generate 

            fifo_cmd_sync_xpm_inst : fifo_cmd_sync_xpm
                generic map (
                    DATA_WIDTH      =>  HI_ADDRA                                                ,
                    MEMTYPE         =>  "distributed"                                           ,
                    DEPTH           =>  16                                              
                )
                port map (
                    CLK             =>  S_AXIS_CLK                                              ,
                    RESET           =>  S_AXIS_RESET                                            ,
                    DIN             =>  fifo_cmd_din                                            ,
                    WREN            =>  fifo_cmd_wren                                           ,
                    FULL            =>  fifo_cmd_full                                           ,
                    DOUT            =>  fifo_cmd_dout                                           ,
                    RDEN            =>  fifo_cmd_rden                                           ,
                    EMPTY           =>  fifo_cmd_empty                                           
                );

        end generate;

        FIFO_DEPTH_NORMAL : if FIFO_DEPTH >= 16 generate 

            fifo_cmd_sync_xpm_inst : fifo_cmd_sync_xpm
                generic map (
                    DATA_WIDTH      =>  HI_ADDRA                                                ,
                    MEMTYPE         =>  "distributed"                                           ,
                    DEPTH           =>  FIFO_DEPTH                                              
                )
                port map (
                    CLK             =>  S_AXIS_CLK                                              ,
                    RESET           =>  S_AXIS_RESET                                            ,
                    DIN             =>  fifo_cmd_din                                            ,
                    WREN            =>  fifo_cmd_wren                                           ,
                    FULL            =>  fifo_cmd_full                                           ,
                    DOUT            =>  fifo_cmd_dout                                           ,
                    RDEN            =>  fifo_cmd_rden                                           ,
                    EMPTY           =>  fifo_cmd_empty                                           
                );

        end generate;

    end generate;


    fifo_din_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            fifo_cmd_din <= addra( ADDRA_WIDTH-1 downto ADDRA_WIDTH-HI_ADDRA );
        end if;
    end process;

    fifo_cmd_wren_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_RESET = '1' then 
                fifo_cmd_wren <= '0';
            else
                if event_compl_vector = 0 then 
                    fifo_cmd_wren <= '0';
                else
                    fifo_cmd_wren <= '1';
                end if;
            end if;
        end if;
    end process;

    current_state_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if M_AXIS_RESET = '1' then 
                current_state <= IDLE_ST;
            else
                
                case current_state is
                    when IDLE_ST =>
                        if fifo_cmd_empty = '0' then 
                            current_state <= TX_OUT_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_OUT_ST =>
                        if out_prog_full = '0' then 
                            if cntb = CNTB_LIMIT_VECTOR then 
                                current_state <= WAIT_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else 
                            current_state <= current_state;
                        end if;

                    when WAIT_ST =>
                        current_state <= IDLE_ST;

                    when others => 
                        current_state <= current_state;
                end case;

            end if;
        end if;
    end process;

    fifo_cmd_rden_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if M_AXIS_RESET = '1' then 
                fifo_cmd_rden <= '0';
            else
                
                case current_state is
                    when TX_OUT_ST =>
                        if out_prog_full = '0' then 
                            if cntb = CNTB_LIMIT_VECTOR then 
                                fifo_cmd_rden <= '1';
                            else
                                fifo_cmd_rden <= '0';
                            end if;
                        else
                            fifo_cmd_rden <= '0';    
                        end if;
                    when others =>
                        fifo_cmd_rden <= '0';

                end case;
            end if;
        end if;
    end process;

    cntb_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if M_AXIS_RESET = '1' then 
                cntb <= (others => '0');
            else
                case current_state is
                    
                    when TX_OUT_ST =>
                        if out_prog_full = '0' then 
                            cntb <= cntb + 1;
                        else
                            cntb <= cntb;
                        end if;
                    
                    when others =>
                        cntb <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    addrb <= fifo_cmd_dout & cntb;

    fifo_out_sync_xpm_id_inst : fifo_out_sync_xpm_id
        generic map (
            DATA_WIDTH          =>  WORDB_WIDTH                                             ,
            MEMTYPE             =>  "distributed"                                           ,
            DEPTH               =>  16                                                      ,
            ID_WIDTH            =>  N_CHANNELS_W                                            ,
            PROG_FULL_THRESH    =>  10                                                       
        )
        port map  (
            CLK                 =>  M_AXIS_CLK                                              ,
            RESET               =>  M_AXIS_RESET                                            ,
            OUT_DIN_DATA        =>  out_din_data                                            ,
            OUT_DIN_KEEP        =>  out_din_keep                                            ,
            OUT_DIN_ID          =>  out_din_id                                              ,
            OUT_DIN_LAST        =>  out_din_last                                            ,
            OUT_PROG_FULL       =>  out_prog_full                                           ,
            OUT_WREN            =>  out_wren                                                ,
            OUT_FULL            =>  out_full                                                ,
            OUT_AWFULL          =>  out_awfull                                              ,
            M_AXIS_TDATA        =>  M_AXIS_TDATA                                            ,
            M_AXIS_TKEEP        =>  open                                                    ,
            M_AXIS_TID          =>  M_AXIS_TID                                              ,
            M_AXIS_TVALID       =>  M_AXIS_TVALID                                           ,
            M_AXIS_TLAST        =>  open                                                    ,
            M_AXIS_TREADY       =>  M_AXIS_TREADY                                            
        );

    out_din_keep                <= (others =>'1')       ;
    out_din_last                <= '0'                  ;
    out_din_id                  <= out_din_id_vector( ((N_CHANNELS_W*2)-1) downto N_CHANNELS_W ); -- второе слово. всегда. 
    out_din_data                <= doutb;
    

    out_din_id_vector_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            out_din_id_vector( ((N_CHANNELS_W*3)-1) downto N_CHANNELS_W ) <= out_din_id_vector ( ((N_CHANNELS_W*2)-1) downto 0 );
            out_din_id_vector( (N_CHANNELS_W-1) downto 0 ) <= addrb( (ADDRB_WIDTH-1) downto (ADDRB_WIDTH - N_CHANNELS_W) );
        end if;
    end process;


    out_wren <= valid_data_vector(2);


    valid_data_vector_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            valid_data_vector( 3 downto 1) <= valid_data_vector ( 2 downto 0 ); 

            case current_state is

                when TX_OUT_ST =>
                    if out_prog_full = '0' then 
                        valid_data_vector(0) <= '1';
                    else
                        valid_data_vector(0) <= '0';
                    end if;

                when others =>
                    valid_data_vector(0) <= '0';
            end case;

        end if;
    end process;


end axis_collector_arch;
