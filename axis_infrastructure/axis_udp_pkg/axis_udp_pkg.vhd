library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    USE IEEE.STD_LOGIC_ARITH.ALL;


library UNISIM;
    use UNISIM.VComponents.all;


entity axis_udp_pkg is
    generic(
        N_BYTES             :           integer                          := 32                  ;
        HEAD_PART           :           integer                          := 22                  ;
        HEAD_CNT_LIMIT      :           integer                          := 1                   ;
        ASYNC_MODE          :           boolean                          := false                 
    );
    port(
        SIZE                :   in      std_logic_Vector (  15 downto 0 )                       ;
        SRC_MAC             :   in      std_logic_vector (  47 downto 0 )                       ;
        SRC_IP              :   in      std_logic_vector (  31 downto 0 )                       ;
        SRC_PORT            :   in      std_logic_vector (  15 downto 0 )                       ;
        DST_MAC             :   in      std_logic_vector (  47 downto 0 )                       ;
        DST_IP              :   in      std_logic_vector (  31 downto 0 )                       ;
        DST_PORT            :   in      std_logic_vector (  15 downto 0 )                       ;
        CNT_US              :   in      std_logic_VectoR (  63 downto 0 )                       ;
        
        S_AXIS_CLK          :   in      std_logic                                               ;
        S_AXIS_RESET        :   in      std_logic                                               ;
        S_AXIS_TDATA        :   in      std_logic_Vector (  (N_BYTES*8)-1 downto 0 )            ;
        S_AXIS_TVALID       :   in      std_logic                                               ;
        S_AXIS_TREADY       :   out     std_logic                                               ;

        M_AXIS_CLK          :   in      std_logic                                               ;
        M_AXIS_TDATA        :   out     std_logic_Vector ( ((N_BYTES*8)-1) downto 0 )           ;
        M_AXIS_TKEEP        :   out     std_logic_Vector ( (N_BYTES-1) downto 0 )               ;
        M_AXIS_TVALID       :   out     std_logic                                               ;
        M_AXIS_TREADY       :   in      std_logic                                               ;
        M_AXIS_TLAST        :   out     std_logic                                               
    );
end axis_udp_pkg;




