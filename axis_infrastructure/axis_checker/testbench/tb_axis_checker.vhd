library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";


library UNISIM;
    use UNISIM.VComponents.all;



entity tb_axis_checker is
end tb_axis_checker;



architecture tb_axis_checker_arch of tb_axis_checker is
    
    constant CLK_period : time := 10 ns;

    constant  N_BYTES                 :           integer   := 8                                  ;
    constant  TIMER_LIMIT             :           integer   := 156250000                          ;
    constant  MODE                    :           string    := "SINGLE"                           ;-- "ZEROS" "BYTE;


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

    signal gen_enable               :           std_logic                                           ;
    signal gen_pause                :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal gen_word_limit           :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;


    component axis_checker
        generic (
            N_BYTES                 :           integer   := 4                                  ;
            TIMER_LIMIT             :           integer   := 156250000                          ;
            MODE                    :           string    := "SINGLE"  -- "ZEROS" "BYTE"
        );
        port(
            CLK                     :   in      std_logic                                       ;
            RESET                   :   in      std_logic                                       ;
            
            S_AXIS_TDATA            :   in      std_logic_vector ( (N_BYTES*8)-1 downto 0 )     ;
            S_AXIS_TKEEP            :   in      std_logic_vector ( N_BYTES-1 downto 0 )         ;
            S_AXIS_TVALID           :   in      std_logic                                       ;
            S_AXIS_TREADY           :   out     std_logic                                       ;
            S_AXIS_TLAST            :   in      std_logic                                       ;
            
            ENABLE                  :   in      std_logic                                       ;
            PACKET_SIZE             :   in      std_logic_vector ( 31 downto 0 )                ;

            READY_LIMIT             :   in      std_logic_Vector ( 31 downto 0 )                ;
            NOT_READY_LIMIT         :   in      std_logic_Vector ( 31 downto 0 )                ;

            DATA_ERROR              :   out     std_logic_vector ( 31 downto 0 )                ;
            PACKET_ERROR            :   out     std_logic_vector ( 31 downto 0 )                ;
            DATA_SPEED              :   out     std_logic_vector ( 31 downto 0 )                ;
            PACKET_SPEED            :   out     std_logic_vector ( 31 downto 0 )                ;
            HAS_PACKET_ERR          :   out     std_logic                                       ;
            HAS_DATA_ERR            :   out     std_logic                           
        );
    end component;

    signal  CLK                     :           std_logic                                   := '0'                  ;
    signal  RESET                   :           std_logic                                   := '0'                  ;


    signal  S_AXIS_TDATA            :           std_logic_vector ( (N_BYTES*8)-1 downto 0 ) := (others => '0')      ;
    signal  S_AXIS_TKEEP            :           std_logic_vector ( N_BYTES-1 downto 0 )     := (others => '0')      ;
    signal  S_AXIS_TVALID           :           std_logic                                   := '0'                  ;
    signal  S_AXIS_TREADY           :           std_logic                                                           ;
    signal  S_AXIS_TLAST            :           std_logic                                   := '0'                  ;
    
    signal  ENABLE                  :           std_logic                                   := '0'                  ;
    signal  PACKET_SIZE             :           std_logic_vector ( 31 downto 0 )            := (others => '0')      ;

    signal  READY_LIMIT             :           std_logic_Vector ( 31 downto 0 )            := (others => '0')      ;
    signal  NOT_READY_LIMIT         :           std_logic_Vector ( 31 downto 0 )            := (others => '0')      ;

    signal  DATA_ERROR              :           std_logic_vector ( 31 downto 0 )                                    ;
    signal  PACKET_ERROR            :           std_logic_vector ( 31 downto 0 )                                    ;
    signal  DATA_SPEED              :           std_logic_vector ( 31 downto 0 )                                    ;
    signal  PACKET_SPEED            :           std_logic_vector ( 31 downto 0 )                                    ;
    signal  HAS_PACKET_ERR          :           std_logic                                                           ;
    signal  HAS_DATA_ERR            :           std_logic                                                           ;


    signal  i : integer := 0;


begin

    CLK <= not CLK after CLK_period/2;

    i_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            i <= i + 1;
        end if;
    end process;

    RESET_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i < 100 then 
                RESET <= '1';
            else
                RESET <= '0';
            end if;
        end if;
    end process;

    axis_checker_inst : axis_checker
        generic map (
            N_BYTES                 =>  N_BYTES                                                 ,
            TIMER_LIMIT             =>  TIMER_LIMIT                                             ,
            MODE                    =>  MODE                                                     
        )
        port map (
            CLK                     =>  CLK                                                     ,
            RESET                   =>  RESET                                                   ,
            
            S_AXIS_TDATA            =>  S_AXIS_TDATA                                            ,
            S_AXIS_TKEEP            =>  S_AXIS_TKEEP                                            ,
            S_AXIS_TVALID           =>  S_AXIS_TVALID                                           ,
            S_AXIS_TREADY           =>  S_AXIS_TREADY                                           ,
            S_AXIS_TLAST            =>  S_AXIS_TLAST                                            ,
            
            ENABLE                  =>  ENABLE                                                  ,
            PACKET_SIZE             =>  PACKET_SIZE                                             ,

            READY_LIMIT             =>  READY_LIMIT                                             ,
            NOT_READY_LIMIT         =>  NOT_READY_LIMIT                                         ,

            DATA_ERROR              =>  DATA_ERROR                                              ,
            PACKET_ERROR            =>  PACKET_ERROR                                            ,
            DATA_SPEED              =>  DATA_SPEED                                              ,
            PACKET_SPEED            =>  PACKET_SPEED                                            ,
            HAS_PACKET_ERR          =>  HAS_PACKET_ERR                                          ,
            HAS_DATA_ERR            =>  HAS_DATA_ERR                                             
        );

    ENABLE <= '1' when i > 1000 else '0';
    PACKET_SIZE <= x"00001000";

    READY_LIMIT     <= x"00000010";
    NOT_READY_LIMIT <= x"00000001";


    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES                ,
            ASYNC                   =>  false                   ,
            MODE                    =>  MODE -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                      =>  CLK                                                     ,
            RESET                    =>  RESET                                                   ,
            
            ENABLE                  =>  gen_enable                                                  ,
            PAUSE                   =>  gen_pause                                                   ,
            WORD_LIMIT              =>  gen_word_limit                                              ,
            
            M_AXIS_CLK              =>  CLK                                                     ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA                                            ,
            M_AXIS_TKEEP            =>  S_AXIS_TKEEP                                            ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID                                           ,
            M_AXIS_TREADY           =>  S_AXIS_TREADY                                           ,
            M_AXIS_TLAST            =>  S_AXIS_TLAST                                             
        );

gen_enable <= '1' when i > 1000 else '0';
gen_pause <= x"00001000";
gen_word_limit <= x"00001000";


end tb_axis_checker_arch;
