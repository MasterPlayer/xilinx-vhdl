library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library unisim;
    use unisim.vcomponents.all;


entity tb_axis_pkt_sw_2_to_1 is
end tb_axis_pkt_sw_2_to_1;



architecture tb_axis_pkt_sw_2_to_1_arch  of tb_axis_pkt_sw_2_to_1 is

    constant  N_BYTES           :           integer := 4                                            ;
    constant  FIFO_TYPE_DATA    :           string  := "block"                                      ;
    constant  FIFO_TYPE_PKT     :           string  := "distributed"                                ;
    constant  DATA_DEPTH_0      :           integer := 1024                                         ;
    constant  DATA_DEPTH_1      :           integer := 1024                                         ;
    constant  PKT_DEPTH_0       :           integer := 1024                                         ;
    constant  PKT_DEPTH_1       :           integer := 1024                                         ;


    component axis_pkt_sw_2_to_1
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
    end component;

    signal  CLK                 :           std_logic                                  := '0'               ;
    signal  RESET               :           std_Logic                                  := '1'               ;

    signal  S_AXIS_TDATA_0      :           std_logic_Vector ((N_BYTES*8)-1 downto 0 ) := (others => '0')   ;
    signal  S_AXIS_TKEEP_0      :           std_logic_Vector ((N_BYTES-1)   downto 0 ) := (others => '0')   ;
    signal  S_AXIS_TVALID_0     :           std_logic                                  := '0'               ;
    signal  S_AXIS_TLAST_0      :           std_logic                                  := '0'               ;
    signal  S_AXIS_TREADY_0     :           std_logic                                                       ;

    signal  S_AXIS_TDATA_1      :           std_logic_Vector ((N_BYTES*8)-1 downto 0 ) := (others => '0')   ;
    signal  S_AXIS_TKEEP_1      :           std_logic_Vector ((N_BYTES-1)   downto 0 ) := (others => '0')   ;
    signal  S_AXIS_TVALID_1     :           std_logic                                  := '0'               ;
    signal  S_AXIS_TLAST_1      :           std_logic                                  := '0'               ;
    signal  S_AXIS_TREADY_1     :           std_logic                                                       ;

    signal  M_AXIS_TDATA        :           std_logic_Vector ((N_BYTES*8)-1 downto 0 )                      ;
    signal  M_AXIS_TKEEP        :           std_logic_Vector ((N_BYTES-1)   downto 0 )                      ;
    signal  M_AXIS_TVALID       :           std_logic                                                       ;
    signal  M_AXIS_TLAST        :           std_logic                                                       ;
    signal  M_AXIS_TREADY       :           std_Logic                                  := '0'               ;



    component axis_dump_gen
        generic (
            N_BYTES                 :           integer                         := 2                ;
            ASYNC                   :           boolean                         := false            ;
            MODE                    :           string                          := "SINGLE"          -- "SINGLE", "ZEROS", "BYTE"
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
    end component;

    signal  ENABLE_0                :           std_logic                        := '0'             ;
    signal  PAUSE_0                 :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  WORD_LIMIT_0            :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;

    signal  ENABLE_1                :           std_logic                        := '0'             ;
    signal  PAUSE_1                 :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  WORD_LIMIT_1            :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;


    constant  clk_period : time := 10 ns;

    signal i : integer := 10;

begin

    CLK <= not CLK after clk_period/2;

    i_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            i <= i + 1;
        end if;
    end process;

    RESET_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i < 10 then 
                RESET <= '1';
            else
                RESET <= '0';
            end if;
        end if;
    end process;

    gen_control_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when 1000   => ENABLE_0 <= '1'; PAUSE_0 <= x"00000000"; WORD_LIMIT_0 <= x"00000020";
                               ENABLE_1 <= '1'; PAUSE_1 <= x"00000000"; WORD_LIMIT_1 <= x"00000200";
                when others => ENABLE_0 <= '0'; PAUSE_0 <= x"00000000"; WORD_LIMIT_0 <= x"00000000";
                               ENABLE_1 <= '0'; PAUSE_1 <= x"00000000"; WORD_LIMIT_1 <= x"00000000";
            end case;
        end if;
    end process;

    axis_dump_gen_inst_0 : axis_dump_gen
        generic map (
            N_BYTES             =>  N_BYTES                                                         ,
            ASYNC               =>  false                                                           ,
            MODE                =>  "SINGLE"                                                        
        )
        port map (
            CLK                 =>  CLK                                                             ,
            RESET               =>  RESET                                                           ,
            
            ENABLE              =>  ENABLE_0                                                        ,
            PAUSE               =>  PAUSE_0                                                         ,
            WORD_LIMIT          =>  WORD_LIMIT_0                                                    ,
            
            M_AXIS_CLK          =>  CLK                                                             ,
            M_AXIS_TDATA        =>  S_AXIS_TDATA_0                                                  ,
            M_AXIS_TKEEP        =>  S_AXIS_TKEEP_0                                                  ,
            M_AXIS_TVALID       =>  S_AXIS_TVALID_0                                                 ,
            M_AXIS_TLAST        =>  S_AXIS_TLAST_0                                                  ,
            M_AXIS_TREADY       =>  S_AXIS_TREADY_0                                                  
        );

    axis_dump_gen_inst_1 : axis_dump_gen
        generic map (
            N_BYTES             =>  N_BYTES                                                         ,
            ASYNC               =>  false                                                           ,
            MODE                =>  "SINGLE"                                                        
        )
        port map (
            CLK                 =>  CLK                                                             ,
            RESET               =>  RESET                                                           ,
            
            ENABLE              =>  ENABLE_1                                                        ,
            PAUSE               =>  PAUSE_1                                                         ,
            WORD_LIMIT          =>  WORD_LIMIT_1                                                    ,
            
            M_AXIS_CLK          =>  CLK                                                             ,
            M_AXIS_TDATA        =>  S_AXIS_TDATA_1                                                  ,
            M_AXIS_TKEEP        =>  S_AXIS_TKEEP_1                                                  ,
            M_AXIS_TVALID       =>  S_AXIS_TVALID_1                                                 ,
            M_AXIS_TLAST        =>  S_AXIS_TLAST_1                                                  ,
            M_AXIS_TREADY       =>  S_AXIS_TREADY_1                                                  
        );


    axis_pkt_sw_2_to_1_inst : axis_pkt_sw_2_to_1
        generic map (
            N_BYTES             =>  N_BYTES                                                         ,
            FIFO_TYPE_DATA      =>  FIFO_TYPE_DATA                                                  ,
            FIFO_TYPE_PKT       =>  FIFO_TYPE_PKT                                                   ,
            DATA_DEPTH_0        =>  DATA_DEPTH_0                                                    ,
            DATA_DEPTH_1        =>  DATA_DEPTH_1                                                    ,
            PKT_DEPTH_0         =>  PKT_DEPTH_0                                                     ,
            PKT_DEPTH_1         =>  PKT_DEPTH_1                                                      
        )
        port map (
            CLK                 =>  CLK                                                             ,
            RESET               =>  RESET                                                           ,
            
            S_AXIS_TDATA_0      =>  S_AXIS_TDATA_0                                                  ,
            S_AXIS_TKEEP_0      =>  S_AXIS_TKEEP_0                                                  ,
            S_AXIS_TVALID_0     =>  S_AXIS_TVALID_0                                                 ,
            S_AXIS_TLAST_0      =>  S_AXIS_TLAST_0                                                  ,
            S_AXIS_TREADY_0     =>  S_AXIS_TREADY_0                                                 ,
            
            S_AXIS_TDATA_1      =>  S_AXIS_TDATA_1                                                  ,
            S_AXIS_TKEEP_1      =>  S_AXIS_TKEEP_1                                                  ,
            S_AXIS_TVALID_1     =>  S_AXIS_TVALID_1                                                 ,
            S_AXIS_TLAST_1      =>  S_AXIS_TLAST_1                                                  ,
            S_AXIS_TREADY_1     =>  S_AXIS_TREADY_1                                                 ,

            M_AXIS_TDATA        =>  M_AXIS_TDATA                                                    ,
            M_AXIS_TKEEP        =>  M_AXIS_TKEEP                                                    ,
            M_AXIS_TVALID       =>  M_AXIS_TVALID                                                   ,
            M_AXIS_TLAST        =>  M_AXIS_TLAST                                                    ,
            M_AXIS_TREADY       =>  M_AXIS_TREADY                                                    
        );
    M_AXIS_TREADY <= '1';

end tb_axis_pkt_sw_2_to_1_arch;