architecture axis_udp_pkg_arch of axis_udp_pkg is

    constant VERSION : string := "v1.0";

    signal  m_axis_reset                        :           std_logic   := '1'                                      ;

    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of S_AXIS_RESET: SIGNAL is "xilinx.com:signal:reset:1.0 S_AXIS_RESET RST";
    ATTRIBUTE X_INTERFACE_INFO of M_AXIS_RESET: SIGNAL is "xilinx.com:signal:reset:1.0 M_AXIS_RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of S_AXIS_RESET: SIGNAL is "POLARITY ACTIVE_HIGH";
    ATTRIBUTE X_INTERFACE_PARAMETER of M_AXIS_RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    

    component ipv4_chksum_calc_sync
        generic(
            SWAP_BYTES                  :           boolean                         := true         
        );
        port(
            CLK                         :   in      std_logic                           ;
            RESET                       :   in      std_logic                           ;
            IPV4_CALC_START             :   in      std_logic                           ;
            IPV4_IP_VER_LEN             :   in      std_logic_vector ( 15 downto 0 )    ;
            IPV4_IP_ID                  :   in      std_logic_Vector ( 15 downto 0 )    ;
            IPV4_TOTAL_SIZE             :   in      std_logic_vector ( 15 downto 0 )    ;
            IPV4_TTL                    :   in      std_logic_vector (  7 downto 0 )    ;
            IPV4_PROTO                  :   in      std_logic_vector (  7 downto 0 )    ;
            IPV4_SRC_ADDR               :   in      std_logic_vector ( 31 downto 0 )    ;
            IPV4_DST_ADDR               :   in      std_logic_vector ( 31 downto 0 )    ;
            IPV4_CHKSUM                 :   out     std_logic_vector ( 15 downto 0 )    ;
            IPV4_DONE                   :   out     std_logic                       

        );
    end component;

    signal  ipv4_calc_start             :           std_logic                        := '0'    ;
    signal  ipv4_chksum                 :           std_logic_vector ( 15 downto 0 )     ;
    signal  ipv4_done                   :           std_logic                            ;

    signal  head_cnt                    :           std_Logic_vector (  7 downto 0 )    := (others => '0')              ;

    constant    DATA_WIDTH              :           integer                         := N_BYTES * 8                                              ;
    constant    HEAD_WIDTH              :           integer                         := HEAD_PART * 8                                            ;
    constant    DELAYREG_WIDTH          :           integer                         := DATA_WIDTH-HEAD_WIDTH                                    ;
    constant    HEAD_CNT_LIMIT_LOGIC    :           std_logic_Vector ( 7 downto 0 ) := conv_std_logic_Vector( HEAD_CNT_LIMIT, head_cnt'length)  ;

    constant    C_ETH_TYPE              :           std_logic_vector ( 15 downto 0 ) := x"0800"                                                 ;
    constant    C_IPV4_IP_VER_LEN       :           std_logic_Vector ( 15 downto 0 ) := x"4500"                                                 ;
    constant    C_IPV4_ID               :           std_logic_Vector ( 15 downto 0 ) := x"0000"                                                 ;
    constant    C_IPV4_FLAGS            :           std_logic_Vector ( 15 downto 0 ) := x"0000"                                                 ;
    constant    C_IPV4_TTL              :           std_logic_Vector (  7 downto 0 ) := x"FF"                                                   ;
    constant    C_IPV4_PROTO            :           std_logic_vector (  7 downto 0 ) := x"11"                                                   ;

    component fifo_in_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
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

    signal  s_axis_tlast_reg            :           std_logic                                       := '0'              ;
    signal  s_axis_tready_sig           :           std_logic                                       := '0'              ;
    signal  in_dout_data                :           std_logic_vector ( data_width-1 downto 0 )                          ;
    signal  in_dout_keep                :           std_logic_vector ( ( data_width/8)-1 downto 0 )                     ;
    signal  in_dout_last                :           std_logic                                                           ;
    signal  in_rden                     :           std_logic                                                           ;
    signal  in_empty                    :           std_logic                                                           ;

    signal  d_in_dout_data              :           std_logic_vector ( HEAD_WIDTH-1 downto 0 )      := (others => '0')  ;

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

    signal  out_din_data                :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')  ;
    signal  out_din_keep                :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) := (others => '1')  ;
    signal  out_din_last                :           std_logic                                       := '0'              ;
    signal  out_wren                    :           std_logic                                       := '0'              ;
    signal  out_full                    :           std_logic                                                           ;
    signal  out_awfull                  :           std_logic                                                           ;

    signal  dbg_dump                    :           std_logic_Vector ( HEAD_WIDTH-1 downto 0 )      := (others => '1')  ;
    signal  last_cnt                    :           std_Logic_vector (  15 downto 0 )               := (others => '0')  ;
    
    signal  pkt_size_reg                :           std_logic_vector (  15 downto 0 )               := (others => '0')  ;  
    signal  pkt_size_reg_ip             :           std_logic_Vector (  15 downto 0 )               := (others => '0')  ;
    signal  pkt_size_reg_udp            :           std_logic_Vector (  15 downto 0 )               := (others => '0')  ;
    signal  pkt_size_reg_dump           :           std_logic_Vector (  15 downto 0 )               := (others => '0')  ;

    constant C_UDP_HEAD                 :           std_logic_Vector (  15 downto 0 )               := x"0008"          ;
    constant C_IP_HEAD                  :           std_logic_Vector (  15 downto 0 )               := x"0014"          ;
    constant C_DUMP_HEAD                :           std_logic_vector (  15 downto 0 )               := x"000C"          ;

    type fsm is(
        IDLE_ST             ,
        READ_FIRST_ST       ,
        WRITE_HEADER_ST     ,
        WRITE_LAST_ST       ,
        WRITE_DATA_ST       
    );

    signal  current_state               :           FSM                                             := IDLE_ST          ;
    signal  first_word                  :           std_logic                                       := '0'              ;

    signal  reg_pnum : std_logic_vector ( 15 downto 0 ) := (others => '0');

    component rst_syncer
        generic(
            INIT_VALUE                          :           bit             := '1'                                  
        );
        port(
            CLK                                 :   in      std_logic                                                   ;
            RESET                               :   in      std_logic                                                   ;
            RESET_OUT                           :   out     std_logic                                                   
        );
    end component;

