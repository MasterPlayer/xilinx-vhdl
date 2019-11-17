library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


library UNISIM;
    use UNISIM.VComponents.all;



entity axis_dump_gen is
    generic(
        N_BYTES                 :           integer                         := 2                ;
        ASYNC                   :           boolean                         := false              
    );
    port(
        CLK                     :   in      std_logic                                           ;
        RESET                   :   in      std_logic                                           ;
        
        ENABLE                  :   in      std_logic                                           ;
        PAUSE                   :   in      std_logic_Vector ( 31 downto 0 )                    ;
        WORD_LIMIT              :   in      std_logic_Vector ( 31 downto 0 )                    ;
        
        M_AXIS_CLK              :   in      std_logic                                           ;
        M_AXIS_TDATA            :   out     std_logic_Vector ( (N_BYTES*8)-1 downto 0 )         ;
        M_AXIS_TKEEP            :   out     std_logic_Vector ( N_BYTES-1 downto 0 )             ;
        M_AXIS_TVALID           :   out     std_logic                                           ;
        M_AXIS_TREADY           :   in      std_logic                                           ;
        M_AXIS_TLAST            :   out     std_logic                                            
    );
end axis_dump_gen;



architecture axis_dump_gen_arch of axis_dump_gen is
    
    constant VERSION : string := "v1.0";
    
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    constant    DATA_WIDTH      :           integer                             := (N_BYTES * 8);

    type fsm is (
        IDLE_ST                 ,
        PAUSE_ST                ,
        TX_ST                   
    );
    
    signal  current_state       :           fsm                                 := IDLE_ST          ;
    
    signal  pause_cnt           :           std_logic_Vector (  31 downto 0 )   := (others => '0')  ;
    signal  pause_reg           :           std_logic_Vector (  31 downto 0 )   := (others => '0')  ;

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

    component fifo_out_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  256                         ;
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

    signal  out_din_data        :           std_logic_vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')      ;
    signal  out_din_keep        :           std_logic_vector ( ( DATA_WIDTH/8)-1 downto 0 ) := (others => '0')      ;
    signal  out_din_last        :           std_logic                                       := '0'                  ;
    signal  out_wren            :           std_logic                                       := '0'                  ;
    signal  out_full            :           std_logic                                                               ;
    signal  out_awfull          :           std_logic                                                               ;

    signal  word_cnt            :           std_logic_vector (  15 downto 0 )   := (others => '0')  ;
    signal  cnt_vector          :           std_logic_Vector ( DATA_WIDTH-1 downto 0 ) := (others => '0');

