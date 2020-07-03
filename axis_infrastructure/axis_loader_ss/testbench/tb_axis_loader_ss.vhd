library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";


library UNISIM;
    use UNISIM.VComponents.all;


entity tb_axis_loader_ss is
end tb_axis_loader_ss;



architecture tb_axis_loader_ss_arch of tb_axis_loader_ss is

    constant  WAIT_ABORT_LIMIT    :           integer := 100000000                                ;
    constant  ASYNC_MODE          :           boolean := false                                    ;
    constant  N_BYTES             :           integer := 8                                        ;     -- Supports : 1/2/4/8 BYTES


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

    signal  ENABLE                  :           std_logic                           := '0'              ;
    signal  PAUSE                   :           std_logic_Vector ( 31 downto 0 )    := (others => '0')  ;
    signal  WORD_LIMIT              :           std_logic_Vector ( 31 downto 0 )    := (others => '0')  ;


    component axis_loader_ss
        generic (
            WAIT_ABORT_LIMIT    :           integer := 100000000                                ;
            ASYNC_MODE          :           boolean := true                                     ;
            N_BYTES             :           integer := 2                                        --;   -- Supports : 1/2/4/8 BYTES
        );
        port (
            CLK                 :   in      std_logic                                           ;
            RESET               :   in      std_logic                                           ;
            CLK_SS              :   in      std_logic                                           ;

            STS_PROG_GOOD       :   out     std_logic                                           ;
            STS_PROG_FAIL       :   out     std_logic                                           ;

            S_AXIS_TDATA        :   in      std_logic_Vector ( (N_BYTES*8)-1 downto 0 )         ;
            S_AXIS_TKEEP        :   in      std_logic_Vector (  N_BYTES-1 downto 0 )            ;
            S_AXIS_TVALID       :   in      std_logic                                           ;
            S_AXIS_TLAST        :   in      std_logic                                           ;
            S_AXIS_TREADY       :   out     std_logic                                           ;
            CCLK                :   out     std_logic                                           ;
            DIN                 :   out     std_logic                                           ;
            DONE                :   in      std_logic                                           ;
            INIT_B              :   in      std_logic                                           ;
            PROG_B              :   out     std_logic                                            
        );
    end component;

    signal  CLK                 :           std_logic                                   := '0'              ;
    signal  RESET               :           std_logic                                   := '0'              ;
    signal  CLK_SS              :           std_logic                                   := '0'              ;
    signal  PROG_DONE           :           std_logic                                   := '0'              ;
    signal  S_AXIS_TDATA        :           std_logic_Vector ( (N_BYTES*8)-1 downto 0 ) := (others => '0')  ;
    signal  S_AXIS_TKEEP        :           std_logic_Vector (  N_BYTES-1 downto 0 )    := (others => '0')  ;
    signal  S_AXIS_TVALID       :           std_logic                                   := '0'              ;
    signal  S_AXIS_TLAST        :           std_logic                                   := '0'              ;
    signal  S_AXIS_TREADY       :           std_logic                                                       ;
    signal  CCLK                :           std_logic                                                       ;
    signal  DIN                 :           std_logic                                                       ;
    signal  DONE                :           std_logic                                   := '0'              ;
    signal  INIT_B              :           std_logic                                   := '1'              ;
    signal  PROG_B              :           std_logic                                                       ;

    signal  i : integer := 0;

    constant CLK_period : time := 10 ns;

    signal  restored_vector : std_logic_vector ( (N_BYTES*8)-1 downto 0 ) := (others => '0');
    signal  restored_valid : std_logic := '0';
    
    signal  valid_counter : integer := 0;
    constant C_VALID_COUNTER_LIMIT : integer := (N_BYTES*8)-1;
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
            if i < 10 then 
                RESET <= '1';
            else
                RESET <= '0';
            end if;
        end if;
    end process;

    ENABLE_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is 
                when 0      => ENABLE <= '0';
                when 100    => ENABLE <= '1';
                when 101    => ENABLE <= '0';
                when others => ENABLE <= ENABLE;
            end case;
        end if;
    end process;    

    PAUSE       <= x"00000004";
    WORD_LIMIT  <= x"00000100";

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES                                                                 ,
            ASYNC                   =>  false                                                                   ,
            MODE                    =>  "BYTE"          -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  CLK                                                                     ,
            RESET                   =>  RESET                                                                   ,
            
            ENABLE                  =>  ENABLE                                                                  ,
            PAUSE                   =>  PAUSE                                                                   ,
            WORD_LIMIT              =>  WORD_LIMIT                                                              ,
            
            M_AXIS_CLK              =>  CLK                                                                     ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA                                                            ,
            M_AXIS_TKEEP            =>  S_AXIS_TKEEP                                                            ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID                                                           ,
            M_AXIS_TREADY           =>  S_AXIS_TREADY                                                           ,
            M_AXIS_TLAST            =>  S_AXIS_TLAST                                                             
        );


    axis_loader_ss_inst : axis_loader_ss
        generic map (
            WAIT_ABORT_LIMIT    =>  WAIT_ABORT_LIMIT                                                        ,
            ASYNC_MODE          =>  ASYNC_MODE                                                              ,
            N_BYTES             =>  N_BYTES                                                                  
        )
        port map (
            CLK                 =>  CLK                                                                     ,
            RESET               =>  RESET                                                                   ,
            CLK_SS              =>  CLK                                                                     ,
            STS_PROG_GOOD       =>  open                                                                    ,
            STS_PROG_FAIL       =>  open                                                                    ,

            S_AXIS_TDATA        =>  S_AXIS_TDATA                                                            ,
            S_AXIS_TKEEP        =>  S_AXIS_TKEEP                                                            ,
            S_AXIS_TVALID       =>  S_AXIS_TVALID                                                           ,
            S_AXIS_TREADY       =>  S_AXIS_TREADY                                                           ,
            S_AXIS_TLAST        =>  S_AXIS_TLAST                                                            ,
            CCLK                =>  CCLK                                                                    ,
            DIN                 =>  DIN                                                                     ,
            DONE                =>  DONE                                                                    ,
            INIT_B              =>  INIT_B                                                                  ,
            PROG_B              =>  PROG_B                                                                   
        );

    INIT_B_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when 1000  => INIT_B <= '0';
                when 1020  => INIT_B <= '1';
                when others => INIT_B <= INIT_B;
            end case;
        end if;
    end process;

    DONE_Processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when 100000  => DONE <= '1';
                when 100010  => DONE <= '0';
                when others => DONE <= DONE;
            end case;
        end if;
    end process;

    valid_counter_processing : process(CCLK)
    begin
        if CCLK'event AND CCLK = '1' then 
            if valid_counter < C_VALID_COUNTER_LIMIT then 
                valid_counter <= valid_counter + 1;
            else
                valid_counter <= 0;
            end if;
        end if;
    end process;

    restored_vector_processing : process(CCLK)
    begin
        if CCLK'event AND CCLK = '1' then 
            restored_vector((N_BYTES*8)-1 downto 0) <= restored_vector((N_BYTES*8)-2 downto 0) & DIN;
        end if;
    end process;

    restored_valid_processing : process(CCLK)
    begin
        if CCLK'event AND CCLK = '1' then 
            if valid_counter = C_VALID_COUNTER_LIMIT then 
                restored_valid <= '1';
            else
                restored_valid <= '0';
            end if;
        end if;
    end process;




end tb_axis_loader_ss_arch;