begin

    reg_pnum_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if m_axis_reset = '1' then 
                reg_pnum <= (others => '0');
            else
                case current_state is
                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            reg_pnum <= reg_pnum + 1;
                        else
                            reg_pnum <= reg_pnum;    
                        end if;

                    when others => 
                        reg_pnum <= reg_pnum;
                    
                end case;
            end if;
        end if;
    end process;

    pkt_size_reg_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            pkt_size_reg(15 downto 5) <= (SIZE(10 downto 0 ) + 1);
        end if; 
    end process;

    pkt_size_reg_ip_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            pkt_size_reg_ip <= pkt_size_reg + (C_DUMP_HEAD + C_UDP_HEAD + C_IP_HEAD);
        end if; 
    end process;

    pkt_size_reg_udp_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            pkt_size_reg_udp <= pkt_size_reg + (C_DUMP_HEAD + C_UDP_HEAD);
        end if;
    end process;

    pkt_size_reg_dump_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            pkt_size_reg_dump <= pkt_size_reg + C_DUMP_HEAD;
        end if;
    end process;

    last_cnt_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_RESET = '1' then 
                last_cnt <= (others => '0') ;
            else
                if S_AXIS_TVALID = '1' and s_axis_tready_sig = '1' then 
                    if last_cnt < SIZE then 
                        last_cnt <= last_cnt + 1;
                    else
                        last_cnt <= (others => '0') ;
                    end if;
                else
                    last_cnt <= last_cnt;
                end if;
            end if;
        end if;
    end process;

    s_axis_tlast_reg_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_RESET = '1' then 
                s_axis_tlast_reg <= '0';
            else
                if S_AXIS_TVALID = '1' and s_axis_tready_sig = '1' then 
                    if last_cnt = SIZE-1 then 
                        s_axis_tlast_reg <= '1';
                    else
                        s_axis_tlast_reg <= '0';
                    end if;
                else
                    s_axis_tlast_reg <= s_axis_tlast_reg;
                end if;
            end if;
        end if;
    end process;

    head_cnt_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if m_axis_reset = '1' then 
                head_cnt <= (others => '0') ;
            else
                case current_state is

                    when WRITE_HEADER_ST =>
                        if out_awfull = '0' and in_empty = '0' then 
                            if head_cnt < HEAD_CNT_LIMIT_LOGIC then 
                                head_cnt <= head_cnt + 1;
                            else
                                head_cnt <= head_cnt;
                            end if;
                        else
                            head_cnt <= head_cnt;
                        end if;

                    when others => 
                        head_cnt <= (others => '0') ;
                end case;

            end if;
        end if;
    end process;

    GEN_SYNC_MODE : if ASYNC_MODE = false generate 


    fifo_in_sync_xpm_inst : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH          =>  DATA_WIDTH                                              ,
            MEMTYPE             =>  "distributed"                                           ,
            DEPTH               =>  16                                                       
        )
        port map (
            CLK                 =>  S_AXIS_CLK                                              ,
            RESET               =>  S_AXIS_RESET                                            ,
            
            S_AXIS_TDATA        =>  S_AXIS_TDATA                                            ,
            S_AXIS_TKEEP        =>  (others => '1')                                         ,
            S_AXIS_TVALID       =>  S_AXIS_TVALID                                           ,
            S_AXIS_TLAST        =>  s_axis_tlast_reg                                        ,
            S_AXIS_TREADY       =>  s_axis_tready_sig                                       ,

            IN_DOUT_DATA        =>  in_dout_data                                            ,
            IN_DOUT_KEEP        =>  in_dout_keep                                            ,
            IN_DOUT_LAST        =>  in_dout_last                                            ,
            IN_RDEN             =>  in_rden                                                 ,
            IN_EMPTY            =>  in_empty                                                 
        );

        m_axis_reset <= S_AXIS_RESET;

    end generate;

    GEN_ASYNC_MODE : if ASYNC_MODE = true generate
       
        fifo_in_async_xpm_inst : fifo_in_async_xpm
            generic map (
                DATA_WIDTH      =>  DATA_WIDTH                                              ,
                CDC_SYNC        =>  4                                                       ,
                MEMTYPE         =>  "distributed"                                           ,
                DEPTH           =>  16                           
            )
            port map (
                S_AXIS_CLK      =>  S_AXIS_CLK                                              ,
                S_AXIS_RESET    =>  S_AXIS_RESET                                            ,
                M_AXIS_CLK      =>  M_AXIS_CLK                                              ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA                                            ,
                S_AXIS_TKEEP    =>  (others => '1')                                         ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                                           ,
                S_AXIS_TLAST    =>  s_axis_tlast_reg                                        ,
                S_AXIS_TREADY   =>  s_axis_tready_sig                                       ,

                IN_DOUT_DATA    =>  in_dout_data                                            ,
                IN_DOUT_KEEP    =>  in_dout_keep                                            ,
                IN_DOUT_LAST    =>  in_dout_last                                            ,
                IN_RDEN         =>  in_rden                                                 ,
                IN_EMPTY        =>  in_empty                                                 
            );

        rst_syncer_inst_m_axis_reset : rst_syncer
            generic map (
                INIT_VALUE      =>  '1'                                                      
            )
            port map (
                CLK             =>  M_AXIS_CLK                                              ,
                RESET           =>  S_AXIS_RESET                                            ,
                RESET_OUT       =>  m_axis_reset                                             
            );

    end generate;

    S_AXIS_TREADY <= s_axis_tready_sig;

    in_rden <= '1' when out_awfull = '0' and in_empty = '0' and (current_state = WRITE_DATA_ST or current_state = READ_FIRST_ST) else '0';

    current_state_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if m_axis_reset = '1' then 
                current_state <= IDLE_ST;
            else
                case current_state is
                    when IDLE_ST =>
                        if out_awfull = '0' and in_empty = '0' then 
                            current_state <= WRITE_HEADER_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when WRITE_HEADER_ST =>
                        if head_cnt = HEAD_CNT_LIMIT_LOGIC then 
                            current_state <= READ_FIRST_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when READ_FIRST_ST =>   
                        if out_awfull = '0' then 
                            current_state <= WRITE_DATA_ST;
                        else
                            current_state <= current_state;
                        end if; 

                    when WRITE_DATA_ST =>
                        if in_rden = '1' then 
                            if in_dout_last = '1' then 
                                current_state <= WRITE_LAST_ST ;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            current_state <= IDLE_ST;
                        else
                            current_state <= current_state;    
                        end if;

                    when others => 
                        current_state <= current_state;
                
                end case;
            end if;
        end if;
    end process;

    fifo_out_sync_xpm_inst : fifo_out_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                              ,
            MEMTYPE         =>  "distributed"                           ,
            DEPTH           =>  16                                      
        )
        port map (
            CLK             =>  M_AXIS_CLK                              ,
            RESET           =>  m_axis_reset                            ,
            
            OUT_DIN_DATA    =>  out_din_data                            ,
            OUT_DIN_KEEP    =>  out_din_keep                            ,
            OUT_DIN_LAST    =>  out_din_last                            ,
            OUT_WREN        =>  out_wren                                ,
            OUT_FULL        =>  out_full                                ,
            OUT_AWFULL      =>  out_awfull                              ,
            
            M_AXIS_TDATA    =>  M_AXIS_TDATA                            ,
            M_AXIS_TKEEP    =>  M_AXIS_TKEEP                            ,
            M_AXIS_TVALID   =>  M_AXIS_TVALID                           ,
            M_AXIS_TLAST    =>  M_AXIS_TLAST                            ,
            M_AXIS_TREADY   =>  M_AXIS_TREADY                            
        );

    -- THIS PROCESS MUST BE CORRECTED IF DATA_BYTES CHANGED N_BYTES/HEAD_PART/HEAD_CNT_LIMIT
    -- because header structure was changed
    GEN_X16 : if N_BYTES = 2 generate
        out_din_data_processing : process(M_AXIS_CLK)
        begin
            if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
                case current_state is
                    when IDLE_ST =>
                        out_din_data <= out_din_data;
                                    
                    when WRITE_HEADER_ST =>
                        case head_cnt is
                            when x"00" => 
                                out_din_data <= x"1111";--111111111111111111111111111111111111111111111111111111111111";

                            when x"01" =>       
                                out_din_data <= in_dout_data ( DELAYREG_WIDTH-1 downto 0 ) & x"22";--222222222222222222222222222222222222222222" ;

                            when others =>
                                out_din_data <= out_din_data;

                        end case;   

                    when WRITE_DATA_ST =>
                        if in_rden = '1' then 
                            out_din_data <= in_dout_data( DELAYREG_WIDTH-1 downto 0 ) & d_in_dout_data;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            out_din_data( HEAD_WIDTH-1 downto 0 ) <= d_in_dout_data;
                            out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) <= out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) ;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when others => 
                        out_din_data <= out_din_data;

                end case;
            end if;
        end process;
    end generate;

    GEN_X64 : if N_BYTES = 8 generate 
        out_din_data_processing : process(M_AXIS_CLK)
        begin
            if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
                case current_state is
                    when IDLE_ST =>
                        out_din_data <= out_din_data;
                                    
                    when WRITE_HEADER_ST =>
                        case head_cnt is
                            when x"00" => 
                                out_din_data (   7 downto   0 ) <= DST_MAC (   7 downto   0 );
                                out_din_data (  15 downto   8 ) <= DST_MAC (  15 downto   8 );
                                out_din_data (  23 downto  16 ) <= DST_MAC (  23 downto  16 );
                                out_din_data (  31 downto  24 ) <= DST_MAC (  31 downto  24 );
                                out_din_data (  39 downto  32 ) <= DST_MAC (  39 downto  32 );
                                out_din_data (  47 downto  40 ) <= DST_MAC (  47 downto  40 );
                                out_din_data (  55 downto  48 ) <= SRC_MAC (   7 downto   0 );
                                out_din_data (  63 downto  56 ) <= SRC_MAC (  15 downto   8 );

                            when x"01" => 
                                out_din_data (   7 downto   0 ) <= SRC_MAC           (  23 downto  16 );
                                out_din_data (  15 downto   8 ) <= SRC_MAC           (  31 downto  24 );
                                out_din_data (  23 downto  16 ) <= SRC_MAC           (  39 downto  32 );
                                out_din_data (  31 downto  24 ) <= SRC_MAC           (  47 downto  40 );
                                out_din_data (  39 downto  32 ) <= C_ETH_TYPE        (  15 downto   8 );
                                out_din_data (  47 downto  40 ) <= C_ETH_TYPE        (   7 downto   0 );
                                out_din_data (  55 downto  48 ) <= C_IPV4_IP_VER_LEN (  15 downto   8 );
                                out_din_data (  63 downto  56 ) <= C_IPV4_IP_VER_LEN (   7 downto   0 );

                            when x"02" => 
                                out_din_data (   7 downto   0 ) <= pkt_size_reg_ip   (  15 downto   8 );
                                out_din_data (  15 downto   8 ) <= pkt_size_reg_ip   (   7 downto   0 );
                                out_din_data (  23 downto  16 ) <= C_IPV4_ID         (  15 downto   8 );
                                out_din_data (  31 downto  24 ) <= C_IPV4_ID         (   7 downto   0 );
                                out_din_data (  39 downto  32 ) <= C_IPV4_FLAGS      (  15 downto   8 );
                                out_din_data (  47 downto  40 ) <= C_IPV4_FLAGS      (   7 downto   0 );
                                out_din_data (  55 downto  48 ) <= C_IPV4_TTL                          ;
                                out_din_data (  63 downto  56 ) <= C_IPV4_PROTO                        ;
                            
                            when x"03" => 
                                out_din_data (   7 downto   0 ) <= ipv4_chksum       (   7 downto   0 );
                                out_din_data (  15 downto   8 ) <= ipv4_chksum       (  15 downto   8 );
                                out_din_data (  23 downto  16 ) <= SRC_IP            (   7 downto   0 );
                                out_din_data (  31 downto  24 ) <= SRC_IP            (  15 downto   8 );
                                out_din_data (  39 downto  32 ) <= SRC_IP            (  23 downto  16 );
                                out_din_data (  47 downto  40 ) <= SRC_IP            (  31 downto  24 );
                                out_din_data (  55 downto  48 ) <= DST_IP            (   7 downto   0 );
                                out_din_data (  63 downto  56 ) <= DST_IP            (  15 downto   8 );

                            when x"04" => 
                                out_din_data (   7 downto   0 ) <= DST_IP            (  23 downto  16 );                          
                                out_din_data (  15 downto   8 ) <= DST_IP            (  31 downto  24 );                          
                                out_din_data (  23 downto  16 ) <= SRC_PORT          (  15 downto   8 );
                                out_din_data (  31 downto  24 ) <= SRC_PORT          (   7 downto   0 );
                                out_din_data (  39 downto  32 ) <= DST_PORT          (  15 downto   8 );
                                out_din_data (  47 downto  40 ) <= DST_PORT          (   7 downto   0 );
                                out_din_data (  55 downto  48 ) <= pkt_size_reg_udp  (  15 downto   8 );
                                out_din_data (  63 downto  56 ) <= pkt_size_reg_udp  (   7 downto   0 );
                            when x"05" => 
                                out_din_data (   7 downto   0 ) <= ( others => '0' )    ;
                                out_din_data (  15 downto   8 ) <= ( others => '0' )    ;
                                out_din_data (  23 downto  16 ) <= pkt_size_reg_dump (   7 downto   0 )     ;
                                out_din_data (  31 downto  24 ) <= pkt_size_reg_dump (  15 downto   8 )     ;
                                out_din_data (  39 downto  32 ) <= reg_pnum (   7 downto   0 ) ;
                                out_din_data (  47 downto  40 ) <= reg_pnum (  15 downto   8 ) ;
                                out_din_data (  55 downto  48 ) <= CNT_US (   7 downto   0 );
                                out_din_data (  63 downto  56 ) <= CNT_US (  15 downto   8 );
                            when x"06" => 
                                out_din_data (   7 downto   0 ) <= CNT_US (  23 downto  16 );
                                out_din_data (  15 downto   8 ) <= CNT_US (  31 downto  24 );
                                out_din_data (  23 downto  16 ) <= CNT_US (  39 downto  32 );
                                out_din_data (  31 downto  24 ) <= CNT_US (  47 downto  40 );
                                out_din_data (  39 downto  32 ) <= CNT_US (  55 downto  48 );
                                out_din_data (  47 downto  40 ) <= CNT_US (  63 downto  56 );
                                out_din_data (  63 downto (DATA_WIDTH - DELAYREG_WIDTH)) <= in_dout_data( DELAYREG_WIDTH-1 downto 0 );

                            when others =>
                                out_din_data <= out_din_data;
                        end case;   

                    when WRITE_DATA_ST =>
                        if in_rden = '1' then 
                            out_din_data <= in_dout_data( DELAYREG_WIDTH-1 downto 0 ) & d_in_dout_data;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            out_din_data( HEAD_WIDTH-1 downto 0 ) <= d_in_dout_data;
                            out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) <= out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) ;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when others => 
                        out_din_data <= out_din_data;

                end case;
            end if;
        end process;
    end generate;

    GEN_X256 : if N_BYTES = 32 generate
        out_din_data_processing : process(M_AXIS_CLK)
        begin
            if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
                case current_state is
                    when IDLE_ST =>
                        out_din_data <= out_din_data;
                                    
                    when WRITE_HEADER_ST =>
                        case head_cnt is
                            when x"00" => 
                                out_din_data (  47 downto   0 ) <= DST_MAC;
                                out_din_data (  95 downto  48 ) <= SRC_MAC;
                                out_din_data ( 111 downto  96 ) <= C_ETH_TYPE       ( 7 downto 0 ) & C_ETH_TYPE       ( 15 downto 8 );
                                out_din_data ( 127 downto 112 ) <= C_IPV4_IP_VER_LEN( 7 downto 0 ) & C_IPV4_IP_VER_LEN( 15 downto 8 );
                                out_din_data ( 143 downto 128 ) <= pkt_size_reg_ip  ( 7 downto 0 ) & pkt_size_reg_ip  ( 15 downto 8 );
                                out_din_data ( 159 downto 144 ) <= C_IPV4_ID        ( 7 downto 0 ) & C_IPV4_ID        ( 15 downto 8 );
                                out_din_data ( 175 downto 160 ) <= C_IPV4_FLAGS     ( 7 downto 0 ) & C_IPV4_FLAGS     ( 15 downto 8 );
                                out_din_data ( 183 downto 176 ) <= C_IPV4_TTL                   ;
                                out_din_data ( 191 downto 184 ) <= C_IPV4_PROTO                 ;
                                out_din_data ( 207 downto 192 ) <= ipv4_chksum                  ; -- not swap CHECKSUM
                                out_din_data ( 239 downto 208 ) <= SRC_IP                       ;
                                out_din_data ( 255 downto 240 ) <= DST_IP( 15 downto 0 )        ;

                            when x"01" =>       
                                --out_din_data <= in_dout_data ( DELAYREG_WIDTH-1 downto 0 ) & x"22222222222222222222222222222222222222222222" ;
                                out_din_data(  15 downto   0 ) <= DST_IP( 31 downto 16 ) ;
                                out_din_data(  31 downto  16 ) <= SRC_PORT ( 7 downto 0 ) & SRC_PORT ( 15 downto 8 );
                                out_din_data(  47 downto  32 ) <= DST_PORT ( 7 downto 0 ) & DST_PORT ( 15 downto 8 );
                                out_din_data(  63 downto  48 ) <= pkt_size_reg_udp( 7 downto 0 ) & pkt_size_reg_udp ( 15 downto 8 ) ;
                                out_din_data(  79 downto  64 ) <= (others => '0')     ;
                                out_din_data(  95 downto  80 ) <= pkt_size_reg_dump;
                                out_din_data( 111 downto  96 ) <= reg_pnum ; 
                                out_din_data( 119 downto 112 ) <= CNT_US (  7 downto   0 )   ;
                                out_din_data( 127 downto 120 ) <= CNT_US ( 15 downto   8 )   ;
                                out_din_data( 135 downto 128 ) <= CNT_US ( 23 downto  16 )   ;
                                out_din_data( 143 downto 136 ) <= CNT_US ( 31 downto  24 )   ;
                                out_din_data( 151 downto 144 ) <= CNT_US ( 39 downto  32 )   ;
                                out_din_data( 159 downto 152 ) <= CNT_US ( 47 downto  40 )   ;
                                out_din_data( 167 downto 160 ) <= CNT_US ( 55 downto  48 )   ;
                                out_din_data( 175 downto 168 ) <= CNT_US ( 63 downto  56 )   ;
                                out_din_data( 255 downto (DATA_WIDTH - DELAYREG_WIDTH)) <= in_dout_data( DELAYREG_WIDTH-1 downto 0 );

                            when others =>
                                out_din_data <= out_din_data;
                        end case;   

                    when WRITE_DATA_ST =>
                        if in_rden = '1' then 
                            out_din_data <= in_dout_data( DELAYREG_WIDTH-1 downto 0 ) & d_in_dout_data;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            out_din_data( HEAD_WIDTH-1 downto 0 ) <= d_in_dout_data;
                            out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) <= out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) ;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when others => 
                        out_din_data <= out_din_data;

                end case;
            end if;
        end process;
    end generate;

    GEN_XOTHER : if not(((N_BYTES = 32) or (N_BYTES = 2) or (N_BYTES = 8))) generate

        out_din_data_processing : process(M_AXIS_CLK)
        begin
            if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
                case current_state is
                    when IDLE_ST =>
                        out_din_data <= out_din_data;
                                    
                    when WRITE_HEADER_ST =>
                        case head_cnt is
                            when x"00" => 
                                out_din_data <= (others => '1');
                            when x"01" =>       
                                out_din_data <= in_dout_data ( DELAYREG_WIDTH-1 downto 0 ) & dbg_dump;
                            when others =>
                                out_din_data <= out_din_data;
                        end case;   

                    when WRITE_DATA_ST =>
                        if in_rden = '1' then 
                            out_din_data <= in_dout_data( DELAYREG_WIDTH-1 downto 0 ) & d_in_dout_data;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            out_din_data( HEAD_WIDTH-1 downto 0 ) <= d_in_dout_data;
                            out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) <= out_din_data( DATA_WIDTH-1 downto HEAD_WIDTH ) ;
                        else
                            out_din_data <= out_din_data;
                        end if;

                    when others => 
                        out_din_data <= out_din_data;

                end case;
            end if;
        end process;
    
    end generate;

    out_din_last_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            case current_state is
                when WRITE_LAST_ST =>
                    if out_awfull = '0' then 
                        out_din_last <= '1';
                    else
                        out_din_last <= out_din_last;
                    end if;

                when others => 
                    out_din_last <= '0';
            end case;   
        end if;
    end process;

    out_din_keep_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            case current_state is
                when WRITE_LAST_ST =>
                    if out_awfull = '0' then 
                        out_din_keep((HEAD_PART-1) downto 0 ) <= (others => '1') ;
                        out_din_keep(((DATA_WIDTH/8)-1) downto HEAD_PART) <= (others => '0') ;
                    else
                        out_din_keep <= out_din_keep;    
                    end if;

                when others =>
                    out_din_keep <= (others => '1');

            end case;
        end if;
    end process;

    d_in_dout_data_processing : process(M_AXIS_CLK)
    begin 
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if in_rden = '1' then
                d_in_dout_data <= in_dout_data((DATA_WIDTH-1)  downto DELAYREG_WIDTH);
            else
                d_in_dout_data <= d_in_dout_data;
            end if;
        end if;
    end process;

    out_wren_processing : process(M_AXIS_CLK)
    begin
        if M_AXIS_CLK'event AND M_AXIS_CLK = '1' then 
            if m_axis_reset = '1' then 
                out_wren <= '0';
            else
                case current_state is 
                    when WRITE_HEADER_ST => 
                        if out_awfull = '0' and in_empty = '0' then 
                            out_wren <= '1';
                        else
                            out_wren <= '0';
                        end if;

                    when WRITE_DATA_ST =>
                        if out_awfull = '0' and in_empty = '0' then
                            out_wren <= '1';
                        else
                            out_wren <= '0';    
                        end if;
                    
                    when WRITE_LAST_ST =>
                        if out_awfull = '0' then 
                            out_wren <= '1';
                        else
                            out_wren <= '0';
                        end if;

                    when others => 
                        out_wren <= '0';

                end case;
            end if;
        end if;
    end process;

    ipv4_chksum_calc_sync_inst : ipv4_chksum_calc_sync
        generic map (
            SWAP_BYTES          =>  true         
        )
        port map (
            CLK                 =>  M_AXIS_CLK                      ,
            RESET               =>  m_axis_reset                    ,
            IPV4_CALC_START     =>  ipv4_calc_start                 ,
            IPV4_IP_VER_LEN     =>  C_IPV4_IP_VER_LEN               ,
            IPV4_IP_ID          =>  C_IPV4_ID                       ,
            IPV4_TOTAL_SIZE     =>  pkt_size_reg_ip                 ,
            IPV4_TTL            =>  C_IPV4_TTL                      ,
            IPV4_PROTO          =>  C_IPV4_PROTO                    ,
            IPV4_SRC_ADDR       =>  SRC_IP                          ,
            IPV4_DST_ADDR       =>  DST_IP                          ,
            IPV4_CHKSUM         =>  ipv4_chksum                     ,
            IPV4_DONE           =>  ipv4_done                        

        );

end axis_udp_pkg_arch;
