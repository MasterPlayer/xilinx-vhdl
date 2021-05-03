library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_Logic_unsigned.all;
    use ieee.std_logic_arith.all;

entity tb_axis_micron_nor_ctrlr_x4 is
end tb_axis_micron_nor_ctrlr_x4;


architecture Behavioral of tb_axis_micron_nor_ctrlr_x4 is

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

    signal  ENABLE              :           std_logic                        := '0'             ;
    signal  PAUSE               :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;
    signal  WORD_LIMIT          :           std_logic_Vector ( 31 downto 0 ) := (others => '0') ;

    component axis_micron_nor_ctrlr_x4
        generic (
            MODE                :           string := "STARTUPE"; -- "STARTUPE - connect to STARTUPE primitive, "DIRECT - connect to pins" 
            ASYNC               :           boolean := true  ;
            SWAP_NIBBLE         :           boolean := true   
        );
        port(
            S_AXIS_CLK          :   in      std_logic                           ;
            S_AXIS_RESET        :   in      std_logic                           ;

            S_AXIS_CMD          :   in      std_logic_Vector (  7 downto 0 )    ;
            S_AXIS_CMD_TSIZE    :   in      std_logic_vector ( 31 downto 0 )    ;
            S_AXIS_CMD_TADDR    :   in      std_logic_vector ( 31 downto 0 )    ;
            S_AXIS_CMD_TVALID   :   in      std_logic                           ;
            S_AXIS_CMD_TREADY   :   out     std_logic                           ;

            S_AXIS_TDATA        :   in      std_logic_vector (  7 downto 0 )    ;
            S_AXIS_TVALID       :   in      std_logic                           ;
            S_AXIS_TREADY       :   out     std_logic                           ;
            S_AXIS_TLAST        :   in      std_Logic                           ;

            M_AXIS_TVALID       :   out     std_Logic                           ;
            M_AXIS_TDATA        :   out     std_logic_Vector (  7 downto 0 )    ;
            M_AXIS_TREADY       :   in      std_logic                           ;
            M_AXIS_TLAST        :   out     std_logic                           ;

            SPI_CLK             :   in      std_logic                           ;

            FLASH_STATUS        :   out     std_Logic_vector (  7 downto 0 )    ;
            FLASH_STATUS_VALID  :   out     std_logic                           ;

            BUSY                :   out     std_logic                           ;

            C                   :   out     std_logic                           ;
            RESET_OUT           :   out     std_logic                           ;
            DQ_I                :   in      std_Logic_Vector ( 3 downto 0 )     ;
            DQ_T                :   out     std_Logic_Vector ( 3 downto 0 )     ;
            DQ_O                :   out     std_Logic_Vector ( 3 downto 0 )     ;

            S                   :   out     std_logic                           
        );
    end component;


    signal  CLK          :           std_logic                        := '0'                 ;
    signal  RESET        :           std_logic                        := '0'                 ;

    signal  S_AXIS_CMD          :           std_logic_Vector (  7 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_CMD_TSIZE    :           std_logic_vector ( 31 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_CMD_TADDR    :           std_logic_vector ( 31 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_CMD_TVALID   :           std_logic                        := '0'                 ;
    signal  S_AXIS_CMD_TREADY   :           std_logic                                               ;

    signal  S_AXIS_TDATA        :           std_logic_vector (  7 downto 0 ) := (others => '0')     ;
    signal  S_AXIS_TVALID       :           std_logic                        := '0'                 ;
    signal  S_AXIS_TREADY       :           std_logic                                               ;
    signal  S_AXIS_TLAST        :           std_Logic                        := '0'                 ;

    signal  M_AXIS_TVALID       :           std_Logic                                               ;
    signal  M_AXIS_TDATA        :           std_logic_Vector (  7 downto 0 )                        ;
    signal  M_AXIS_TREADY       :           std_logic                        := '0'                 ;
    signal  M_AXIS_TLAST        :           std_logic                                               ;

    signal  SPI_CLK             :           std_logic                        := '0'                 ;

    signal  FLASH_STATUS        :           std_Logic_vector (  7 downto 0 )                        ;
    signal  FLASH_STATUS_VALID  :           std_logic                                               ;

    signal  BUSY                :           std_logic                                               ;

    signal  C                   :           std_logic                                               ;
    signal  RESET_OUT           :           std_logic                                               ;
    signal  DQ_I                :           std_Logic_Vector ( 3 downto 0 ) := (others => '0')      ;
    signal  DQ_T                :           std_Logic_Vector ( 3 downto 0 )                         ;
    signal  DQ_O                :           std_Logic_Vector ( 3 downto 0 )                         ;

    signal  S                   :           std_logic                                               ;

    signal  i                   :           integer                         := 0                    ;

begin

    CLK <= not CLK after 5 ns;
    

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

    cmd_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when 2000 => S_AXIS_CMD <= x"3E"; S_AXIS_CMD_TSIZE <= x"00000100"; S_AXIS_CMD_TADDR <= x"DEADACAB"; S_AXIS_CMD_TVALID <= '1';
                when others => S_AXIS_CMD <= S_AXIS_CMD; S_AXIS_CMD_TSIZE <= S_AXIS_CMD_TSIZE; S_AXIS_CMD_TADDR <= S_AXIS_CMD_TADDR; S_AXIS_CMD_TVALID <= '0';
            end case;
        end if;
    end process;

    axis_micron_nor_ctrlr_x4_inst : axis_micron_nor_ctrlr_x4
        generic map (
            MODE                =>  "DIRECT"                    , -- "STARTUPE - connect to STARTUPE primitive, "DIRECT - connect to pins" 
            ASYNC               =>  false                       ,
            SWAP_NIBBLE         =>  false                         
        )
        port map (
            S_AXIS_CLK          =>  CLK                         ,
            S_AXIS_RESET        =>  RESET                       ,

            S_AXIS_CMD          =>  S_AXIS_CMD                  ,
            S_AXIS_CMD_TSIZE    =>  S_AXIS_CMD_TSIZE            ,
            S_AXIS_CMD_TADDR    =>  S_AXIS_CMD_TADDR            ,
            S_AXIS_CMD_TVALID   =>  S_AXIS_CMD_TVALID           ,
            S_AXIS_CMD_TREADY   =>  S_AXIS_CMD_TREADY           ,

            S_AXIS_TDATA        =>  S_AXIS_TDATA                ,
            S_AXIS_TVALID       =>  S_AXIS_TVALID               ,
            S_AXIS_TREADY       =>  S_AXIS_TREADY               ,
            S_AXIS_TLAST        =>  S_AXIS_TLAST                ,

            M_AXIS_TVALID       =>  M_AXIS_TVALID               ,
            M_AXIS_TDATA        =>  M_AXIS_TDATA                ,
            M_AXIS_TREADY       =>  M_AXIS_TREADY               ,
            M_AXIS_TLAST        =>  M_AXIS_TLAST                ,

            SPI_CLK             =>  CLK                         ,

            FLASH_STATUS        =>  FLASH_STATUS                ,
            FLASH_STATUS_VALID  =>  FLASH_STATUS_VALID          ,

            BUSY                =>  BUSY                        ,

            C                   =>  C                           ,
            RESET_OUT           =>  RESET_OUT                   ,
            DQ_I                =>  DQ_I                        ,
            DQ_T                =>  DQ_T                        ,
            DQ_O                =>  DQ_O                        ,

            S                   =>  S                            
        );

    M_AXIS_TREADY <= '1';


    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  1                ,
            ASYNC                   =>  false            ,
            MODE                    =>  "BYTE"              -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  CLK      ,
            RESET                   =>  RESET    ,
            
            ENABLE                  =>  ENABLE          ,
            PAUSE                   =>  PAUSE           ,
            WORD_LIMIT              =>  WORD_LIMIT      ,
            
            M_AXIS_CLK              =>  CLK      ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA    ,
            M_AXIS_TKEEP            =>  open            ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID   ,
            M_AXIS_TREADY           =>  S_AXIS_TREADY   ,
            M_AXIS_TLAST            =>  S_AXIS_TLAST     
        );

    gen_ctrlr_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is 
                when 100 => ENABLE <= '1'; PAUSE <= x"00000000"; WORD_LIMIT <= x"00000100";
                when others => ENABLE <= '0'; PAUSE <= PAUSE; WORD_LIMIT <= WORD_LIMIT;
            end case;
        end if;
    end process;

    DQ_I_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when others => DQ_I <= x"0";
            end case;
        end if;
    end process;


end Behavioral;
