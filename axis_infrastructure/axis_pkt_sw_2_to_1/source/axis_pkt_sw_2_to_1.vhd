library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library unisim;
    use unisim.vcomponents.all;


entity axis_pkt_sw_2_to_1 is
    generic(
        N_BYTES             :           integer := 8                                            ;
        FIFO_TYPE_DATA      :           string  := "block"                                      ;
        FIFO_TYPE_PKT       :           string  := "distributed"                                ;
        DATA_DEPTH_0        :           integer := 1024                                         ;
        DATA_DEPTH_1        :           integer := 1024                                         ;
        PKT_DEPTH_0         :           integer := 16                                           ;
        PKT_DEPTH_1         :           integer := 16                                            
    );
    port(
        CLK                 :   in      std_logic                                               ;
        RESET               :   in      std_Logic                                               ;
        
        S_AXIS_TDATA_0      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_0      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_0     :   in      std_logic                                               ;
        S_AXIS_TLAST_0      :   in      std_logic                                               ;
        S_AXIS_TREADY_0     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_1      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_1      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_1     :   in      std_logic                                               ;
        S_AXIS_TLAST_1      :   in      std_logic                                               ;
        S_AXIS_TREADY_1     :   out     std_logic                                               ;
                
        M_AXIS_TDATA        :   out     std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        M_AXIS_TKEEP        :   out     std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        M_AXIS_TVALID       :   out     std_logic                                               ;
        M_AXIS_TLAST        :   out     std_logic                                               ;
        M_AXIS_TREADY       :   in      std_Logic                                               
    );
end axis_pkt_sw_2_to_1;



architecture axis_pkt_sw_2_to_1_arch  of axis_pkt_sw_2_to_1 is

    constant VERSION : string := "v1.0";
    
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    constant  DATA_WIDTH    :           integer                         := (N_BYTES * 8) ;

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

    signal  in_dout_data_0  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_0  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_0  :           std_logic                                               ;
    signal  in_rden_0       :           std_logic                                       := '0'  ;
    signal  in_empty_0      :           std_logic                                               ;

    signal  in_dout_data_1  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_1  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_1  :           std_logic                                               ;
    signal  in_rden_1       :           std_logic                                       := '0'  ;
    signal  in_empty_1      :           std_logic                                               ;


    component fifo_in_pkt_xpm
        generic(
            MEMTYPE         :           string          :=  "distributed"               ;
            DEPTH           :           integer         :=  16                        
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            S_AXIS_TVALID   :   in      std_logic                                       ;
            S_AXIS_TLAST    :   in      std_logic                                       ;
            IN_RDEN         :   in      std_logic                                       ;
            IN_EMPTY        :   out     std_logic                                   
        );
    end component;

    signal  in_rden_pkt_0   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_0  :           std_logic                                               ;
    signal  in_rden_pkt_1   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_1  :           std_logic                                               ;



    type fsm is(
        CHK_0_ST    ,
        TX_0_ST     ,
        CHK_1_ST    ,
        TX_1_ST     
    );

    signal  current_state   :           fsm                 := CHK_0_ST;


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

    signal  out_din_data    :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')      ;
    signal  out_din_keep    :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) := (others => '0')      ;
    signal  out_din_last    :           std_logic                                       := '0'                  ;
    signal  out_wren        :           std_logic                                       := '0'                  ;
    signal  out_full        :           std_logic                                                               ;
    signal  out_awfull      :           std_logic                                                               ;

