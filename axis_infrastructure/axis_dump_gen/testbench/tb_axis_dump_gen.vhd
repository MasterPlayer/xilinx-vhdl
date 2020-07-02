library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";


library UNISIM;
    use UNISIM.VComponents.all;



entity tb_axis_dump_gen is
end tb_axis_dump_gen;



architecture tb_axis_dump_gen_arch of tb_axis_dump_gen is
    
    constant CLK_period : time := 10 ns;

    constant  N_BYTES               :           integer                         := 2                ;
    constant  ASYNC                 :           boolean                         := false            ;
    constant  SIMPLE_COUNTER        :           boolean                         := true             ;
    constant  FILL_ZEROS            :           boolean                         := false            ;


    signal  i : integer := 0;

    component axis_dump_gen
        generic(
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

    signal  CLK                     :           std_logic                                    := '0'                 ;
    signal  RESET                   :           std_logic                                    := '0'                 ;

    signal  ENABLE                  :           std_logic                                    := '0'                 ;
    signal  PAUSE                   :           std_logic_Vector ( 31 downto 0 )             := (others => '0')     ;
    signal  WORD_LIMIT              :           std_logic_Vector ( 31 downto 0 )             := (others => '0')     ;

    signal  M_AXIS_CLK              :           std_logic                                    := '0'                 ;
    signal  M_AXIS_TDATA            :           std_logic_Vector ( (N_BYTES*8)-1 downto 0 )         ;
    signal  M_AXIS_TKEEP            :           std_logic_Vector ( N_BYTES-1 downto 0 )             ;
    signal  M_AXIS_TVALID           :           std_logic                                           ;
    signal  M_AXIS_TREADY           :           std_logic                                           ;
    signal  M_AXIS_TLAST            :           std_logic                                           ;

    signal  i_rdy                   :           integer                                      := 0                   ;

begin

    CLK <= not CLK after CLK_period/2;

    i_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            i <= i + 1;
        end if;
    end process;

    i_rdy_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i_rdy < 16 then 
                i_rdy <= i_rdy + 1;
            else
                i_rdy <= 0;
            end if;
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

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES                                                     ,
            ASYNC                   =>  ASYNC                                                       ,
            MODE                    =>  "SINGLE"          -- "SINGLE", "ZEROS", "BYTE"        );
        )
        port map (
            CLK                     =>  CLK                                                         ,
            RESET                   =>  RESET                                                       ,
            
            ENABLE                  =>  ENABLE                                                      ,
            PAUSE                   =>  PAUSE                                                       ,
            WORD_LIMIT              =>  WORD_LIMIT                                                  ,
            
            M_AXIS_CLK              =>  M_AXIS_CLK                                                  ,
            M_AXIS_TDATA            =>  M_AXIS_TDATA                                                ,
            M_AXIS_TKEEP            =>  M_AXIS_TKEEP                                                ,
            M_AXIS_TVALID           =>  M_AXIS_TVALID                                               ,
            M_AXIS_TREADY           =>  M_AXIS_TREADY                                               ,
            M_AXIS_TLAST            =>  M_AXIS_TLAST                                                 
        );

    ENABLE_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i > 1000 then
                if i < 100000 then 
                    ENABLE <= '1';
                else
                    ENABLE <= '0';    
                end if;
            else
                ENABLE <= '0';
            end if; 
        end if;
    end process;

    PAUSE_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i < 5000 then 
                PAUSE <= x"00000001";
            else
                PAUSE <= x"00000001";
            end if;
        end if;
    end process;

    WORD_LIMIT_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i < 10000 then 
                WORD_LIMIT <= x"00000100";
            else
                WORD_LIMIT <= x"00000100";
            end if;
        end if;
    end process;

    --M_AXIS_TREADY <= '1' when i_rdy < 1 else '0';
    M_AXIS_TREADY <= '1';




end tb_axis_dump_gen_arch;
