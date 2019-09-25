library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


package axis_loader_ss_pkg is
        
    component axis_loader_ss
        generic(
            WAIT_ABORT_LIMIT    :           integer := 100000000                                ;
            ASYNC_MODE          :           boolean := true                                     
        );
        port(
            
            CLK                 :   in      std_logic                                           ;
            RESET               :   in      std_logic                                           ;
            CLK_SS              :   in      std_logic                                           ;
            
            PROG_DONE           :   in      std_logic                                           ;
            -- CLK clock Domain 
            S_AXIS_TDATA        :   in      std_logic_Vector ( 15 downto 0 )                    ;
            S_AXIS_TKEEP        :   in      std_logic_Vector (  1 downto 0 )                    ;
            S_AXIS_TVALID       :   in      std_logic                                           ;
            S_AXIS_TLAST        :   in      std_logic                                           ;
            S_AXIS_TREADY       :   out     std_logic                                           ;
            -- CLK_SS clock domain
            CCLK                :   out     std_logic                                           ;
            DIN                 :   out     std_logic                                           ;
            DONE                :   in      std_logic                                           ;
            INIT_B              :   in      std_logic                                           ;
            PROG_B              :   out     std_logic                                            

        );
    end component;
end package ;


library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;


entity axis_loader_ss is
    generic(
        WAIT_ABORT_LIMIT    :           integer := 100000000                                ; 
        ASYNC_MODE          :           boolean := true                                     
    );
    port(
        
        CLK                 :   in      std_logic                                           ;
        RESET               :   in      std_logic                                           ;
        CLK_SS              :   in      std_logic                                           ;
        
        PROG_DONE           :   in      std_logic                                           ;
        -- CLK clock Domain 
        S_AXIS_TDATA        :   in      std_logic_Vector ( 15 downto 0 )                    ;
        S_AXIS_TKEEP        :   in      std_logic_Vector (  1 downto 0 )                    ;
        S_AXIS_TVALID       :   in      std_logic                                           ;
        S_AXIS_TLAST        :   in      std_logic                                           ;
        S_AXIS_TREADY       :   out     std_logic                                           ;
        -- CLK_SS clock domain
        CCLK                :   out     std_logic                                           ;
        DIN                 :   out     std_logic                                           ;
        DONE                :   in      std_logic                                           ;
        INIT_B              :   in      std_logic                                           ;
        PROG_B              :   out     std_logic                                            

    );
end axis_loader_ss;



architecture axis_loader_ss_arch of axis_loader_ss is


    
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    constant version : string := "v1.0" ;

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

    component fifo_in_sync_xpm is
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

    signal  in_dout_data    :           std_logic_vector ( 15 downto 0 )                    ;
    signal  in_dout_keep    :           std_logic_Vector (  1 downto 0 )                    ;
    signal  in_dout_last    :           std_logic                                           ;
    signal  r_in_dout_data  :           std_logic_Vector ( 15 downto 0 )                    ;
    signal  in_rden         :           std_logic                                           ;
    signal  in_empty        :           std_logic                                           ;

    type fsm is(
        WAIT_PROG_ST       ,
        RESET_FPGA_ST      ,
        WAIT_FOR_INITB_ST  ,
        PROG_FPGA_ST       ,
        WAIT_DATA_ST       ,
        WAIT_DONE_ST        
    );

    signal current_state : FSM := WAIT_PROG_ST;

    signal  prog_b_reg      :           std_logic                           := '1'          ;
    signal  bit_cnt         :           std_logic_vector ( 3 downto 0 )     := (others => '0')  ;
    signal  clk_ss_sig      :           std_Logic                                               ;
   
    signal  last_flaq       :           std_logic                           := '0'              ;

    signal  wait_abort_cnt  :           std_logic_Vector ( 31 downto  0 )   := (others => '0')  ;