begin

    current_state_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                current_state <= CHK_0_ST ;
            else
                case current_state is
                    when CHK_0_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_0 = '0' then 
                                current_state <= TX_0_ST;
                            else
                                current_state <= CHK_1_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_1_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_1 = '0' then 
                                current_state <= TX_1_ST;
                            else
                                current_state <= CHK_0_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when TX_0_ST =>
                        if out_awfull = '0' then 
                            if in_dout_last_0 = '1' then 
                                current_state <= CHK_1_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_1_ST =>
                        if out_awfull = '0' then 
                            if in_dout_last_1 = '1' then 
                                current_state <= CHK_0_ST;
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

    in_rden_pkt_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_0 <= '0';
            else
                case current_state is
                    when CHK_0_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_0 = '0' then 
                                in_rden_pkt_0 <= '1';
                            else
                                in_rden_pkt_0 <= '0';
                            end if;
                        else
                            in_rden_pkt_0 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_0 <= '0';
                end case;
            end if;
        end if;
    end process;

    in_rden_pkt_1_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_1 <= '0';
            else
                case current_state is
                    when CHK_1_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_1 = '0' then 
                                in_rden_pkt_1 <= '1';
                            else
                                in_rden_pkt_1 <= '0';
                            end if;
                        else
                            in_rden_pkt_1 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_1 <= '0';
                end case;
            end if;
        end if;
    end process;

    out_din_data_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when TX_0_ST => 
                    if in_rden_0 = '1' then 
                        out_din_data <= in_dout_data_0;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_1_ST =>
                    if in_rden_1 = '1' then 
                        out_din_data <= in_dout_data_1;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when others => 
                    out_din_data <= out_din_data;
            end case;
        end if;
    end process;

    out_din_keep_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when TX_0_ST => 
                    if in_rden_0 = '1' then 
                        out_din_keep <= in_dout_keep_0;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_1_ST =>
                    if in_rden_1 = '1' then 
                        out_din_keep <= in_dout_keep_1;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when others => 
                    out_din_keep <= out_din_keep;
            end case;
        end if;
    end process;

    out_din_last_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when TX_0_ST => 
                    if in_rden_0 = '1' then
                        out_din_last <= in_dout_last_0;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_1_ST => 
                    if in_rden_1 = '1' then
                        out_din_last <= in_dout_last_1;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when others => 
                    out_din_last <= out_din_last;
            end case;
        end if;
    end process;

    out_wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when TX_0_ST => 
                    if in_empty_0 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_1_ST => 
                    if in_empty_1 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when others  => 
                    out_wren <= '0';

            end case;
        end if;
    end process;

    fifo_in_sync_xpm_inst_0 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_0                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_0              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_0              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_0             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_0              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_0             ,

            IN_DOUT_DATA    =>  in_dout_data_0              ,
            IN_DOUT_KEEP    =>  in_dout_keep_0              ,
            IN_DOUT_LAST    =>  in_dout_last_0              ,
            IN_RDEN         =>  in_rden_0                   ,
            IN_EMPTY        =>  in_empty_0                   
        );

    fifo_in_pkt_xpm_inst_0 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_0                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_0         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_0          ,
            IN_RDEN         =>  IN_RDEN_PKT_0           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_0           
        );

    fifo_in_sync_xpm_inst_1 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_1                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_1              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_1              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_1             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_1              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_1             ,

            IN_DOUT_DATA    =>  in_dout_data_1              ,
            IN_DOUT_KEEP    =>  in_dout_keep_1              ,
            IN_DOUT_LAST    =>  in_dout_last_1              ,
            IN_RDEN         =>  in_rden_1                   ,
            IN_EMPTY        =>  in_empty_1                   
        );

    fifo_in_pkt_xpm_inst_1 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_1                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_1         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_1          ,
            IN_RDEN         =>  IN_RDEN_PKT_1           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_1           
        );

    fifo_out_sync_xpm_inst : fifo_out_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  "distributed"               ,
            DEPTH           =>  16                           
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            OUT_DIN_DATA    =>  out_din_data                ,
            OUT_DIN_KEEP    =>  out_din_keep                ,
            OUT_DIN_LAST    =>  out_din_last                ,
            OUT_WREN        =>  out_wren                    ,
            OUT_FULL        =>  out_full                    ,
            OUT_AWFULL      =>  out_awfull                  ,
            M_AXIS_TDATA    =>  M_AXIS_TDATA                ,
            M_AXIS_TKEEP    =>  M_AXIS_TKEEP                ,
            M_AXIS_TVALID   =>  M_AXIS_TVALID               ,
            M_AXIS_TLAST    =>  M_AXIS_TLAST                ,
            M_AXIS_TREADY   =>  M_AXIS_TREADY                
        );

    in_rden_0 <= '1' when current_state = TX_0_ST and out_awfull = '0' else '0';
    in_rden_1 <= '1' when current_state = TX_1_ST and out_awfull = '0' else '0';


end axis_pkt_sw_2_to_1_arch;
