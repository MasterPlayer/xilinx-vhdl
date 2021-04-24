library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;

entity tb_axis_loader_ssm is
end tb_axis_loader_ssm;



architecture Behavioral of tb_axis_loader_ssm is


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

    signal  ENABLE                  :           std_logic                         := '0'            ;
    signal  PAUSE                   :           std_logic_Vector ( 31 downto 0 )  := (others => '0');
    signal  WORD_LIMIT              :           std_logic_Vector ( 31 downto 0 )  := (others => '0');


    component axis_loader_ssm
        generic(
            N_BYTES             :           integer := 1                                    ;
            ASYNC_MODE          :           boolean := true                                 ;
            CONTROL             :           string  := "SIZE"                               ;  -- "SIZE" "LAST"
            WAIT_DONE_LIMIT     :           integer := 10000                                 
        );
        port(
            CLK                 :   in      std_logic                                       ;
            RESET               :   in      std_logic                                       ;

            STS_DONE            :   out     std_logic                                       ;
            STS_EVENT           :   out     std_logic                                       ;

            SM_CLK              :   in      std_logic                                       ;
            SM_RESET            :   in      std_logic                                       ;
            
            S_AXIS_TDATA        :   in      std_logic_Vector ( (N_BYTES*8)-1 downto 0 )     ;
            S_AXIS_TKEEP        :   in      std_logic_Vector ( N_BYTES-1 downto 0 )         ;
            S_AXIS_TDEST        :   in      std_logic_Vector ( 7 downto 0 )                 ;
            S_AXIS_TVALID       :   in      std_logic                                       ;
            S_AXIS_TREADY       :   out     std_logic                                       ;
            S_AXIS_TLAST        :   in      std_logic                                       ;
            
            BITSTREAM_SIZE      :   in      std_logic_Vector ( 31 downto 0 )                ;
            BITSTREAM_COUNTER   :   out     std_logic_vector ( 31 downto 0 )                ;
            -- FPGA configuration port 
            CCLK                :   out     std_logic                                       ;
            DATA                :   out     std_logic_Vector (  7 downto 0 )                ;
            PROG_B              :   out     std_logic                                       ;
            INIT_B              :   in      std_Logic                                       ;
            DONE                :   in      std_logic                                       ;
            CS                  :   out     std_logic                                        
        );
    end component;

    signal  CLK                 :           std_logic                                   := '0'                  ;
    signal  RESET               :           std_logic                                   := '0'                  ;

    signal  STS_DONE            :           std_logic                                                           ;
    signal  STS_EVENT           :           std_logic                                                           ;

    signal  SM_CLK              :           std_logic                                   := '0'                  ;
    signal  SM_RESET            :           std_logic                                   := '0'                  ;

    signal  S_AXIS_TDATA        :           std_logic_Vector (  7 downto 0 )            := (others => '0')      ;
    signal  S_AXIS_TKEEP        :           std_logic_Vector (  0 downto 0 )            := (others => '0')      ;
    signal  S_AXIS_TDEST        :           std_logic_Vector (  7 downto 0 )            := (others => '0')      ;
    signal  S_AXIS_TVALID       :           std_logic                                   := '0'                  ;
    signal  S_AXIS_TREADY       :           std_logic                                                           ;
    signal  S_AXIS_TLAST        :           std_logic                                   := '0'                  ;

    signal  BITSTREAM_SIZE      :           std_logic_Vector ( 31 downto 0 )            := (others => '0')      ;
    signal  BITSTREAM_COUNTER   :           std_logic_vector ( 31 downto 0 )                                    ;

    signal  CCLK                :           std_logic                                                           ;
    signal  DATA                :           std_logic_Vector (  7 downto 0 )                                    ;
    signal  PROG_B              :           std_logic                                                           ;
    signal  INIT_B              :           std_Logic                                   := '0'                  ;
    signal  DONE                :           std_logic                                   := '0'                  ;
    signal  CS                  :           std_logic                                                           ;

    signal  GEN_CLK             :           std_logic                                   := '0'                  ;

    constant gen_clk_period     :           time                                        := 250 ns               ;
    constant clk_period         :           time                                        := 10 ns                ;
    constant sm_clk_period      :           time                                        := 100 ns               ;

    signal  i_gen_clk           :           integer                                     := 0                    ;
    signal  i_clk               :           integer                                     := 0                    ;
    signal  i_sm_clk            :           integer                                     := 0                    ;

    signal  i_done              :           integer                                     := 0                    ;

