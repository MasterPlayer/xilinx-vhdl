library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;



library UNISIM;
    use UNISIM.VComponents.all;



entity axis_data_delayer is
    generic (
        DW                      :           integer := 32                                           ;
        DELAY                   :           integer := 8000                                         ;
        MEMTYPE                 :           string  := "block"                                      ;
        MAX_PKT_SIZE            :           integer := 2048                                         
    );
    port (
        CLK                     :   in      std_logic                                               ;
        RESET                   :   in      std_logic                                               ;

        S_AXIS_TDATA            :   in      std_logic_Vector ( DW-1 downto 0 )                      ;
        S_AXIS_TKEEP            :   in      std_logic_Vector ( ((DW/8)-1) downto 0 )                ;
        S_AXIS_TVALID           :   in      std_logic                                               ;
        S_AXIS_TLAST            :   in      std_logic                                               ;

        M_AXIS_TDATA            :   out     std_logic_Vector ( DW-1 downto 0 )                      ;
        M_AXIS_TKEEP            :   out     std_logic_Vector ( ((DW/8)-1) downto 0 )                ;
        M_AXIS_TVALID           :   out     std_logic                                               ;
        M_AXIS_TLAST            :   out     std_logic                                               ;

        DBG_OVERLOAD_DATA       :   out     std_logic                                               ;
        DBG_OVERLOAD_TIMER      :   out     std_Logic                                                

    );
end axis_data_delayer;



architecture axis_data_delayer_arch of axis_data_delayer is

------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_in_sync_xpm component declaration <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

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

    signal  data_din        :           std_logic_vector ( ((DW/8)+DW) downto 0 )   := (others => '0')  ;
    signal  data_wren       :           std_logic                                   := '0'              ;
    signal  data_rden       :           std_logic                                   := '0'              ;
    signal  data_dout       :           std_logic_vector ( ((DW/8)+DW) downto 0 )                       ;
    signal  data_empty      :           std_logic                                                       ;

    signal  s_axis_tready   :           std_logic                                                       ;
------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_cmd_sync_xpm component declaration <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

    -- fifo holds time markers when packet has begin loading to data fifo 
    -- time marker width has 64 bits
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




    signal  timer_din           :           std_logic_vector ( 63 downto 0 )    := (others => '0')  ;
    signal  timer_wren          :           std_logic                           := '0'              ;
    signal  timer_rden          :           std_logic                           := '0'              ;
    signal  timer_dout          :           std_logic_vector ( 63 downto 0 )                        ;
    signal  timer_full          :           std_logic                                               ;
    signal  timer_empty         :           std_logic                                               ;

    signal  timer_cnt_0         :           std_Logic_VectoR ( 63 downto 0 )    := (others => '0')  ;
    signal  timer_cnt_1         :           std_Logic_vector ( 63 downto 0 )    := (others => '0')  ;


    type fsm is (
        WAIT_ST     ,
        READ_ST     
    );

    signal current_state        :           FSM                                 := WAIT_ST          ;
    signal  first_flaq                  :           std_Logic                   := '1'              ;

    signal  dbg_overload_data_reg       :           std_logic                   := '0'              ;
    signal  dbg_overload_timer_reg      :           std_Logic                   := '0'              ;

    signal  allow_data_rden             :           std_logic                   := '0'              ;


begin


    M_AXIS_TDATA                        <= data_dout(DW-1 downto 0)                 ;
    M_AXIS_TKEEP                        <= data_dout(((DW/8)+DW)-1 downto DW)       ;
    M_AXIS_TLAST                        <= data_dout((DW/8)+DW)                     ;
    M_AXIS_TVALID                       <= data_rden                                ;

    DBG_OVERLOAD_DATA                   <=  dbg_overload_data_reg                                   ;
    DBG_OVERLOAD_TIMER                  <=  dbg_overload_timer_reg                                  ;

    dbg_overload_data_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                dbg_overload_data_reg <= '0';
            else
                if s_axis_tready = '0' then 
                    dbg_overload_data_reg <= '1';
                else
                    dbg_overload_data_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    dbg_overload_timer_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                dbg_overload_timer_reg <= '0';
            else
                dbg_overload_timer_reg <= timer_full;
            end if;
        end if;
    end process;

    timer_cnt_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                timer_cnt_0 <= (others => '0');
                --timer_cnt_0 <= x"0000000000000001";
            else
                timer_cnt_0 <= timer_cnt_0 + 1;
            end if;
        end if;
    end process;

    timer_cnt_1_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                timer_cnt_1 <= (others => '0');
            else
                if timer_cnt_0 < DELAY then 
                    timer_cnt_1 <= timer_cnt_1;
                else
                    timer_cnt_1 <= timer_cnt_1 + 1;
                end if;
            end if;
        end if;
    end process;

    current_state_processing : process(CLK)
    begin
        if CLK'event and clk = '1' then 
            if RESET = '1' then 
                current_state <= WAIT_ST ;
            else
                
                case current_state is
                    when WAIT_ST =>
                        if timer_empty = '0' then 
                            if timer_dout = timer_cnt_1 then 
                                current_state <= READ_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when READ_ST =>
                        if data_dout(DW+(DW/8)) = '1' then 
                            if timer_dout = timer_cnt_1  then 
                                current_state <= current_state;
                            else
                                current_state <= WAIT_ST;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when others =>
                        current_state <= current_state;
                end case;

            end if;
        end if; 
    end process;

    first_flaq_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                first_flaq <= '1';
            else
                if S_AXIS_TVALID = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        first_flaq <= '1';
                    else
                        first_flaq <= '0';
                    end if;
                else
                    first_flaq <= first_flaq;
                end if;
            end if;
        end if;
    end process;

