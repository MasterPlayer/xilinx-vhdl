library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


entity tb_axis_arb_2_to_1 is
end tb_axis_arb_2_to_1;



architecture tb_axis_arb_2_to_1_arch of tb_axis_arb_2_to_1 is

    constant  N_BYTES             :           integer                           := 2                ;

    component axis_arb_2_to_1
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
    end component;

    signal  CLK                 :           std_logic                                    := '0'             ;
    signal  RESET               :           std_logic                                    := '0'             ;

    signal  S00_AXIS_TDATA      :           std_logic_vector ( (N_BYTES*8)-1 downto 0 )  := (others => '0') ;
    signal  S00_AXIS_TKEEP      :           std_logic_vector ( (N_BYTES-1) downto 0 )    := (others => '0') ;
    signal  S00_AXIS_TVALID     :           std_logic                                    := '0'             ;
    signal  S00_AXIS_TREADY     :           std_logic                                                       ;
    signal  S00_AXIS_TLAST      :           std_logic                                    := '0'             ;

    signal  S01_AXIS_TDATA      :           std_logic_vector ( (N_BYTES*8)-1 downto 0 )  := (others => '0') ;
    signal  S01_AXIS_TKEEP      :           std_logic_vector ( (N_BYTES-1) downto 0 )    := (others => '0') ;
    signal  S01_AXIS_TVALID     :           std_logic                                    := '0'             ;
    signal  S01_AXIS_TREADY     :           std_logic                                                       ;
    signal  S01_AXIS_TLAST      :           std_logic                                    := '0'             ;

    signal  M_AXIS_TDATA        :           std_logic_vector ( (N_BYTES*8)-1 downto 0 )                     ;
    signal  M_AXIS_TKEEP        :           std_logic_vector ( (N_BYTES-1) downto 0 )                       ;
    signal  M_AXIS_TVALID       :           std_logic                                                       ;
    signal  M_AXIS_TREADY       :           std_logic                                    := '0'             ;
    signal  M_AXIS_TLAST        :           std_logic                                                       ;

    constant  CLK_PERIOD : time := 10 ns;

    signal i                    :           integer                                      := 0;



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

    signal  ENABLE_0                :            std_logic                        := '0'             ;
    signal  PAUSE_0                 :            std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  WORD_LIMIT_0            :            std_logic_Vector ( 31 downto 0 ) := (others => '0') ;

    signal  ENABLE_1                :            std_logic                        := '0'             ;
    signal  PAUSE_1                 :            std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  WORD_LIMIT_1            :            std_logic_Vector ( 31 downto 0 ) := (others => '0') ;

    signal  i_rdy_counter           :            integer                            := 0                ;

begin

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

    i_rdy_counter_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                i_rdy_counter <= 0;
            else
                
                if i_rdy_counter < 16 then 
                    i_rdy_counter <= i_rdy_counter + 1;
                else
                    i_rdy_counter <= 0;
                end if;

            end if;
        end if;
    end process;

    WORD_LIMIT_0 <= x"00000010";
    WORD_LIMIT_1 <= x"00000100";

    PAUSE_0 <= x"00000000";
    PAUSE_1 <= x"00000000";

    ENABLE_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i > 1000 and i < 10000 then
                ENABLE_0 <= '1';
            else
                ENABLE_0 <= '0';
            end if;
        end if;
    end process;

    ENABLE_1_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i > 2000 and i < 11000 then 
                ENABLE_1 <= '1';
            else
                ENABLE_1 <= '0';
            end if;
        end if;
    end process;

    axis_dump_gen_inst_0 : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES                                         ,
            ASYNC                   =>  false                                           ,
            MODE                    =>  "SINGLE"          -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  CLK                                             ,
            RESET                   =>  RESET                                           ,
            
            ENABLE                  =>  ENABLE_0                                        ,
            PAUSE                   =>  PAUSE_0                                         ,
            WORD_LIMIT              =>  WORD_LIMIT_0                                    ,
            
            M_AXIS_CLK              =>  CLK                                             ,
            M_AXIS_TDATA            =>  S00_AXIS_TDATA                                  ,
            M_AXIS_TKEEP            =>  S00_AXIS_TKEEP                                  ,
            M_AXIS_TVALID           =>  S00_AXIS_TVALID                                 ,
            M_AXIS_TREADY           =>  S00_AXIS_TREADY                                 ,
            M_AXIS_TLAST            =>  S00_AXIS_TLAST                                  
        );

    axis_dump_gen_inst_1 : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES                                         ,
            ASYNC                   =>  false                                           ,
            MODE                    =>  "BYTE"          -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  CLK                                             ,
            RESET                   =>  RESET                                           ,
            
            ENABLE                  =>  ENABLE_1                                        ,
            PAUSE                   =>  PAUSE_1                                         ,
            WORD_LIMIT              =>  WORD_LIMIT_1                                    ,
            
            M_AXIS_CLK              =>  CLK                                             ,
            M_AXIS_TDATA            =>  S01_AXIS_TDATA                                  ,
            M_AXIS_TKEEP            =>  S01_AXIS_TKEEP                                  ,
            M_AXIS_TVALID           =>  S01_AXIS_TVALID                                 ,
            M_AXIS_TREADY           =>  S01_AXIS_TREADY                                 ,
            M_AXIS_TLAST            =>  S01_AXIS_TLAST                                  
        );


    axis_arb_2_to_1_inst : axis_arb_2_to_1
        generic map (
            N_BYTES             =>  N_BYTES                                                      
        )
        port map (
            CLK                 =>  CLK                                                                     ,
            RESET               =>  RESET                                                                   ,

            S00_AXIS_TDATA      =>  S00_AXIS_TDATA                                                          ,
            S00_AXIS_TKEEP      =>  S00_AXIS_TKEEP                                                          ,
            S00_AXIS_TVALID     =>  S00_AXIS_TVALID                                                         ,
            S00_AXIS_TREADY     =>  S00_AXIS_TREADY                                                         ,
            S00_AXIS_TLAST      =>  S00_AXIS_TLAST                                                          ,

            S01_AXIS_TDATA      =>  S01_AXIS_TDATA                                                          ,
            S01_AXIS_TKEEP      =>  S01_AXIS_TKEEP                                                          ,
            S01_AXIS_TVALID     =>  S01_AXIS_TVALID                                                         ,
            S01_AXIS_TREADY     =>  S01_AXIS_TREADY                                                         ,
            S01_AXIS_TLAST      =>  S01_AXIS_TLAST                                                          ,

            M_AXIS_TDATA        =>  M_AXIS_TDATA                                                            ,
            M_AXIS_TKEEP        =>  M_AXIS_TKEEP                                                            ,
            M_AXIS_TVALID       =>  M_AXIS_TVALID                                                           ,
            M_AXIS_TREADY       =>  M_AXIS_TREADY                                                           ,
            M_AXIS_TLAST        =>  M_AXIS_TLAST                                                             
        );

    M_AXIS_TREADY <= '1' when i_rdy_counter < 2 else '0';

end tb_axis_arb_2_to_1_arch;
