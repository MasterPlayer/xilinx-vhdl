library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


entity tb_axis_data_delayer is
end tb_axis_data_delayer;



architecture tb_axis_data_delayer_arch of tb_axis_data_delayer is

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
    

    signal  SLOWCLK                 :           std_logic                   := '0'                  ;
    signal  ENABLE                  :           std_logic                   := '0'                  ;



    component axis_data_delayer
        generic(
            DW                      :           integer := 32                                           ;
            DELAY                   :           integer := 8000                                         ;
            MEMTYPE                 :           string  := "block"                                      ;
            MAX_PKT_SIZE            :           integer := 2048                                         
        );
        port(
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
    end component;

    signal  CLK                     :           std_logic                        := '0'                 ;
    signal  RESET                   :           std_logic                        := '0'                 ;

    signal  S_AXIS_TDATA            :           std_logic_Vector ( 31 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_TKEEP            :           std_logic_Vector (  3 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_TVALID           :           std_logic                        := '0'                 ;
    signal  S_AXIS_TLAST            :           std_logic                        := '0'                 ;

    signal  M_AXIS_TDATA            :           std_logic_Vector ( 31 downto 0 )                        ;
    signal  M_AXIS_TKEEP            :           std_logic_Vector (  3 downto 0 )                        ;
    signal  M_AXIS_TVALID           :           std_logic                                               ;
    signal  M_AXIS_TLAST            :           std_logic                                               ;

    signal  DBG_OVERLOAD_DATA       :           std_logic                                               ;
    signal  DBG_OVERLOAD_TIMER      :           std_Logic                                               ;



    constant  CLK_PERIOD : time := 6400 ps;

    signal i                    :           integer                                      := 0;

    signal  mclk_duration : integer := 0;

    signal  packet_size_cnt : std_logic_Vector ( 31 downto 0 ) := (others => '0')   ;
    signal  packet_size_reg : std_logic_Vector ( 31 downto 0 ) := (others => '0')   ;

begin

    SLOWCLK <= not SLOWCLK after 10 ns;
    CLK <= not CLK after CLK_PERIOD/2;

    i_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            i <= i + 1;
        end if;
    end process;

    RESET_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if I < 100 then 
                RESET <= '1';
            else
                RESET <= '0';
            end if;
        end if;
    end process;

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  4                                   ,
            ASYNC                   =>  true                                ,
            MODE                    =>  "SINGLE"                            -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  SLOWCLK                             ,
            RESET                   =>  RESET                               ,
            
            ENABLE                  =>  ENABLE                              ,
            PAUSE                   =>  x"00000001"                         ,
            WORD_LIMIT              =>  x"00000008"                         ,
            
            M_AXIS_CLK              =>  CLK                                 ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA                        ,
            M_AXIS_TKEEP            =>  S_AXIS_TKEEP                        ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID                       ,
            M_AXIS_TREADY           =>  '1'                                 ,
            M_AXIS_TLAST            =>  S_AXIS_TLAST                         
        );
    
    ENABLE <= '1' when i > 1000 else '0';

    axis_data_delayer_inst : axis_data_delayer
        generic map (
            DW                      =>  32                                  ,
            DELAY                   =>  25                                ,
            MEMTYPE                 =>  "block"                             ,
            MAX_PKT_SIZE            =>  8                                 
        )
        port map (
            CLK                     =>  CLK                                 ,
            RESET                   =>  RESET                               ,

            S_AXIS_TDATA            =>  S_AXIS_TDATA                        ,
            S_AXIS_TKEEP            =>  S_AXIS_TKEEP                        ,
            S_AXIS_TVALID           =>  S_AXIS_TVALID                       ,
            S_AXIS_TLAST            =>  S_AXIS_TLAST                        ,

            M_AXIS_TDATA            =>  M_AXIS_TDATA                        ,
            M_AXIS_TKEEP            =>  M_AXIS_TKEEP                        ,
            M_AXIS_TVALID           =>  M_AXIS_TVALID                       ,
            M_AXIS_TLAST            =>  M_AXIS_TLAST                        ,

            DBG_OVERLOAD_DATA       =>  DBG_OVERLOAD_DATA                   ,
            DBG_OVERLOAD_TIMER      =>  DBG_OVERLOAD_TIMER                   

        );

    mclk_duration_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if mclk_duration = 0 then 
                if S_AXIS_TVALID = '1' then 
                    mclk_duration <= mclk_duration + 1;
                else
                    mclk_duration <= mclk_duration;
                end if;
            else 
                if S_AXIS_TVALID = '1' and S_AXIS_TLAST = '1' then 
                    mclk_duration <= 0;
                else
                    mclk_duration <= mclk_duration + 1;
                end if;
            end if;
        end if;
    end process;

    packet_size_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if M_AXIS_TVALID = '1' then 
                if M_AXIS_TLAST = '1' then 
                    packet_size_cnt <= (others => '0');
                else
                    packet_size_cnt <= packet_size_cnt + 1;
                end if;
            else
                packet_size_cnt <= packet_size_cnt;
            end if;
        end if;
    end process;

    packet_size_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if M_AXIS_TVALID = '1' then 
                if M_AXIS_TLAST = '1' then 
                    packet_size_reg <= packet_size_cnt + 1;
                else
                    packet_size_reg <= packet_size_reg;
                end if;
            else
                packet_size_reg <= packet_size_reg;
            end if;
        end if;
    end process;


end tb_axis_data_delayer_arch;