------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_data_delayer component instantiate <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

    fifo_in_sync_xpm_inst : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DW                                  ,
            MEMTYPE         =>  MEMTYPE                             ,
            DEPTH           =>  MAX_PKT_SIZE                           
        )
        port map (
            CLK             =>  CLK                                 ,
            RESET           =>  RESET                               ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA                        ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP                        ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID                       ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST                        ,
            S_AXIS_TREADY   =>  s_axis_tready                           ,

            IN_DOUT_DATA    =>  data_dout(DW-1 downto 0 )           ,
            IN_DOUT_KEEP    =>  data_dout(((DW/8)+DW)-1 downto DW)  ,
            IN_DOUT_LAST    =>  data_dout((DW/8)+DW)                ,
            IN_RDEN         =>  data_rden                           ,
            IN_EMPTY        =>  data_empty                          
        );

    data_rden <= allow_data_rden ;

    allow_data_rden_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                allow_data_rden <= '0';
            else
                case current_state is
                    when WAIT_ST =>
                        if timer_empty = '0' then 
                            if timer_cnt_1 = timer_dout then 
                                allow_data_rden <= '1';
                            else
                                allow_data_rden <= '0';
                            end if;
                        else
                            allow_data_rden <= '0';
                        end if;

                    when READ_ST =>
                        if data_dout((DW/8)+DW) = '1' then 
                            if timer_cnt_1 = timer_dout then 
                                allow_data_rden <= '1';
                            else
                                allow_data_rden <= '0';
                            end if;
                        else
                            allow_data_rden <= '1';        
                        end if;    

                    when others =>
                        allow_data_rden <= '0';
                end case;
            end if;
        end if;
    end process;

------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_cmd_sync_xpm component instantiate <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

    fifo_cmd_sync_xpm_inst : fifo_cmd_sync_xpm
        generic map (
            DATA_WIDTH      =>  64              ,
            MEMTYPE         =>  MEMTYPE         ,
            DEPTH           =>  MAX_PKT_SIZE               
        )
        port map (
            CLK             =>  CLK             ,
            RESET           =>  RESET           ,
            DIN             =>  timer_din       ,
            WREN            =>  timer_wren      ,
            RDEN            =>  timer_rden      ,
            DOUT            =>  timer_dout      ,
            FULL            =>  timer_full      ,
            EMPTY           =>  timer_empty      
        );

    timer_din_processing : process(CLK)
    begin
        if CLK'event and CLK = '1' then 
            if RESET = '1' then 
                timer_din <= (others => '0') ;
            else
                if S_AXIS_TVALID = '1' then 
                    if first_flaq = '1' then 
                        timer_din <= timer_cnt_0;
                    else
                        timer_din <= timer_din;
                    end if;
                else
                    timer_din <= timer_din;
                end if;
            end if;
        end if;
    end process;

    timer_wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                timer_wren <= '0';
            else
                if S_AXIS_TVALID = '1' then 
                    if first_flaq = '1' then 
                        timer_wren <= '1';
                    else
                        timer_wren <= '0';
                    end if;
                else
                    timer_wren <= '0';
                end if;
            end if;
        end if;
    end process;

    timer_rden_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                timer_rden <= '0';
            else

                case current_state is
                    when WAIT_ST | READ_ST =>
                        if timer_empty = '0' then 
                            if timer_cnt_1 = timer_dout then 
                                timer_rden <= '1';
                            else
                                timer_rden <= '0';
                            end if;
                        else
                            timer_rden <= '0';
                        end if;

                    when others =>
                        timer_rden <= '0';

                end case;
            end if;
        end if;
    end process;



end axis_data_delayer_arch;