begin


    clk_ss_sig      <=  CLK_SS                                      ;

    CCLK            <=  clk_ss_sig when current_state = PROG_FPGA_ST else '0' ;
    PROG_B          <=  prog_b_reg                                  ;
    DIN             <=  r_in_dout_data(15)                          ;


    ASYNC_GEN_ON : if ASYNC_MODE = true generate 
        
        fifo_in_async_xpm_inst : fifo_in_async_xpm
            generic map (
                DATA_WIDTH      =>  16                                  ,
                CDC_SYNC        =>  4                                   ,
                MEMTYPE         =>  "distributed"                       ,
                DEPTH           =>  16                           
            )
            port map (
                S_AXIS_CLK      =>  CLK                                 ,
                S_AXIS_RESET    =>  RESET                               ,
                M_AXIS_CLK      =>  CLK_SS                              ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA( 7 downto 0 ) & S_AXIS_TDATA( 15 downto 8 ) ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP                        ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                        ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY                       ,

                IN_DOUT_DATA    =>  in_dout_data                        ,
                IN_DOUT_KEEP    =>  in_dout_keep                        ,
                IN_DOUT_LAST    =>  in_dout_last                        ,
                IN_RDEN         =>  in_rden                             ,
                IN_EMPTY        =>  in_empty                            
            );

    end generate;


    ASYNC_GEN_OFF : if ASYNC_MODE = false generate 
            
        fifo_in_sync_xpm_inst : fifo_in_sync_xpm
            generic map (
                DATA_WIDTH      =>  16                                  ,
                MEMTYPE         =>  "distributed"                       ,
                DEPTH           =>  16                                   
            )
            port map (
                CLK             =>  CLK                                 ,
                RESET           =>  RESET                               ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA( 7 downto 0 ) & S_AXIS_TDATA( 15 downto 8 ) ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP                        ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                        ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY                       ,

                IN_DOUT_DATA    =>  in_dout_data                        ,
                IN_DOUT_KEEP    =>  in_dout_keep                        ,
                IN_DOUT_LAST    =>  in_dout_last                        ,
                IN_RDEN         =>  in_rden                             ,
                IN_EMPTY        =>  in_empty                            
            );


    end generate;

    wait_abort_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                wait_abort_cnt <= (others => '0');
            else
                case current_state is
                    when WAIT_DONE_ST =>
                        wait_abort_cnt <= wait_abort_cnt + 1;
                    when others =>
                        wait_abort_cnt <= (others => '0')   ;
                end case;
            end if;
        end if;
    end process;

    current_state_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                current_state <= WAIT_PROG_ST;
            else
                case current_state is
                    when WAIT_PROG_ST =>
                        if (in_empty = '0') then 
                            current_state <= RESET_FPGA_ST;
                        else
                            current_state <= current_state;
                        end if; 

                    when RESET_FPGA_ST =>
                        if INIT_B = '0' then 
                            current_state <= WAIT_FOR_INITB_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when WAIT_FOR_INITB_ST =>
                        if INIT_B = '1' then 
                            current_state <= PROG_FPGA_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when PROG_FPGA_ST =>
                        if bit_cnt = x"F" then 
                            if PROG_DONE = '1' then 
                                current_state <= WAIT_DONE_ST;
                            elsif in_empty = '0' then 
                                current_state <= current_state;
                            else
                                current_state <= WAIT_DATA_ST;    
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when WAIT_DATA_ST =>
                        if PROG_DONE = '1' then 
                            current_state <= WAIT_DONE_ST;
                        elsif in_empty = '0' then 
                            current_state <= PROG_FPGA_ST;
                        else
                            current_state <= current_state;    
                        end if;

                    when WAIT_DONE_ST =>
                        if DONE = '1' then 
                            current_state <= WAIT_PROG_ST;
                        else
                            if wait_abort_cnt = WAIT_ABORT_LIMIT then 
                                current_state <= WAIT_PROG_ST;    
                            else
                                current_state <= current_state;   
                            end if;
                        end if;

                    when others =>
                        current_state <= current_state;
                        
                end case;   
            end if;
        end if;
    end process;    

    prog_b_reg_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                prog_b_reg <= '1';
            else
                case current_state is
                    when RESET_FPGA_ST =>
                        prog_b_reg <= '0';

                    when others =>
                        prog_b_reg <= '1';
                end case;
            end if;
        end if;
    end process;

    in_rden_processing : process(CLK_SS)
    begin 
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                in_rden <= '0';
            else
                case current_state is
                    when PROG_FPGA_ST =>
                        if bit_cnt = x"D" then 
                            in_rden <= '1';
                        else
                            in_rden <= '0';
                        end if;

                    when others => 
                        in_rden <= '0';
                end case;
            end if;
        end if;
    end process;

    bit_cnt_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                bit_cnt <= (others => '0');
            else
                case current_state is
                    when PROG_FPGA_ST =>
                        if in_empty = '0' then 
                            bit_cnt <= bit_cnt + 1;
                        else
                            bit_cnt <= (others => '0');
                        end if;

                    when others =>
                        bit_cnt <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    r_in_dout_data_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                r_in_dout_data <= (others => '0');
            else
                
                case current_state is
                    when WAIT_FOR_INITB_ST | WAIT_DATA_ST =>
                        r_in_dout_data <= in_dout_data( 15 downto 0 );

                    when PROG_FPGA_ST =>
                        if bit_cnt = x"F" then 
                            r_in_dout_data <= in_dout_data(15 downto 0 );
                        else                    
                            r_in_dout_data <= r_in_dout_data( 14 downto 0 ) & r_in_dout_data(15);
                        end if;                
                    when others =>
                        r_in_dout_data <= r_in_dout_data;
                end case;
            end if;
        end if;
    end process;

end axis_loader_ss_arch;
