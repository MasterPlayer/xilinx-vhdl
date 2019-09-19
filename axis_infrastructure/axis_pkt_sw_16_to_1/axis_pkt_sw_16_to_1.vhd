library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library unisim;
    use unisim.vcomponents.all;


entity axis_pkt_sw_16_to_1 is
    generic(
        N_BYTES             :           integer := 8                                            ;
        FIFO_TYPE_DATA      :           string  := "block"                                      ;
        FIFO_TYPE_PKT       :           string  := "distributed"                                ;
        DATA_DEPTH_0        :           integer := 1024                                         ;
        DATA_DEPTH_1        :           integer := 1024                                         ;
        DATA_DEPTH_2        :           integer := 1024                                         ;
        DATA_DEPTH_3        :           integer := 1024                                         ;
        DATA_DEPTH_4        :           integer := 1024                                         ;
        DATA_DEPTH_5        :           integer := 1024                                         ;
        DATA_DEPTH_6        :           integer := 1024                                         ;
        DATA_DEPTH_7        :           integer := 1024                                         ;
        DATA_DEPTH_8        :           integer := 1024                                         ;
        DATA_DEPTH_9        :           integer := 1024                                         ;
        DATA_DEPTH_A        :           integer := 1024                                         ;
        DATA_DEPTH_B        :           integer := 1024                                         ;
        DATA_DEPTH_C        :           integer := 1024                                         ;
        DATA_DEPTH_D        :           integer := 1024                                         ;
        DATA_DEPTH_E        :           integer := 1024                                         ;
        DATA_DEPTH_F        :           integer := 1024                                         ;
        PKT_DEPTH_0         :           integer := 16                                           ;
        PKT_DEPTH_1         :           integer := 16                                           ;
        PKT_DEPTH_2         :           integer := 16                                           ;
        PKT_DEPTH_3         :           integer := 16                                           ;
        PKT_DEPTH_4         :           integer := 16                                           ;
        PKT_DEPTH_5         :           integer := 16                                           ;
        PKT_DEPTH_6         :           integer := 16                                           ;
        PKT_DEPTH_7         :           integer := 16                                           ;
        PKT_DEPTH_8         :           integer := 16                                           ;
        PKT_DEPTH_9         :           integer := 16                                           ;
        PKT_DEPTH_A         :           integer := 16                                           ;
        PKT_DEPTH_B         :           integer := 16                                           ;
        PKT_DEPTH_C         :           integer := 16                                           ;
        PKT_DEPTH_D         :           integer := 16                                           ;
        PKT_DEPTH_E         :           integer := 16                                           ;
        PKT_DEPTH_F         :           integer := 16                                            
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
        
        S_AXIS_TDATA_2      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_2      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_2     :   in      std_logic                                               ;
        S_AXIS_TLAST_2      :   in      std_logic                                               ;
        S_AXIS_TREADY_2     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_3      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_3      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_3     :   in      std_logic                                               ;
        S_AXIS_TLAST_3      :   in      std_logic                                               ;
        S_AXIS_TREADY_3     :   out     std_logic                                               ;

        S_AXIS_TDATA_4      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_4      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_4     :   in      std_logic                                               ;
        S_AXIS_TLAST_4      :   in      std_logic                                               ;
        S_AXIS_TREADY_4     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_5      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_5      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_5     :   in      std_logic                                               ;
        S_AXIS_TLAST_5      :   in      std_logic                                               ;
        S_AXIS_TREADY_5     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_6      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_6      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_6     :   in      std_logic                                               ;
        S_AXIS_TLAST_6      :   in      std_logic                                               ;
        S_AXIS_TREADY_6     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_7      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_7      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_7     :   in      std_logic                                               ;
        S_AXIS_TLAST_7      :   in      std_logic                                               ;
        S_AXIS_TREADY_7     :   out     std_logic                                               ;

        S_AXIS_TDATA_8      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_8      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_8     :   in      std_logic                                               ;
        S_AXIS_TLAST_8      :   in      std_logic                                               ;
        S_AXIS_TREADY_8     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_9      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_9      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_9     :   in      std_logic                                               ;
        S_AXIS_TLAST_9      :   in      std_logic                                               ;
        S_AXIS_TREADY_9     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_A      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_A      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_A     :   in      std_logic                                               ;
        S_AXIS_TLAST_A      :   in      std_logic                                               ;
        S_AXIS_TREADY_A     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_B      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_B      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_B     :   in      std_logic                                               ;
        S_AXIS_TLAST_B      :   in      std_logic                                               ;
        S_AXIS_TREADY_B     :   out     std_logic                                               ;

        S_AXIS_TDATA_C      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_C      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_C     :   in      std_logic                                               ;
        S_AXIS_TLAST_C      :   in      std_logic                                               ;
        S_AXIS_TREADY_C     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_D      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_D      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_D     :   in      std_logic                                               ;
        S_AXIS_TLAST_D      :   in      std_logic                                               ;
        S_AXIS_TREADY_D     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_E      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_E      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_E     :   in      std_logic                                               ;
        S_AXIS_TLAST_E      :   in      std_logic                                               ;
        S_AXIS_TREADY_E     :   out     std_logic                                               ;
        
        S_AXIS_TDATA_F      :   in      std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        S_AXIS_TKEEP_F      :   in      std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        S_AXIS_TVALID_F     :   in      std_logic                                               ;
        S_AXIS_TLAST_F      :   in      std_logic                                               ;
        S_AXIS_TREADY_F     :   out     std_logic                                               ;
        
        M_AXIS_TDATA        :   out     std_logic_Vector ((N_BYTES*8)-1 downto 0 )              ;
        M_AXIS_TKEEP        :   out     std_logic_Vector ((N_BYTES-1)   downto 0 )              ;
        M_AXIS_TVALID       :   out     std_logic                                               ;
        M_AXIS_TLAST        :   out     std_logic                                               ;
        M_AXIS_TREADY       :   in      std_Logic                                               
    );
