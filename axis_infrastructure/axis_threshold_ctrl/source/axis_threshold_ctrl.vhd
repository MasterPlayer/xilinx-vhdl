library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    USE IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";
    
library UNISIM;
    use UNISIM.VComponents.all;


entity axis_threshold_ctrl is
    generic(
        N_BYTES             :           integer                          := 8                   ;
        USER_WIDTH          :           integer                          := 8                   ;
        DEPENDENCY          :           string                           := "COUNTER"           ; -- DATA | PACKET
        ASYNC_CTRL          :           string                           := "S_SIDE"            ; -- S_SIDE | M_SIDE | FULL
        DFLT_RDY_DRTN       :           integer                          := 1024                ; -- Number of words for default value READY_DURATION_LIMIT
        DFLT_BSY_DRTN       :           integer                          := 1024                ; -- Number of words for default value BUSY_DURATION_LIMIT
        DEPTH               :           integer                          := 1024                  -- depth for fifo
    );
    port(
        CLK                 :   in      std_logic                                               ;
        RESET               :   in      std_logic                                               ;

        CMD_READY_DURATION  :   in      std_logic_Vector ( 31 downto 0 )                        ;
        CMD_BUSY_DURATION   :   in      std_Logic_Vector ( 31 downto 0 )                        ;
        CMD_VALID           :   in      std_logic                                               ;

        S_AXIS_CLK          :   in      std_Logic                                               ;
        S_AXIS_TDATA        :   in      std_logic_Vector (  (N_BYTES*8)-1 downto 0 )            ;
        S_AXIS_TKEEP        :   in      std_logic_vector ( N_BYTES-1 downto 0 )                 ;
        S_AXIS_TUSER        :   in      std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
        S_AXIS_TVALID       :   in      std_logic                                               ;
        S_AXIS_TREADY       :   out     std_logic                                               ;
        S_AXIS_TLAST        :   in      std_logic                                               ;

        M_AXIS_CLK          :   in      std_Logic                                               ;
        M_AXIS_TDATA        :   out     std_logic_Vector ( ((N_BYTES*8)-1) downto 0 )           ;
        M_AXIS_TKEEP        :   out     std_logic_Vector ( (N_BYTES-1) downto 0 )               ;
        M_AXIS_TUSER        :   out     std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
        M_AXIS_TVALID       :   out     std_logic                                               ;
        M_AXIS_TREADY       :   in      std_logic                                               ;
        M_AXIS_TLAST        :   out     std_logic                                               
    );
end axis_threshold_ctrl;