begin

    pause_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                pause_reg <= (others => '0');
            else
                case current_state is 
                    
                    when IDLE_ST =>
                        pause_reg <= PAUSE;
                    
                    when others => 
                        pause_reg <= pause_reg;

                end case;
            end if;
        end if;
    end process;

    pause_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                pause_cnt <= (others => '0');
            else
                
                case( current_state ) is
                
                    when PAUSE_ST =>
                        pause_cnt <= pause_cnt + 1;

                    when others =>  
                        pause_cnt <= (others => '0');
                
                end case ;
            end if;
        end if;
    end process;

    current_state_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                current_state <= IDLE_ST;
            else
                case current_state is
                    when IDLE_ST =>
                        if ENABLE = '1' then 
                            if out_awfull = '0' then 
                                current_state <= PAUSE_ST;
                            else
                                current_state <= current_state;    
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when PAUSE_ST =>
                        if pause_cnt = pause_reg then 
                            current_state <= TX_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_ST =>
                        if out_awfull = '0' then 
                            if word_cnt = WORD_LIMIT then 
                                current_state <= IDLE_ST;
                            else
                                current_state <= current_state;
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

    word_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                word_cnt <= (others => '0');
            else
                
                case current_state is
                    when TX_ST =>
                        if out_awfull = '0' then 
                            word_cnt <= word_cnt + 1;
                        else
                            word_cnt <= word_cnt;
                        end if;

                    when others =>
                        word_cnt <= (others => '0');

                end case;
            end if;
        end if;
    end process;

    GEN_ASYNC : if ASYNC = true generate 

        fifo_out_async_xpm_inst : fifo_out_async_xpm
            generic map (
                DATA_WIDTH      =>  DATA_WIDTH                                      ,
                CDC_SYNC        =>  4                                               ,
                MEMTYPE         =>  "distributed"                                   ,
                DEPTH           =>  16                                               
            )
            port map (
                CLK             =>  CLK                                             ,
                RESET           =>  RESET                                           ,
                
                OUT_DIN_DATA    =>  out_din_data                                    ,
                OUT_DIN_KEEP    =>  out_din_keep                                    ,
                OUT_DIN_LAST    =>  out_din_last                                    ,
                OUT_WREN        =>  out_wren                                        ,
                OUT_FULL        =>  out_full                                        ,
                OUT_AWFULL      =>  out_awfull                                      ,

                M_AXIS_CLK      =>  M_AXIS_CLK                                      ,
                M_AXIS_TDATA    =>  M_AXIS_TDATA                                    ,
                M_AXIS_TKEEP    =>  M_AXIS_TKEEP                                    ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID                                   ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST                                    ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY                                    
            );

    end generate;

    GEN_SYNC : if ASYNC = false generate 

        fifo_out_sync_xpm_inst : fifo_out_sync_xpm
            generic map (
                DATA_WIDTH      =>  DATA_WIDTH                                      ,
                MEMTYPE         =>  "distributed"                                   ,
                DEPTH           =>  16                                               
            )
            port map (
                CLK             =>  CLK                                             ,
                RESET           =>  RESET                                           ,
                
                OUT_DIN_DATA    =>  out_din_data                                    ,
                OUT_DIN_KEEP    =>  out_din_keep                                    ,
                OUT_DIN_LAST    =>  out_din_last                                    ,
                OUT_WREN        =>  out_wren                                        ,
                OUT_FULL        =>  out_full                                        ,
                OUT_AWFULL      =>  out_awfull                                      ,

                M_AXIS_TDATA    =>  M_AXIS_TDATA                                    ,
                M_AXIS_TKEEP    =>  M_AXIS_TKEEP                                    ,
                M_AXIS_TVALID   =>  M_AXIS_TVALID                                   ,
                M_AXIS_TLAST    =>  M_AXIS_TLAST                                    ,
                M_AXIS_TREADY   =>  M_AXIS_TREADY                                    
            );

    end generate;

    wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                out_wren <= '0';    
            else
                case current_state is
                    when TX_ST =>
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

    out_din_data <= cnt_vector;
    out_din_keep <= (others => '1') ;

    last_field_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                out_din_last <= '0';
            else                
                case current_state is
                    when TX_ST =>
                        case conv_integer(word_cnt) is
                            when 255        => out_din_last <= '1';
                            when others     => out_din_last <= '0';
                        end case;
                        
                    when others =>
                        out_din_last <= out_din_last;

                end case;
            end if;
        end if;
    end process;

    gen_vector_cnt : for i in 0 to N_BYTES-1 generate 
        cnt_vector_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    cnt_vector( (((i+1)*8)-1) downto  (i*8)) <= conv_std_logic_Vector( ((256 - N_BYTES) + i) , 8);
                else
                    case current_state is
                        when TX_ST =>
                            if out_awfull = '0' then 
                                cnt_vector((((i+1)*8)-1) downto  (i*8)) <= cnt_vector((((i+1)*8)-1) downto  (i*8)) + conv_std_logic_Vector(N_BYTES, 8);
                            else
                                cnt_vector((((i+1)*8)-1) downto  (i*8)) <= cnt_vector((((i+1)*8)-1) downto  (i*8));
                            end if;
                        when others =>
                            cnt_vector((((i+1)*8)-1) downto  (i*8)) <= cnt_vector((((i+1)*8)-1) downto  (i*8));
                    end case;
                end if;
            end if;
        end process;
    end generate;



end axis_dump_gen_arch;