end axis_pkt_sw_16_to_1;



architecture axis_pkt_sw_16_to_1_arch  of axis_pkt_sw_16_to_1 is

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

    signal  in_dout_data_2  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_2  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_2  :           std_logic                                               ;
    signal  in_rden_2       :           std_logic                                       := '0'  ;
    signal  in_empty_2      :           std_logic                                               ;

    signal  in_dout_data_3  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_3  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_3  :           std_logic                                               ;
    signal  in_rden_3       :           std_logic                                       := '0'  ;
    signal  in_empty_3      :           std_logic                                               ;

    signal  in_dout_data_4  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_4  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_4  :           std_logic                                               ;
    signal  in_rden_4       :           std_logic                                       := '0'  ;
    signal  in_empty_4      :           std_logic                                               ;

    signal  in_dout_data_5  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_5  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_5  :           std_logic                                               ;
    signal  in_rden_5       :           std_logic                                       := '0'  ;
    signal  in_empty_5      :           std_logic                                               ;

    signal  in_dout_data_6  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_6  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_6  :           std_logic                                               ;
    signal  in_rden_6       :           std_logic                                       := '0'  ;
    signal  in_empty_6      :           std_logic                                               ;

    signal  in_dout_data_7  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_7  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_7  :           std_logic                                               ;
    signal  in_rden_7       :           std_logic                                       := '0'  ;
    signal  in_empty_7      :           std_logic                                               ;
    
    signal  in_dout_data_8  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_8  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_8  :           std_logic                                               ;
    signal  in_rden_8       :           std_logic                                       := '0'  ;
    signal  in_empty_8      :           std_logic                                               ;

    signal  in_dout_data_9  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_9  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_9  :           std_logic                                               ;
    signal  in_rden_9       :           std_logic                                       := '0'  ;
    signal  in_empty_9      :           std_logic                                               ;

    signal  in_dout_data_A  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_A  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_A  :           std_logic                                               ;
    signal  in_rden_A       :           std_logic                                       := '0'  ;
    signal  in_empty_A      :           std_logic                                               ;

    signal  in_dout_data_B  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_B  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_B  :           std_logic                                               ;
    signal  in_rden_B       :           std_logic                                       := '0'  ;
    signal  in_empty_B      :           std_logic                                               ;

    signal  in_dout_data_C  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_C  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_C  :           std_logic                                               ;
    signal  in_rden_C       :           std_logic                                       := '0'  ;
    signal  in_empty_C      :           std_logic                                               ;

    signal  in_dout_data_D  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_D  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_D  :           std_logic                                               ;
    signal  in_rden_D       :           std_logic                                       := '0'  ;
    signal  in_empty_D      :           std_logic                                               ;

    signal  in_dout_data_E  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_E  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_E  :           std_logic                                               ;
    signal  in_rden_E       :           std_logic                                       := '0'  ;
    signal  in_empty_E      :           std_logic                                               ;

    signal  in_dout_data_F  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
    signal  in_dout_keep_F  :           std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
    signal  in_dout_last_F  :           std_logic                                               ;
    signal  in_rden_F       :           std_logic                                       := '0'  ;
    signal  in_empty_F      :           std_logic                                               ;


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
    signal  in_rden_pkt_2   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_2  :           std_logic                                               ;
    signal  in_rden_pkt_3   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_3  :           std_logic                                               ;
    signal  in_rden_pkt_4   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_4  :           std_logic                                               ;
    signal  in_rden_pkt_5   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_5  :           std_logic                                               ;
    signal  in_rden_pkt_6   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_6  :           std_logic                                               ;
    signal  in_rden_pkt_7   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_7  :           std_logic                                               ;
    signal  in_rden_pkt_8   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_8  :           std_logic                                               ;
    signal  in_rden_pkt_9   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_9  :           std_logic                                               ;
    signal  in_rden_pkt_A   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_A  :           std_logic                                               ;
    signal  in_rden_pkt_B   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_B  :           std_logic                                               ;
    signal  in_rden_pkt_C   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_C  :           std_logic                                               ;
    signal  in_rden_pkt_D   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_D  :           std_logic                                               ;
    signal  in_rden_pkt_E   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_E  :           std_logic                                               ;
    signal  in_rden_pkt_F   :           std_logic                               := '0'          ;
    signal  in_empty_pkt_F  :           std_logic                                               ;

    type fsm is(
        CHK_0_ST    ,
        TX_0_ST     ,
        CHK_1_ST    ,
        TX_1_ST     ,
        CHK_2_ST    ,
        TX_2_ST     ,
        CHK_3_ST    ,
        TX_3_ST     ,
        CHK_4_ST    ,
        TX_4_ST     ,
        CHK_5_ST    ,
        TX_5_ST     ,
        CHK_6_ST    ,
        TX_6_ST     ,
        CHK_7_ST    ,
        TX_7_ST     ,
        CHK_8_ST    ,
        TX_8_ST     ,
        CHK_9_ST    ,
        TX_9_ST     ,
        CHK_A_ST    ,
        TX_A_ST     ,
        CHK_B_ST    ,
        TX_B_ST     ,
        CHK_C_ST    ,
        TX_C_ST     ,
        CHK_D_ST    ,
        TX_D_ST     ,
        CHK_E_ST    ,
        TX_E_ST     ,
        CHK_F_ST    ,
        TX_F_ST      
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
                                current_state <= CHK_2_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_2_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_2 = '0' then 
                                current_state <= TX_2_ST;
                            else
                                current_state <= CHK_3_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_3_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_3 = '0' then 
                                current_state <= TX_3_ST;
                            else
                                current_state <= CHK_4_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_4_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_4 = '0' then 
                                current_state <= TX_4_ST;
                            else
                                current_state <= CHK_5_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_5_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_5 = '0' then 
                                current_state <= TX_5_ST;
                            else
                                current_state <= CHK_6_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_6_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_6 = '0' then 
                                current_state <= TX_6_ST;
                            else
                                current_state <= CHK_7_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;
                    
                    when CHK_7_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_7 = '0' then 
                                current_state <= TX_7_ST;
                            else
                                current_state <= CHK_8_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;
                    
                    when CHK_8_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_8 = '0' then 
                                current_state <= TX_8_ST;
                            else
                                current_state <= CHK_9_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;
                    
                    when CHK_9_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_9 = '0' then 
                                current_state <= TX_9_ST;
                            else
                                current_state <= CHK_A_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;
                    
                    when CHK_A_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_a = '0' then 
                                current_state <= TX_A_ST;
                            else
                                current_state <= CHK_B_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_B_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_b = '0' then 
                                current_state <= TX_B_ST;
                            else
                                current_state <= CHK_C_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_C_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_c = '0' then 
                                current_state <= TX_C_ST;
                            else
                                current_state <= CHK_D_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_D_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_d = '0' then 
                                current_state <= TX_D_ST;
                            else
                                current_state <= CHK_E_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_E_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_e = '0' then 
                                current_state <= TX_E_ST;
                            else
                                current_state <= CHK_F_ST;
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when CHK_F_ST =>
                        if out_awfull = '0' then 
                            if in_empty_pkt_f = '0' then 
                                current_state <= TX_F_ST;
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
                                current_state <= CHK_2_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_2_ST =>
                        if out_awfull = '0' then 
                            if in_dout_last_2 = '1' then 
                                current_state <= CHK_3_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_3_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_3 = '1' then 
                                current_state <= CHK_4_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_4_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_4 = '1' then 
                                current_state <= CHK_5_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_5_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_5 = '1' then 
                                current_state <= CHK_6_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_6_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_6 = '1' then 
                                current_state <= CHK_7_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_7_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_7 = '1' then 
                                current_state <= CHK_8_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_8_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_8 = '1' then 
                                current_state <= CHK_9_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_9_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_9 = '1' then 
                                current_state <= CHK_A_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_A_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_a = '1' then 
                                current_state <= CHK_B_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_B_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_b = '1' then 
                                current_state <= CHK_C_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_C_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_c = '1' then 
                                current_state <= CHK_D_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_D_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_d = '1' then 
                                current_state <= CHK_E_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_E_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_e = '1' then 
                                current_state <= CHK_F_ST;
                            else
                                current_state <= current_state;
                            end if;
                        else
                            current_state <= current_state;
                        end if;

                    when TX_F_ST => 
                        if out_awfull = '0' then 
                            if in_dout_last_f = '1' then 
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

    in_rden_pkt_2_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_2 <= '0';
            else
                case current_state is
                    when CHK_2_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_2 = '0' then 
                                in_rden_pkt_2 <= '1';
                            else
                                in_rden_pkt_2 <= '0';
                            end if;
                        else
                            in_rden_pkt_2 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_2 <= '0';
                end case;
            end if;
        end if;
    end process;

    in_rden_pkt_3_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_3 <= '0';
            else
                case current_state is
                    when CHK_3_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_3 = '0' then 
                                in_rden_pkt_3 <= '1';
                            else
                                in_rden_pkt_3 <= '0';
                            end if;
                        else
                            in_rden_pkt_3 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_3 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_4_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_4 <= '0';
            else
                case current_state is
                    when CHK_4_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_4 = '0' then 
                                in_rden_pkt_4 <= '1';
                            else
                                in_rden_pkt_4 <= '0';
                            end if;
                        else
                            in_rden_pkt_4 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_4 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_5_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_5 <= '0';
            else
                case current_state is
                    when CHK_5_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_5 = '0' then 
                                in_rden_pkt_5 <= '1';
                            else
                                in_rden_pkt_5 <= '0';
                            end if;
                        else
                            in_rden_pkt_5 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_5 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_6_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_6 <= '0';
            else
                case current_state is
                    when CHK_6_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_6 = '0' then 
                                in_rden_pkt_6 <= '1';
                            else
                                in_rden_pkt_6 <= '0';
                            end if;
                        else
                            in_rden_pkt_6 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_6 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_7_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_7 <= '0';
            else
                case current_state is
                    when CHK_7_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_7 = '0' then 
                                in_rden_pkt_7 <= '1';
                            else
                                in_rden_pkt_7 <= '0';
                            end if;
                        else
                            in_rden_pkt_7 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_7 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_8_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_8 <= '0';
            else
                case current_state is
                    when CHK_8_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_8 = '0' then 
                                in_rden_pkt_8 <= '1';
                            else
                                in_rden_pkt_8 <= '0';
                            end if;
                        else
                            in_rden_pkt_8 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_8 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_9_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_9 <= '0';
            else
                case current_state is
                    when CHK_9_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_9 = '0' then 
                                in_rden_pkt_9 <= '1';
                            else
                                in_rden_pkt_9 <= '0';
                            end if;
                        else
                            in_rden_pkt_9 <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_9 <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_A_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_a <= '0';
            else
                case current_state is
                    when CHK_A_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_a = '0' then 
                                in_rden_pkt_a <= '1';
                            else
                                in_rden_pkt_a <= '0';
                            end if;
                        else
                            in_rden_pkt_a <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_a <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_b_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_b <= '0';
            else
                case current_state is
                    when CHK_b_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_b = '0' then 
                                in_rden_pkt_b <= '1';
                            else
                                in_rden_pkt_b <= '0';
                            end if;
                        else
                            in_rden_pkt_b <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_b <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_C_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_c <= '0';
            else
                case current_state is
                    when CHK_C_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_c = '0' then 
                                in_rden_pkt_c <= '1';
                            else
                                in_rden_pkt_c <= '0';
                            end if;
                        else
                            in_rden_pkt_c <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_c <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_D_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_d <= '0';
            else
                case current_state is
                    when CHK_D_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_d = '0' then 
                                in_rden_pkt_d <= '1';
                            else
                                in_rden_pkt_d <= '0';
                            end if;
                        else
                            in_rden_pkt_d <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_d <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_E_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_e <= '0';
            else
                case current_state is
                    when CHK_E_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_e = '0' then 
                                in_rden_pkt_e <= '1';
                            else
                                in_rden_pkt_e <= '0';
                            end if;
                        else
                            in_rden_pkt_e <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_e <= '0';
                end case;
            end if;
        end if;
    end process;


    in_rden_pkt_F_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                in_rden_pkt_f <= '0';
            else
                case current_state is
                    when CHK_F_ST => 
                        if out_awfull = '0' then 
                            if in_empty_pkt_f = '0' then 
                                in_rden_pkt_f <= '1';
                            else
                                in_rden_pkt_f <= '0';
                            end if;
                        else
                            in_rden_pkt_f <= '0';
                        end if;

                    when others =>
                        in_rden_pkt_f <= '0';
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

                when TX_2_ST =>
                    if in_rden_2 = '1' then 
                        out_din_data <= in_dout_data_2;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_3_ST =>
                    if in_rden_3 = '1' then 
                        out_din_data <= in_dout_data_3;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_4_ST =>
                    if in_rden_4 = '1' then 
                        out_din_data <= in_dout_data_4;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_5_ST =>
                    if in_rden_5 = '1' then 
                        out_din_data <= in_dout_data_5;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_6_ST =>
                    if in_rden_6 = '1' then 
                        out_din_data <= in_dout_data_6;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_7_ST =>
                    if in_rden_7 = '1' then 
                        out_din_data <= in_dout_data_7;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_8_ST =>
                    if in_rden_8 = '1' then 
                        out_din_data <= in_dout_data_8;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_9_ST =>
                    if in_rden_9 = '1' then 
                        out_din_data <= in_dout_data_9;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_A_ST =>
                    if in_rden_a = '1' then 
                        out_din_data <= in_dout_data_a;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_B_ST =>
                    if in_rden_b = '1' then 
                        out_din_data <= in_dout_data_b;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_C_ST =>
                    if in_rden_c = '1' then 
                        out_din_data <= in_dout_data_c;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_D_ST =>
                    if in_rden_d = '1' then 
                        out_din_data <= in_dout_data_d;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_E_ST =>
                    if in_rden_e = '1' then 
                        out_din_data <= in_dout_data_e;
                    else
                        out_din_data <= out_din_data;
                    end if;

                when TX_F_ST =>
                    if in_rden_f = '1' then 
                        out_din_data <= in_dout_data_f;
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

                when TX_2_ST =>
                    if in_rden_2 = '1' then 
                        out_din_keep <= in_dout_keep_2;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_3_ST =>
                    if in_rden_3 = '1' then 
                        out_din_keep <= in_dout_keep_3;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_4_ST =>
                    if in_rden_4 = '1' then 
                        out_din_keep <= in_dout_keep_4;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_5_ST =>
                    if in_rden_5 = '1' then 
                        out_din_keep <= in_dout_keep_5;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_6_ST =>
                    if in_rden_6 = '1' then 
                        out_din_keep <= in_dout_keep_6;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_7_ST =>
                    if in_rden_7 = '1' then 
                        out_din_keep <= in_dout_keep_7;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_8_ST =>
                    if in_rden_8 = '1' then 
                        out_din_keep <= in_dout_keep_8;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_9_ST =>
                    if in_rden_9 = '1' then 
                        out_din_keep <= in_dout_keep_9;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_A_ST =>
                    if in_rden_a = '1' then 
                        out_din_keep <= in_dout_keep_a;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_B_ST =>
                    if in_rden_b = '1' then 
                        out_din_keep <= in_dout_keep_b;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_C_ST =>
                    if in_rden_c = '1' then 
                        out_din_keep <= in_dout_keep_c;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_D_ST =>
                    if in_rden_d = '1' then 
                        out_din_keep <= in_dout_keep_d;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_E_ST =>
                    if in_rden_e = '1' then 
                        out_din_keep <= in_dout_keep_e;
                    else
                        out_din_keep <= out_din_keep;
                    end if;

                when TX_F_ST =>
                    if in_rden_f = '1' then 
                        out_din_keep <= in_dout_keep_f;
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

                when TX_2_ST => 
                    if in_rden_2 = '1' then
                        out_din_last <= in_dout_last_2;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_3_ST => 
                    if in_rden_3 = '1' then
                        out_din_last <= in_dout_last_3;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_4_ST => 
                    if in_rden_4 = '1' then
                        out_din_last <= in_dout_last_4;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_5_ST => 
                    if in_rden_5 = '1' then
                        out_din_last <= in_dout_last_5;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_6_ST => 
                    if in_rden_6 = '1' then
                        out_din_last <= in_dout_last_6;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_7_ST => 
                    if in_rden_7 = '1' then
                        out_din_last <= in_dout_last_7;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_8_ST => 
                    if in_rden_8 = '1' then
                        out_din_last <= in_dout_last_8;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_9_ST => 
                    if in_rden_9 = '1' then
                        out_din_last <= in_dout_last_9;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_A_ST => 
                    if in_rden_a = '1' then
                        out_din_last <= in_dout_last_a;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_B_ST => 
                    if in_rden_b = '1' then
                        out_din_last <= in_dout_last_b;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_C_ST => 
                    if in_rden_c = '1' then
                        out_din_last <= in_dout_last_c;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_D_ST => 
                    if in_rden_d = '1' then
                        out_din_last <= in_dout_last_d;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_E_ST => 
                    if in_rden_e = '1' then
                        out_din_last <= in_dout_last_e;
                    else
                        out_din_last <= out_din_last;
                    end if;

                when TX_F_ST => 
                    if in_rden_f = '1' then
                        out_din_last <= in_dout_last_f;
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

                when TX_2_ST => 
                    if in_empty_2 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_3_ST => 
                    if in_empty_3 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_4_ST => 
                    if in_empty_4 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_5_ST => 
                    if in_empty_5 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_6_ST => 
                    if in_empty_6 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_7_ST => 
                    if in_empty_7 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_8_ST => 
                    if in_empty_8 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_9_ST => 
                    if in_empty_9 = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_A_ST => 
                    if in_empty_a = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_B_ST => 
                    if in_empty_b = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_C_ST => 
                    if in_empty_c = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_D_ST => 
                    if in_empty_d = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_E_ST => 
                    if in_empty_e = '0' and out_awfull = '0' then 
                        out_wren <= '1';
                    else
                        out_wren <= '0';
                    end if;

                when TX_F_ST => 
                    if in_empty_f = '0' and out_awfull = '0' then 
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

    fifo_in_sync_xpm_inst_2 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_2                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_2              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_2              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_2             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_2              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_2             ,

            IN_DOUT_DATA    =>  in_dout_data_2              ,
            IN_DOUT_KEEP    =>  in_dout_keep_2              ,
            IN_DOUT_LAST    =>  in_dout_last_2              ,
            IN_RDEN         =>  in_rden_2                   ,
            IN_EMPTY        =>  in_empty_2                   
        );

    fifo_in_pkt_xpm_inst_2 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_2                      
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_2         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_2          ,
            IN_RDEN         =>  IN_RDEN_PKT_2           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_2           
        );

    fifo_in_sync_xpm_inst_3 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_3                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_3              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_3              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_3             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_3              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_3             ,

            IN_DOUT_DATA    =>  in_dout_data_3              ,
            IN_DOUT_KEEP    =>  in_dout_keep_3              ,
            IN_DOUT_LAST    =>  in_dout_last_3              ,
            IN_RDEN         =>  in_rden_3                   ,
            IN_EMPTY        =>  in_empty_3                   
        );

    fifo_in_pkt_xpm_inst_3 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_3                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_3         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_3          ,
            IN_RDEN         =>  IN_RDEN_PKT_3           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_3           
        );

    fifo_in_sync_xpm_inst_4 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_4                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_4              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_4              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_4             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_4              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_4             ,

            IN_DOUT_DATA    =>  in_dout_data_4              ,
            IN_DOUT_KEEP    =>  in_dout_keep_4              ,
            IN_DOUT_LAST    =>  in_dout_last_4              ,
            IN_RDEN         =>  in_rden_4                   ,
            IN_EMPTY        =>  in_empty_4                   
        );

    fifo_in_pkt_xpm_inst_4 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_4                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_4         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_4          ,
            IN_RDEN         =>  IN_RDEN_PKT_4           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_4           
        );

    fifo_in_sync_xpm_inst_5 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_5                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_5              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_5              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_5             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_5              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_5             ,

            IN_DOUT_DATA    =>  in_dout_data_5              ,
            IN_DOUT_KEEP    =>  in_dout_keep_5              ,
            IN_DOUT_LAST    =>  in_dout_last_5              ,
            IN_RDEN         =>  in_rden_5                   ,
            IN_EMPTY        =>  in_empty_5                   
        );

    fifo_in_pkt_xpm_inst_5 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_5                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_5         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_5          ,
            IN_RDEN         =>  IN_RDEN_PKT_5           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_5           
        );

    fifo_in_sync_xpm_inst_6 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_6                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_6              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_6              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_6             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_6              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_6             ,

            IN_DOUT_DATA    =>  in_dout_data_6              ,
            IN_DOUT_KEEP    =>  in_dout_keep_6              ,
            IN_DOUT_LAST    =>  in_dout_last_6              ,
            IN_RDEN         =>  in_rden_6                   ,
            IN_EMPTY        =>  in_empty_6                   
        );

    fifo_in_pkt_xpm_inst_6 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_6                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_6         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_6          ,
            IN_RDEN         =>  IN_RDEN_PKT_6           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_6           
        );

    fifo_in_sync_xpm_inst_7 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_7                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_7              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_7              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_7             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_7              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_7             ,

            IN_DOUT_DATA    =>  in_dout_data_7              ,
            IN_DOUT_KEEP    =>  in_dout_keep_7              ,
            IN_DOUT_LAST    =>  in_dout_last_7              ,
            IN_RDEN         =>  in_rden_7                   ,
            IN_EMPTY        =>  in_empty_7                   
        );

    fifo_in_pkt_xpm_inst_7 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_7                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_7         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_7          ,
            IN_RDEN         =>  IN_RDEN_PKT_7           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_7           
        );

    fifo_in_sync_xpm_inst_8 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_8                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_8              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_8              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_8             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_8              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_8             ,

            IN_DOUT_DATA    =>  in_dout_data_8              ,
            IN_DOUT_KEEP    =>  in_dout_keep_8              ,
            IN_DOUT_LAST    =>  in_dout_last_8              ,
            IN_RDEN         =>  in_rden_8                   ,
            IN_EMPTY        =>  in_empty_8                   
        );

    fifo_in_pkt_xpm_inst_8 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_8                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_8         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_8          ,
            IN_RDEN         =>  IN_RDEN_PKT_8           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_8           
        );

    fifo_in_sync_xpm_inst_9 : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_9                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_9              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_9              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_9             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_9              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_9             ,

            IN_DOUT_DATA    =>  in_dout_data_9              ,
            IN_DOUT_KEEP    =>  in_dout_keep_9              ,
            IN_DOUT_LAST    =>  in_dout_last_9              ,
            IN_RDEN         =>  in_rden_9                   ,
            IN_EMPTY        =>  in_empty_9                   
        );

    fifo_in_pkt_xpm_inst_9 : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_9                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_9         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_9          ,
            IN_RDEN         =>  IN_RDEN_PKT_9           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_9           
        );

    fifo_in_sync_xpm_inst_A : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_A                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_A              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_A              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_A             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_A              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_A             ,

            IN_DOUT_DATA    =>  in_dout_data_A              ,
            IN_DOUT_KEEP    =>  in_dout_keep_A              ,
            IN_DOUT_LAST    =>  in_dout_last_A              ,
            IN_RDEN         =>  in_rden_A                   ,
            IN_EMPTY        =>  in_empty_A                   
        );

    fifo_in_pkt_xpm_inst_A : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_A                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_A         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_A          ,
            IN_RDEN         =>  IN_RDEN_PKT_A           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_A           
        );

    fifo_in_sync_xpm_inst_B : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_B                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_B              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_B              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_B             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_B              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_B             ,

            IN_DOUT_DATA    =>  in_dout_data_B              ,
            IN_DOUT_KEEP    =>  in_dout_keep_B              ,
            IN_DOUT_LAST    =>  in_dout_last_B              ,
            IN_RDEN         =>  in_rden_B                   ,
            IN_EMPTY        =>  in_empty_B                   
        );

    fifo_in_pkt_xpm_inst_B : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_B                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_B         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_B          ,
            IN_RDEN         =>  IN_RDEN_PKT_B           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_B           
        );

    fifo_in_sync_xpm_inst_C : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_C                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_C              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_C              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_C             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_C              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_C             ,

            IN_DOUT_DATA    =>  in_dout_data_C              ,
            IN_DOUT_KEEP    =>  in_dout_keep_C              ,
            IN_DOUT_LAST    =>  in_dout_last_C              ,
            IN_RDEN         =>  in_rden_C                   ,
            IN_EMPTY        =>  in_empty_C                   
        );

    fifo_in_pkt_xpm_inst_C : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_C                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_C         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_C          ,
            IN_RDEN         =>  IN_RDEN_PKT_C           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_C           
        );

    fifo_in_sync_xpm_inst_D : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_D                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_D              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_D              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_D             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_D              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_D             ,

            IN_DOUT_DATA    =>  in_dout_data_D              ,
            IN_DOUT_KEEP    =>  in_dout_keep_D              ,
            IN_DOUT_LAST    =>  in_dout_last_D              ,
            IN_RDEN         =>  in_rden_D                   ,
            IN_EMPTY        =>  in_empty_D                   
        );

    fifo_in_pkt_xpm_inst_D : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_D                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_D         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_D          ,
            IN_RDEN         =>  IN_RDEN_PKT_D           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_D           
        );

    fifo_in_sync_xpm_inst_E : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_E                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_E              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_E              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_E             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_E              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_E             ,

            IN_DOUT_DATA    =>  in_dout_data_E              ,
            IN_DOUT_KEEP    =>  in_dout_keep_E              ,
            IN_DOUT_LAST    =>  in_dout_last_E              ,
            IN_RDEN         =>  in_rden_E                   ,
            IN_EMPTY        =>  in_empty_E                   
        );

    fifo_in_pkt_xpm_inst_E : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_E                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_E         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_E          ,
            IN_RDEN         =>  IN_RDEN_PKT_E           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_E           
        );

    fifo_in_sync_xpm_inst_F : fifo_in_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                  ,
            MEMTYPE         =>  FIFO_TYPE_DATA              ,
            DEPTH           =>  DATA_DEPTH_F                        
        )
        port map (
            CLK             =>  CLK                         ,
            RESET           =>  RESET                       ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA_F              ,
            S_AXIS_TKEEP    =>  S_AXIS_TKEEP_F              ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_F             ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_F              ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY_F             ,

            IN_DOUT_DATA    =>  in_dout_data_F              ,
            IN_DOUT_KEEP    =>  in_dout_keep_F              ,
            IN_DOUT_LAST    =>  in_dout_last_F              ,
            IN_RDEN         =>  in_rden_F                   ,
            IN_EMPTY        =>  in_empty_F                   
        );

    fifo_in_pkt_xpm_inst_F : fifo_in_pkt_xpm
        generic map (
            MEMTYPE         =>  FIFO_TYPE_PKT           ,
            DEPTH           =>  PKT_DEPTH_F                       
        )
        port map (
            CLK             =>  CLK                     ,
            RESET           =>  RESET                   ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID_F         ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST_F          ,
            IN_RDEN         =>  IN_RDEN_PKT_F           ,
            IN_EMPTY        =>  IN_EMPTY_PKT_F           
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
    in_rden_2 <= '1' when current_state = TX_2_ST and out_awfull = '0' else '0';
    in_rden_3 <= '1' when current_state = TX_3_ST and out_awfull = '0' else '0';
    in_rden_4 <= '1' when current_state = TX_4_ST and out_awfull = '0' else '0';
    in_rden_5 <= '1' when current_state = TX_5_ST and out_awfull = '0' else '0';
    in_rden_6 <= '1' when current_state = TX_6_ST and out_awfull = '0' else '0';
    in_rden_7 <= '1' when current_state = TX_7_ST and out_awfull = '0' else '0';
    in_rden_8 <= '1' when current_state = TX_8_ST and out_awfull = '0' else '0';
    in_rden_9 <= '1' when current_state = TX_9_ST and out_awfull = '0' else '0';
    in_rden_A <= '1' when current_state = TX_A_ST and out_awfull = '0' else '0';
    in_rden_B <= '1' when current_state = TX_B_ST and out_awfull = '0' else '0';
    in_rden_C <= '1' when current_state = TX_C_ST and out_awfull = '0' else '0';
    in_rden_D <= '1' when current_state = TX_D_ST and out_awfull = '0' else '0';
    in_rden_E <= '1' when current_state = TX_E_ST and out_awfull = '0' else '0';
    in_rden_F <= '1' when current_state = TX_F_ST and out_awfull = '0' else '0';

end axis_pkt_sw_16_to_1_arch;