architecture axis_threshold_ctrl_arch of axis_threshold_ctrl is

    constant VERSION : string := "v1.0";

    constant DATA_WIDTH : integer := N_BYTES*8;

    component rst_syncer
        generic(
            INIT_VALUE                          :           bit             := '1'                                  
        );
        port(
            CLK                                 :   in      std_logic                                               ;
            RESET                               :   in      std_logic                                               ;
            RESET_OUT                           :   out     std_logic                                               
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

    signal  cmd_dout                :       std_logic_Vector ( 63 downto 0 )                ;
    signal  cmd_ready_duration_reg  :       std_Logic_Vector ( 31 downto 0 ) := conv_std_logic_Vector (DFLT_RDY_DRTN, 32)    ;
    signal  cmd_busy_duration_reg   :       std_Logic_Vector ( 31 downto 0 ) := conv_std_logic_Vector (DFLT_BSY_DRTN, 32)     ;
    signal  cmd_rden                :       std_logic                        := '0'                                                                     ;
    signal  cmd_empty               :       std_Logic                                       ;

    component fifo_in_sync_user_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                                  ;
            USER_WIDTH      :           integer         :=  1                                   ;
            MEMTYPE         :           String          :=  "block"                             ;
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
            IN_EMPTY        :   out     std_logic                                                
        );
    end component;


    component fifo_in_async_user_xpm
        generic(
            CDC_SYNC        :           integer         :=  4                               ;
            DATA_WIDTH      :           integer         :=  16                              ;
            USER_WIDTH      :           integer         :=  1                               ;
            MEMTYPE         :           String          :=  "block"                         ;
            DEPTH           :           integer         :=  16                              
        );
        port(
            S_AXIS_CLK      :   in      std_logic                                               ;
            S_AXIS_RESET    :   in      std_logic                                               ;
            M_AXIS_CLK      :   in      std_logic                                               ;
            
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
            IN_EMPTY        :   out     std_logic                                                
        );
    end component;

    signal  in_dout_data                :           std_logic_vector ( DATA_WIDTH-1 downto 0 )                          ;
    signal  in_dout_keep                :           std_logic_vector ( ( DATA_WIDTH/8)-1 downto 0 )                     ;
    signal  in_dout_user                :           std_logic_vector ( USER_WIDTH-1 downto 0 )                          ;
    signal  in_dout_last                :           std_logic                                                           ;
    signal  in_rden                     :           std_logic                                                           ;
    signal  in_empty                    :           std_logic                                                           ;

    component fifo_out_sync_tuser_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            USER_WIDTH      :           integer         :=  1                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            
            OUT_DIN_DATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP    :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_USER    :   in      std_logic_Vector ( USER_WIDTH-1 downto 0 )      ;
            OUT_DIN_LAST    :   in      std_logic                                       ;
            OUT_WREN        :   in      std_logic                                       ;
            OUT_FULL        :   out     std_logic                                       ;
            OUT_AWFULL      :   out     std_logic                                       ;
            
            M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TUSER    :   out     std_logic_vector ( USER_WIDTH-1 downto 0 )      ;
            M_AXIS_TVALID   :   out     std_logic                                       ;
            M_AXIS_TLAST    :   out     std_logic                                       ;
            M_AXIS_TREADY   :   in      std_logic                                        

        );
    end component;

    component fifo_out_async_user_xpm
        generic(
            DATA_WIDTH      :           integer         :=  256                         ;
            USER_WIDTH      :           integer         :=  8                           ;
            CDC_SYNC        :           integer         :=  4                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;        
            OUT_DIN_DATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP    :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_USER    :   in      std_Logic_Vector ( USER_WIDTH-1 downto 0 )      ;
            OUT_DIN_LAST    :   in      std_logic                                       ;
            OUT_WREN        :   in      std_logic                                       ;
            OUT_FULL        :   out     std_logic                                       ;
            OUT_AWFULL      :   out     std_logic                                       ;

            M_AXIS_CLK      :   in      std_logic                                       ;
            M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TUSER    :   out     std_Logic_Vector ( USER_WIDTH-1 downto 0 )      ;
            M_AXIS_TVALID   :   out     std_logic                                       ;
            M_AXIS_TLAST    :   out     std_logic                                       ;
            M_AXIS_TREADY   :   in      std_logic                                        

        );
    end component;

    signal  out_din_data                :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')  ;
    signal  out_din_keep                :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) := (others => '1')  ;
    signal  out_din_user                :           std_logic_Vector ( USER_WIDTH-1 downto 0 )      := (others => '1')  ;
    signal  out_din_last                :           std_logic                                       := '0'              ;
    signal  out_wren                    :           std_logic                                       := '0'              ;
    signal  out_full                    :           std_logic                                                           ;
    signal  out_awfull                  :           std_logic                                                           ;

    type fsm is(
        IDLE_ST             ,
        READY_ST            ,
        BUSY_ST              
    );

    signal  current_state               :           FSM                                             := IDLE_ST          ;

    signal  ready_cnt                   :           std_logic_Vector ( 31 downto 0 ) := (others => '0')     ;
    signal  busy_cnt                    :           std_logic_Vector ( 31 downto 0 ) := (others => '0')     ;

    signal  sreset                      :           std_Logic                                                           ;
    signal  mreset                      :           std_Logic                                                           ;

    signal  first_run                   :           std_Logic                        := '0'                 ;

