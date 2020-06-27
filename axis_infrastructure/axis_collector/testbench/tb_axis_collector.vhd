library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

library UNISIM;
    use UNISIM.VComponents.all;


entity tb_axis_collector is
end tb_axis_collector;



architecture tb_axis_collector_arch of tb_axis_collector is

    constant  N_CHANNELS            :           integer                          := 32              ; -- Number of channels which do segmentation of RAM 
    constant  N_CHANNELS_W          :           integer                          := 5               ; -- Channel width ( must be > log2(N_CHANNELS))
    constant  TUSER_WIDTH           :           integer                          := 3               ;
    constant  SEGMENT_BYTE_SIZE     :           integer                          := 32              ; -- Size of each segment for holding data from each received channel
    constant  N_BYTES_IN            :           integer                          := 4               ; -- Input width in bytes
    constant  N_BYTES_OUT           :           integer                          := 8               ; -- output width in bytes, can be assymetric
    constant  ASYNC_MODE            :           boolean                          := true            ; -- use asyncronous mode
    constant  SEGMENT_MAX_PKTS      :           integer                          := 1               ; -- Number of packets in each segment. 
    constant  ADDR_USE              :           string                           := "full"          ; -- Address part using "full" or "high" 


    component axis_collector
        generic(
            N_CHANNELS              :           integer                          := 32              ; -- Number of channels which do segmentation of RAM 
            N_CHANNELS_W            :           integer                          := 5               ; -- Channel width ( must be > log2(N_CHANNELS))
            TUSER_WIDTH             :           integer                          := 6               ;
            SEGMENT_BYTE_SIZE       :           integer                          := 2048            ; -- Size of each segment for holding data from each received channel
            N_BYTES_IN              :           integer                          := 4               ; -- Input width in bytes
            N_BYTES_OUT             :           integer                          := 32              ; -- output width in bytes, can be assymetric
            ASYNC_MODE              :           boolean                          := true            ; -- use asyncronous mode
            SEGMENT_MAX_PKTS        :           integer                          := 2               ; -- Number of packets in each segment. 
            ADDR_USE                :           string                           := "full"            -- Address part using "full" or "high" 

        );
        port(
            S_AXIS_CLK              :   in      std_logic                                           ;
            S_AXIS_RESET            :   in      std_logic                                           ;
            S_AXIS_TDATA            :   in      std_logic_vector ( (N_BYTES_IN*8)-1 downto 0 )      ;
            S_AXIS_TVALID           :   in      std_logic                                           ;
            S_AXIS_TID              :   in      std_logic_Vector ( N_CHANNELS_W-1 downto 0 )        ;
            S_AXIS_TUSER            :   in      std_logic_vector ( TUSER_WIDTH-1 downto 0 )         ;
            M_AXIS_CLK              :   in      std_logic                                           ;
            M_AXIS_RESET            :   in      std_logic                                           ;
            M_AXIS_TDATA            :   out     std_logic_vector ( (N_BYTES_OUT*8)-1 downto 0 )     ;
            M_AXIS_TID              :   out     std_logic_Vector ( N_CHANNELS_W-1 downto 0 )        ;
            M_AXIS_TVALID           :   out     std_logic                                           ;
            M_AXIS_TREADY           :   in      std_logic                           
        );
    end component;

    signal  S_AXIS_CLK              :           std_logic                                        := '0'                 ;
    signal  S_AXIS_RESET            :           std_logic                                        := '0'                 ;
    signal  S_AXIS_TDATA            :           std_logic_vector ( (N_BYTES_IN*8)-1 downto 0 )   := (others => '0')     ;
    signal  S_AXIS_TVALID           :           std_logic                                        := '0'                 ;
    signal  S_AXIS_TID              :           std_logic_Vector ( N_CHANNELS_W-1 downto 0 )     := (others => '1')     ;
    signal  S_AXIS_TUSER            :           std_logic_vector ( TUSER_WIDTH-1 downto 0 )      := (others => '0')     ;
    signal  M_AXIS_CLK              :           std_logic                                        := '0'                 ;
    signal  M_AXIS_RESET            :           std_logic                                        := '0'                 ;
    signal  M_AXIS_TDATA            :           std_logic_vector ( (N_BYTES_OUT*8)-1 downto 0 )                         ;
    signal  M_AXIS_TID              :           std_logic_Vector ( N_CHANNELS_W-1 downto 0 )                            ;
    signal  M_AXIS_TVALID           :           std_logic                                                               ;
    signal  M_AXIS_TREADY           :           std_logic                                        := '0'                 ;

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

    signal  enable                  :           std_logic                        := '0'             ;
    signal  pause                   :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  word_limit              :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;


    constant S_CLK_PERIOD : time := 10 ns;
    constant M_CLK_PERIOD : time := 10 ns;

    signal  i_sclk : integer := 0;

    signal  i_sclk_loop : integer := -1;