begin

    clk <= not clk after clk_period/2;
    sm_clk <= not sm_clk after sm_clk_period/2; 
    gen_clk <= not gen_clk after gen_clk_period/2;

    i_clk_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            i_clk <= i_clk + 1;
        end if;
    end process;

    i_sm_clk_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            i_sm_clk <= i_sm_clk + 1;
        end if;
    end process;

    i_gen_clk_processing : process(GEN_CLK)
    begin
        if GEN_CLK'event AND GEN_CLK = '1' then 
            i_gen_clk <= i_gen_clk + 1;
        end if;
    end process;

    sm_reset_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            if i_sm_clk < 5 then 
                SM_RESET <= '1';
            else
                SM_RESET <= '0';
            end if;
        end if;
    end process;

    RESET <= SM_RESET;

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES             =>  1                                       ,
            ASYNC               =>  true                                    ,
            MODE                =>  "BYTE"                                      -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                 =>  GEN_CLK                                 ,
            RESET               =>  RESET                                   ,
            
            ENABLE              =>  ENABLE                                  ,
            PAUSE               =>  PAUSE                                   ,
            WORD_LIMIT          =>  WORD_LIMIT                              ,
            
            M_AXIS_CLK          =>  CLK                                     ,
            M_AXIS_TDATA        =>  S_AXIS_TDATA                            ,
            M_AXIS_TKEEP        =>  S_AXIS_TKEEP                            ,
            M_AXIS_TVALID       =>  S_AXIS_TVALID                           ,
            M_AXIS_TREADY       =>  S_AXIS_TREADY                           ,
            M_AXIS_TLAST        =>  S_AXIS_TLAST                             
        );

    config_generator_processing : process(GEN_CLK)
    begin
        if GEN_CLK'event AND GEN_CLK = '1' then 
            case i_gen_clk is
                when 1000   => ENABLE <= '1'; PAUSE <= x"00000000"; WORD_LIMIT <= x"00001000";
                when others => ENABLE <= '0'; PAUSE <= PAUSE; WORD_LIMIT <= WORD_LIMIT;
            end case;
        end if;
    end process;

    bitstream_size_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i_clk is
                when 200    => BITSTREAM_SIZE <= x"00001000";
                when others => BITSTREAM_SIZE <= BITSTREAM_SIZE;
            end case;
        end if;
    end process;

    axis_loader_ssm_inst : axis_loader_ssm
        generic map (
            N_BYTES             =>  1                                       ,
            ASYNC_MODE          =>  true                                    ,
            CONTROL             =>  "SIZE"                                  , -- "SIZE" "LAST"
            WAIT_DONE_LIMIT     =>  10000                                   
        )
        port map (
            CLK                 =>  CLK                                     ,
            RESET               =>  RESET                                   ,

            STS_DONE            =>  STS_DONE                                ,
            STS_EVENT           =>  STS_EVENT                               ,

            SM_CLK              =>  SM_CLK                                  ,
            SM_RESET            =>  SM_RESET                                ,
            
            S_AXIS_TDATA        =>  S_AXIS_TDATA                            ,
            S_AXIS_TKEEP        =>  S_AXIS_TKEEP                            ,
            S_AXIS_TDEST        =>  S_AXIS_TDEST                            ,
            S_AXIS_TVALID       =>  S_AXIS_TVALID                           ,
            S_AXIS_TREADY       =>  S_AXIS_TREADY                           ,
            S_AXIS_TLAST        =>  S_AXIS_TLAST                            ,
            
            BITSTREAM_SIZE      =>  BITSTREAM_SIZE                          ,
            BITSTREAM_COUNTER   =>  BITSTREAM_COUNTER                       ,

            CCLK                =>  CCLK                                    ,
            DATA                =>  DATA                                    ,
            PROG_B              =>  PROG_B                                  ,
            INIT_B              =>  INIT_B                                  ,
            DONE                =>  DONE                                    ,
            CS                  =>  CS                                       
        );

    INIT_B_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            if PROG_B = '0' then 
                INIT_B <= '0';
            else
                INIT_B <= '1';
            end if;
        end if;
    end process;

    i_done_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            if CS = '0' then 
                i_done <= i_done + 1;
            else
                i_done <= i_done;
            end if;
        end if;
    end process;

    DONE_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            if i_done > 20000 then 
                DONE <= '1';
            else
                DONE <= '0';
            end if;
        end if;
    end process;

end Behavioral;