begin

    first_run_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                first_run <= '1';
            else
                if cmd_empty = '0' then 
                    first_run <= '0';
                else
                    first_run <= first_run;
                end if;
            end if;
        end if;
    end process;

    fifo_cmd_sync_xpm_inst : fifo_cmd_sync_xpm
        generic map (
            DATA_WIDTH      =>  64                                  ,
            MEMTYPE         =>  "distributed"                       ,
            DEPTH           =>  16                                   
        )
        port map (
            CLK             =>  CLK                                     ,
            RESET           =>  RESET                                   ,
            DIN             =>  CMD_READY_DURATION & CMD_BUSY_DURATION  ,
            WREN            =>  CMD_VALID                               ,
            FULL            =>  open                                    ,
            DOUT            =>  cmd_dout                                ,
            RDEN            =>  cmd_rden                                ,
            EMPTY           =>  cmd_empty                           
        );
    
    cmd_rden_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when IDLE_ST => 
                    if cmd_empty = '0' then 
                        cmd_rden <= '1';    
                    else
                        cmd_rden <= '0';
                    end if;

                when others => 
                    cmd_rden <= '0';

            end case;
        end if;
    end process;

    cmd_ready_duration_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                cmd_ready_duration_reg <= conv_std_Logic_Vector ( DFLT_RDY_DRTN, cmd_ready_duration_reg'length);
            else
                case current_state is
                    when IDLE_ST => 
                        if cmd_empty = '0' then 
                            cmd_ready_duration_reg <= cmd_dout(63 downto 32);
                        else
                            cmd_ready_duration_reg <= cmd_ready_duration_reg;
                        end if;

                    when others => 
                        cmd_ready_duration_reg <= cmd_ready_duration_reg;
                end case;
            end if;
        end if;
    end process;

    cmd_busy_duration_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then
            if RESET = '1' then 
                cmd_busy_duration_reg <= conv_std_Logic_Vector ( DFLT_BSY_DRTN, cmd_busy_duration_reg'length);
            else
                case current_state is
                    when IDLE_ST => 
                        if cmd_empty = '0' then 
                            cmd_busy_duration_reg <= cmd_dout(31 downto 0 );
                        else
                            cmd_busy_duration_reg <= cmd_busy_duration_reg;
                        end if;

                    when others => 
                        cmd_busy_duration_reg <= cmd_busy_duration_reg;
                end case;
            end if; 
        end if;
    end process;

    ASYNC_CTRL_M_SIDE_SYNC_IN_GEN : if ASYNC_CTRL = "M_SIDE" or ASYNC_CTRL = "SYNC" generate
        fifo_in_sync_user_xpm_inst : fifo_in_sync_user_xpm
            generic map (
                DATA_WIDTH          =>  DATA_WIDTH              ,
                USER_WIDTH          =>  USER_WIDTH              ,
                MEMTYPE             =>  "distributed"           ,
                DEPTH               =>  DEPTH                     
            )
            port map (
                CLK                 =>  CLK                     ,
                RESET               =>  RESET                   ,
                
                S_AXIS_TDATA        =>  S_AXIS_TDATA            ,
                S_AXIS_TKEEP        =>  S_AXIS_TKEEP            ,
                S_AXIS_TUSER        =>  S_AXIS_TUSER            ,
                S_AXIS_TVALID       =>  S_AXIS_TVALID           ,
                S_AXIS_TLAST        =>  S_AXIS_TLAST            ,
                S_AXIS_TREADY       =>  S_AXIS_TREADY           ,

                IN_DOUT_DATA        =>  in_dout_data            ,
                IN_DOUT_KEEP        =>  in_dout_keep            ,
                IN_DOUT_USER        =>  in_dout_user            ,
                IN_DOUT_LAST        =>  in_dout_last            ,
                IN_RDEN             =>  in_rden                 ,
                IN_EMPTY            =>  in_empty                 
            );
    end generate;

    ASYNC_CTRL_S_SIDE_FULL_IN_GEN : if ASYNC_CTRL = "S_SIDE" or ASYNC_CTRL = "FULL" generate

        fifo_in_async_user_xpm_inst : fifo_in_async_user_xpm
            generic map (
                CDC_SYNC            =>  4                       ,
                DATA_WIDTH          =>  DATA_WIDTH              ,
                USER_WIDTH          =>  USER_WIDTH              ,
                MEMTYPE             =>  "distributed"           ,
                DEPTH               =>  DEPTH                      
            )
            port map (
                S_AXIS_CLK          =>  S_AXIS_CLK              ,
                S_AXIS_RESET        =>  sreset                  ,
                M_AXIS_CLK          =>  CLK                     ,
                
                S_AXIS_TDATA        =>  S_AXIS_TDATA            ,
                S_AXIS_TKEEP        =>  S_AXIS_TKEEP            ,
                S_AXIS_TUSER        =>  S_AXIS_TUSER            ,
                S_AXIS_TVALID       =>  S_AXIS_TVALID           ,
                S_AXIS_TLAST        =>  S_AXIS_TLAST            ,
                S_AXIS_TREADY       =>  S_AXIS_TREADY           ,

                IN_DOUT_DATA        =>  in_dout_data            ,
                IN_DOUT_KEEP        =>  in_dout_keep            ,
                IN_DOUT_USER        =>  in_dout_user            ,
                IN_DOUT_LAST        =>  in_dout_last            ,
                IN_RDEN             =>  in_rden                 ,
                IN_EMPTY            =>  in_empty                 
            );

        rst_syncer_inst_s_axis : rst_syncer
            generic map (
                INIT_VALUE          =>  '1'                     
            )
            port map (
                CLK                 =>  S_AXIS_CLK              ,
                RESET               =>  RESET                   ,
                RESET_OUT           =>  sreset                   
            );

    end generate; 


    in_rden <= '1' when out_awfull = '0' and in_empty = '0' and current_state = READY_ST else '0';

    DEPENDENCY_DATA_GEN : if DEPENDENCY = "DATA" generate 
        current_state_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    current_state <= IDLE_ST;
                else
                    case current_state is
                        when IDLE_ST =>
                            if cmd_empty = '0' or first_run = '1' then 
                                current_state <= READY_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when READY_ST =>
                            if ready_cnt < cmd_ready_duration_reg then 
                                current_state <= current_state;
                            else
                                if cmd_empty = '0' then 
                                    current_state <= IDLE_ST;
                                else
                                    if cmd_busy_duration_reg = 0 then 
                                        current_state <= current_state;
                                    else
                                        current_state <= BUSY_ST;
                                    end if;
                                end if;
                            end if;

                        when BUSY_ST =>   
                            if busy_cnt < cmd_busy_duration_reg then 
                                current_state <= current_state;
                            else
                                if cmd_empty = '0' then 
                                    current_state <= IDLE_ST;
                                else
                                    if cmd_ready_duration_reg = 0 then 
                                        current_state <= current_state;
                                    else
                                        current_state <= READY_ST;
                                    end if;
                                end if;
                            end if;

                        when others => 
                            current_state <= current_state;
                    
                    end case;
                end if;
            end if;
        end process;

        ready_cnt_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    ready_cnt <= (others => '0');
                else
                    case current_state is
                        when READY_ST => 
                            if in_empty = '0' and out_awfull = '0' then 
                                if ready_cnt < cmd_ready_duration_reg then 
                                    ready_cnt <= ready_cnt + 1;
                                else
                                    ready_cnt <= (others => '0');
                                end if;
                            else
                                ready_cnt <= ready_cnt;    
                            end if;

                        when others => 
                            ready_cnt <= (others => '0');

                    end case;
                end if;
            end if;
        end process;

        busy_cnt_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    busy_cnt <= (others => '0');
                else
                    case current_state is
                        when BUSY_ST => 
                            if in_empty = '0' and out_awfull = '0' then 
                                if busy_cnt < cmd_busy_duration_reg then 
                                    busy_cnt <= busy_cnt + 1;
                                else
                                    busy_cnt <= (others => '0');
                                end if;
                            else
                                busy_cnt <= busy_cnt;
                            end if;
                        
                        when others => 
                            busy_cnt <= (others => '0');

                    end case;
                end if;
            end if;
        end process;

    end generate;



    DEPENDENCY_PACKET_GEN : if DEPENDENCY = "PACKET" generate 
        current_state_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    current_state <= IDLE_ST;
                else
                    case current_state is
                        when IDLE_ST =>
                            if cmd_empty = '0' or first_run = '1' then 
                                current_state <= READY_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when READY_ST =>
                            if in_rden = '1' then 
                                if in_dout_last = '1' then 
                                    if cmd_empty = '0' then 
                                        current_state <= IDLE_ST;
                                    else
                                        if cmd_busy_duration_reg = 0 then 
                                            current_state <= current_state;
                                        else
                                            current_state <= BUSY_ST;
                                        end if;
                                    end if;
                                else
                                    current_state <= current_state;
                                end if;
                            else
                                current_state <= current_state;
                            end if;

                        when BUSY_ST =>   
                            if busy_cnt < cmd_busy_duration_reg then 
                                current_state <= current_state;
                            else
                                if cmd_empty = '0' then 
                                    current_state <= IDLE_ST;
                                else
                                    current_state <= READY_ST;
                                end if;
                            end if;

                        when others => 
                            current_state <= current_state;
                    
                    end case;
                end if;
            end if;
        end process;

        busy_cnt_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    busy_cnt <= (others => '0');
                else
                    case current_state is
                        when BUSY_ST => 
                            if in_empty = '0' and out_awfull = '0' then 
                                if busy_cnt < cmd_busy_duration_reg then 
                                    busy_cnt <= busy_cnt + 1;
                                else
                                    busy_cnt <= (others => '0');
                                end if;
                            else
                                busy_cnt <= busy_cnt;
                            end if;
                        
                        when others => 
                            busy_cnt <= (others => '0');

                    end case;
                end if;
            end if;
        end process;
        
    end generate;



    DEPENDENCY_COUNTER_GEN : if DEPENDENCY = "COUNTER" generate 
        current_state_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    current_state <= IDLE_ST;
                else
                    case current_state is
                        when IDLE_ST =>
                            if cmd_empty = '0' or first_run = '1' then 
                                current_state <= READY_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when READY_ST =>
                            if ready_cnt < cmd_ready_duration_reg then 
                                current_state <= current_state;
                            else
                                if cmd_empty = '0' then 
                                    current_state <= IDLE_ST;
                                else
                                    if cmd_busy_duration_reg = 0 then 
                                        current_state <= current_state;
                                    else
                                        current_state <= BUSY_ST;
                                    end if;
                                end if;
                            end if;

                        when BUSY_ST =>   
                            if busy_cnt < cmd_busy_duration_reg then 
                                current_state <= current_state;
                            else
                                if cmd_empty = '0' then 
                                    current_state <= IDLE_ST;
                                else
                                    if cmd_ready_duration_reg = 0 then 
                                        current_state <= current_state;
                                    else
                                        current_state <= READY_ST;
                                    end if;
                                end if;
                            end if;

                        when others => 
                            current_state <= current_state;
                    
                    end case;
                end if;
            end if;
        end process;

        ready_cnt_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    ready_cnt <= (others => '0');
                else
                    case current_state is
                        when READY_ST => 
                            if ready_cnt < cmd_ready_duration_reg then 
                                ready_cnt <= ready_cnt + 1;
                            else
                                ready_cnt <= (others => '0');
                            end if;

                        when others => 
                            ready_cnt <= (others => '0');

                    end case;
                end if;
            end if;
        end process;

        busy_cnt_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    busy_cnt <= (others => '0');
                else
                    case current_state is
                        when BUSY_ST => 
                            if busy_cnt < cmd_busy_duration_reg then 
                                busy_cnt <= busy_cnt + 1;
                            else
                                busy_cnt <= (others => '0');
                            end if;
                        
                        when others => 
                            busy_cnt <= (others => '0');

                    end case;
                end if;
            end if;
        end process;

    end generate;


    ASYNC_CTRL_M_SIDE_SYNC_OUT_GEN : if ASYNC_CTRL = "S_SIDE" or ASYNC_CTRL = "SYNC" generate

        fifo_out_sync_tuser_xpm_inst : fifo_out_sync_tuser_xpm
            generic map (
                DATA_WIDTH      =>  DATA_WIDTH          ,
                USER_WIDTH      =>  USER_WIDTH          ,
                MEMTYPE         =>  "distributed"       ,
                DEPTH           =>  DEPTH                  
            )
            port map (
                CLK             =>  CLK                 ,
                RESET           =>  RESET               ,
                
                OUT_DIN_DATA    =>  out_din_data        ,
                OUT_DIN_KEEP    =>  out_din_keep        ,
                OUT_DIN_USER    =>  out_din_user        ,
                OUT_DIN_LAST    =>  out_din_last        ,
                OUT_WREN        =>  out_wren            ,
                OUT_FULL        =>  out_full            ,
                OUT_AWFULL      =>  out_awfull          ,
                
                M_AXIS_TDATA    =>  M_AXIS_TDATA        ,
                M_AXIS_TKEEP    =>  M_AXIS_TKEEP        ,
                M_AXIS_TUSER    =>  M_AXIS_TUSER        ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID       ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST        ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY        
            );

    end generate;

    ASYNC_CTRL_S_SIDE_FULL_OUT_GEN : if ASYNC_CTRL = "M_SIDE" or ASYNC_CTRL = "FULL" generate

        fifo_out_async_user_xpm_inst : fifo_out_async_user_xpm
            generic map (
                DATA_WIDTH      =>  DATA_WIDTH          ,
                USER_WIDTH      =>  USER_WIDTH          ,
                CDC_SYNC        =>  4                   ,
                MEMTYPE         =>  "distributed"       ,
                DEPTH           =>  DEPTH                  
            )
            port map (
                CLK             =>  CLK                 ,
                RESET           =>  RESET               ,     
                OUT_DIN_DATA    =>  out_din_data        ,
                OUT_DIN_KEEP    =>  out_din_keep        ,
                OUT_DIN_USER    =>  out_din_user        ,
                OUT_DIN_LAST    =>  out_din_last        ,
                OUT_WREN        =>  out_wren            ,
                OUT_FULL        =>  out_full            ,
                OUT_AWFULL      =>  out_awfull          ,

                M_AXIS_CLK      =>  M_AXIS_CLK          ,
                M_AXIS_TDATA    =>  M_AXIS_TDATA        ,
                M_AXIS_TKEEP    =>  M_AXIS_TKEEP        ,
                M_AXIS_TUSER    =>  M_AXIS_TUSER        ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID       ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST        ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY        

            );

    end generate;

    -- THIS PROCESS MUST BE CORRECTED IF DATA_BYTES CHANGED N_BYTES/HEAD_PART/HEAD_CNT_LIMIT
    -- because header structure was changed

    out_din_data_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when IDLE_ST =>
                    out_din_data <= out_din_data;

                when READY_ST =>
                    if in_rden = '1' then 
                        out_din_data <= in_dout_data;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when others => 
                    out_din_data <= out_din_data;

            end case;
        end if;
    end process;

    out_din_last_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when READY_ST =>
                    if in_rden = '1' then
                        out_din_last <= in_dout_last;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when others => 
                    out_din_last <= '0';
            end case;   
        end if;
    end process;

    out_din_keep_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when READY_ST =>
                    if in_rden = '1' then
                        out_din_keep <= in_dout_keep;
                    else
                        out_din_keep <= out_din_keep;    
                    end if;

                when others =>
                    out_din_keep <= out_din_keep;

            end case;
        end if;
    end process;

    out_din_user_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when READY_ST => 
                    if in_rden = '1' then 
                        out_din_user <= in_dout_user;
                    else
                        out_din_user <= out_din_user;
                    end if;

                when others => 
                    out_din_user <= out_din_user;
                    
            end case;
        end if;
    end process;


    out_wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                out_wren <= '0';
            else
                case current_state is 
                    when READY_ST => 
                        if out_awfull = '0' and in_empty = '0' then 
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

end axis_threshold_ctrl_arch;
