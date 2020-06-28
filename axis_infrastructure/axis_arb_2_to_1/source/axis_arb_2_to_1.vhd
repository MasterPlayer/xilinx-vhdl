library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;



entity axis_arb_2_to_1 is
    generic(
        N_BYTES             :           integer                           := 2               
    );
    port(
        CLK                 :   in      std_logic                                           ;
        RESET               :   in      std_logic                                           ;

        S00_AXIS_TDATA      :   in      std_logic_vector ( (N_BYTES*8)-1 downto 0 )         ;
        S00_AXIS_TKEEP      :   in      std_logic_vector ( (N_BYTES-1) downto 0 )           ;
        S00_AXIS_TVALID     :   in      std_logic                                           ;
        S00_AXIS_TREADY     :   out     std_logic                                           ;
        S00_AXIS_TLAST      :   in      std_logic                                           ;

        S01_AXIS_TDATA      :   in      std_logic_vector ( (N_BYTES*8)-1 downto 0 )         ;
        S01_AXIS_TKEEP      :   in      std_logic_vector ( (N_BYTES-1) downto 0 )           ;
        S01_AXIS_TVALID     :   in      std_logic                                           ;
        S01_AXIS_TREADY     :   out     std_logic                                           ;
        S01_AXIS_TLAST      :   in      std_logic                                           ;

        M_AXIS_TDATA        :   out     std_logic_vector ( (N_BYTES*8)-1 downto 0 )         ;
        M_AXIS_TKEEP        :   out     std_logic_vector ( (N_BYTES-1) downto 0 )           ;
        M_AXIS_TVALID       :   out     std_logic                                           ;
        M_AXIS_TREADY       :   in      std_logic                                           ;
        M_AXIS_TLAST        :   out     std_logic                                            
    );
end axis_arb_2_to_1;



architecture axis_arb_2_to_1_arch of axis_arb_2_to_1 is

    constant VERSION : string := "v1.0";
    
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    constant DATA_WIDTH     :           integer := N_BYTES*8;

------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_out_xpm declaration <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

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

    signal  out_din_data    :           std_logic_vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')  ;
    signal  out_din_keep    :           std_logic_vector ( ( DATA_WIDTH/8)-1 downto 0 ) := (others => '0')  ;
    signal  out_din_last    :           std_logic                                       := '0'              ;
    signal  out_wren        :           std_logic                                       := '0'              ;
    signal  out_full        :           std_logic                                                           ;
    signal  out_awfull      :           std_logic                                                           ;

    signal  s00_ready       :           std_logic                                       := '0'              ;
    signal  s01_ready       :           std_logic                                       := '0'              ;
    
    type FSM is (
        CH0_CHECK       , 
        CH0_TX          , 
        CH1_CHECK       , 
        CH1_TX          
    );

    signal current_state    :           fsm                                             := CH0_CHECK        ;

begin

    s00_ready <= not ( out_awfull ) when current_state = CH0_TX else '0' ;
    s01_ready <= not ( out_awfull ) when current_state = CH1_TX else '0' ;

    S00_AXIS_TREADY <= s00_ready;
    S01_AXIS_TREADY <= s01_ready;
    
    fsm_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 

                current_state <= CH0_CHECK ;
            
            else
                
                case current_state is
                    
                    when CH0_CHECK => 
                        if S00_AXIS_TVALID = '1' then 
                            current_state <= CH0_TX;
                        else
                            current_state <= CH1_CHECK;
                        end if;

                    when CH0_TX => 
                        if out_awfull = '0' then 
                            if S00_AXIS_TVALID = '1' then 
                                if S00_AXIS_TLAST = '1' then 
                                    current_state <= CH1_CHECK;
                                else
                                    current_state <= current_state;
                                end if;
                            else
                                current_state <= current_state;    
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CH1_CHECK => 
                        if S01_AXIS_TVALID = '1' then 
                            current_state <= CH1_TX;
                        else
                            current_state <= CH0_CHECK;
                        end if;
               
                    when CH1_TX => 
                        if out_awfull = '0' then 
                            if S01_AXIS_TVALID = '1' then 
                                if S01_AXIS_TLAST = '1' then 
                                    current_state <= CH0_CHECK;
                                else
                                    current_state <= current_state;
                                end if;
                            else
                                current_state <= current_state;    
                            end if;
                        else
                            current_state <= current_state;    
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

------------------------------------------------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fifo_arb_x256_reduced_keep instantiate <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --
------------------------------------------------------------------------------------------------------------------------

    fifo_out_sync_xpm_inst : fifo_out_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                          ,
            MEMTYPE         =>  "distributed"                       ,
            DEPTH           =>  16                                   
        )
        port map (
            CLK             =>  CLK                                 ,
            RESET           =>  RESET                               ,
            OUT_DIN_DATA    =>  OUT_DIN_DATA                        ,
            OUT_DIN_KEEP    =>  OUT_DIN_KEEP                        ,
            OUT_DIN_LAST    =>  OUT_DIN_LAST                        ,
            OUT_WREN        =>  OUT_WREN                            ,
            OUT_FULL        =>  OUT_FULL                            ,
            OUT_AWFULL      =>  OUT_AWFULL                          ,
            M_AXIS_TDATA    =>  M_AXIS_TDATA                        ,
            M_AXIS_TKEEP    =>  M_AXIS_TKEEP                        ,
            M_AXIS_TVALID   =>  M_AXIS_TVALID                       ,
            M_AXIS_TLAST    =>  M_AXIS_TLAST                        ,
            M_AXIS_TREADY   =>  M_AXIS_TREADY                        
        );

    out_wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                out_wren <= '0';
            else
                case current_state is 
                    when CH0_TX =>
                        out_wren <= S00_AXIS_TVALID and s00_ready;

                    when CH1_TX =>
                        out_wren <= S01_AXIS_TVALID and s01_ready;

                    when others =>
                        out_wren <= '0';

                end case;
            end if;
        end if;
    end process;

    out_din_data_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when CH0_TX =>
                    OUT_DIN_DATA <= S00_AXIS_TDATA;
                when CH1_TX =>
                    OUT_DIN_DATA <= S01_AXIS_TDATA;
                when others => 
                    OUT_DIN_DATA <= OUT_DIN_DATA;
            end case;
        end if;
    end process;

    out_din_keep_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when CH0_TX =>
                    OUT_DIN_KEEP <= S00_AXIS_TKEEP;
                when CH1_TX =>
                    OUT_DIN_KEEP <= S01_AXIS_TKEEP;
                when others => 
                    OUT_DIN_KEEP <= OUT_DIN_KEEP;
            end case;
        end if;
    end process;

    out_din_last_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when CH0_TX =>
                    OUT_DIN_LAST <= S00_AXIS_TLAST;
                when CH1_TX =>
                    OUT_DIN_LAST <= S01_AXIS_TLAST;
                when others => 
                    OUT_DIN_LAST <= OUT_DIN_LAST;
            end case;
        end if;
    end process;



end axis_arb_2_to_1_arch;