begin

    S_AXIS_CLK <= not S_AXIS_CLK after S_CLK_PERIOD/2;
    M_AXIS_CLK <= not M_AXIS_CLK after M_CLK_PERIOD/2;

    i_sclk_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            i_sclk <= i_sclk + 1;
        end if;
    end process;

    i_sclk_loop_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if i_sclk > 1000 then 
                if i_sclk_loop < 2000 then 
                    i_sclk_loop <= i_sclk_loop + 1;
                else
                    i_sclk_loop <= 0;
                end if;
            else
                i_sclk_loop <= -1;
            end if;
        end if;
    end process;

    S_AXIS_RESET_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if i_sclk < 10 then 
                S_AXIS_RESET <= '1';
            else
                S_AXIS_RESET <= '0';
            end if;
        end if;
    end process; 


    axis_collector_inst : axis_collector
        generic map (
            N_CHANNELS              =>  N_CHANNELS                          ,
            N_CHANNELS_W            =>  N_CHANNELS_W                        ,
            TUSER_WIDTH             =>  TUSER_WIDTH                         ,
            SEGMENT_BYTE_SIZE       =>  SEGMENT_BYTE_SIZE                   ,
            N_BYTES_IN              =>  N_BYTES_IN                          ,
            N_BYTES_OUT             =>  N_BYTES_OUT                         ,
            ASYNC_MODE              =>  ASYNC_MODE                          ,
            SEGMENT_MAX_PKTS        =>  SEGMENT_MAX_PKTS                    ,
            ADDR_USE                =>  ADDR_USE                             
        )
        port map (
            S_AXIS_CLK              =>  S_AXIS_CLK                          ,
            S_AXIS_RESET            =>  S_AXIS_RESET                        ,

            S_AXIS_TDATA            =>  S_AXIS_TDATA                        ,
            S_AXIS_TVALID           =>  S_AXIS_TVALID                       ,
            S_AXIS_TID              =>  S_AXIS_TID                          ,
            S_AXIS_TUSER            =>  S_AXIS_TUSER                        ,
            
            M_AXIS_CLK              =>  M_AXIS_CLK                          ,
            M_AXIS_RESET            =>  M_AXIS_RESET                        ,
            M_AXIS_TDATA            =>  M_AXIS_TDATA                        ,
            M_AXIS_TID              =>  M_AXIS_TID                          ,
            M_AXIS_TVALID           =>  M_AXIS_TVALID                       ,
            M_AXIS_TREADY           =>  M_AXIS_TREADY                        
        );

    M_AXIS_TREADY <= '1';

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  N_BYTES_IN                          ,
            ASYNC                   =>  false                               ,
            MODE                    =>  "SINGLE"                             -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  S_AXIS_CLK                          ,
            RESET                   =>  S_AXIS_RESET                        ,
            
            ENABLE                  =>  ENABLE                              ,
            PAUSE                   =>  PAUSE                               ,
            WORD_LIMIT              =>  WORD_LIMIT                          ,
            
            M_AXIS_CLK              =>  S_AXIS_CLK                          ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA                        ,
            M_AXIS_TKEEP            =>  open                                ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID                       ,
            M_AXIS_TREADY           =>  '1'                                 ,
            M_AXIS_TLAST            =>  open                                 
        );

    PAUSE_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            PAUSE <= x"00000000";
        end if;
    end process;

    WORD_LIMIT_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            WORD_LIMIT <= x"00000008";
        end if;
    end process;

    ENABLE_processing : process(S_AXIS_CLK) 
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if i_sclk_loop = 0 then 
                ENABLE <= '1';
            else
                ENABLE <= '0';
            end if;
        end if;
    end process;

    S_AXIS_TID_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            --if ENABLE = '1' then 
            if S_AXIS_TVALID = '1' then 
                S_AXIS_TID <= S_AXIS_TID + 1;
            else
                S_AXIS_TID <= S_AXIS_TID;
            end if;
        end if;
    end process;

    S_AXIS_TUSER_processing : process(S_AXIS_CLK)
    begin
        if S_AXIS_CLK'event AND S_AXIS_CLK = '1' then 
            if S_AXIS_TVALID = '1' then 
                S_AXIS_TUSER <= S_AXIS_TUSER + 1;
            else
                S_AXIS_TUSER <= S_AXIS_TUSER;
            end if;
        end if;
    end process;

end tb_axis_collector_arch;
