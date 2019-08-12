
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


library UNISIM;
    use UNISIM.VComponents.all;



-- set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_syncer_fdre*/GEN_VECTOR[*].meta_0_inst}]
entity bit_syncer_fdre is
    generic(
        DATA_WIDTH          :           integer := 8                                            ;
        INIT_VALUE          :           bit_vector ( 4 downto 0 ) := "00000" 
    );
    port(
        CLK_SRC             :   in      std_logic                                               ;
        CLK_DST             :   in      std_logic                                               ;
        DATA_IN             :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )              ;
        DATA_OUT            :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )              
    );
    attribute dont_touch    : string;
    attribute dont_touch of bit_syncer_fdre  : entity is "true";

end bit_syncer_fdre;



architecture bit_syncer_fdre_arch of bit_syncer_fdre is

    signal  meta_0_out                  :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;
    signal  meta_1_out                  :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;
    signal  meta_2_out                  :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;
    signal  meta_3_out                  :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;
    signal  meta_4_out                  :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;

    signal  data_vector_src             :           std_logic_Vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;


    attribute ASYNC_REG     : string;
    attribute ASYNC_REG of data_vector_src   : signal is "TRUE";
    attribute ASYNC_REG of meta_0_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_1_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_2_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_3_out   : signal is "TRUE";
    --attribute ASYNC_REG of meta_4_out   : signal is "TRUE";



    attribute MAX_FANOUT : integer;
    attribute MAX_FANOUT of meta_4_out: signal is 10;
                
            

begin


    GEN_VECTOR : for i in 0 to DATA_WIDTH-1 generate 

        fdre_src_inst : FDRE
            generic map (
                INIT                =>  '0'                                                                     ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_SRC                                                                 ,   -- 1-bit input: Clock
                Q                   =>  data_vector_src(i)                                                      ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  DATA_IN(i)                                                              ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

        meta_0_inst : FDRE
            generic map (
                INIT                =>  INIT_VALUE(0)                                                           ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_DST                                                                 ,   -- 1-bit input: Clock
                Q                   =>  meta_0_out(i)                                                           ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  data_vector_src(i)                                                      ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

        meta_1_inst : FDRE
            generic map (
                INIT                =>  INIT_VALUE(1)                                                           ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_DST                                                                 ,   -- 1-bit input: Clock
                Q                   =>  meta_1_out(i)                                                           ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  meta_0_out(i)                                                           ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

        meta_2_inst : FDRE
            generic map (
                INIT                =>  INIT_VALUE(2)                                                           ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_DST                                                                 ,   -- 1-bit input: Clock
                Q                   =>  meta_2_out(i)                                                           ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  meta_1_out(i)                                                           ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

        meta_3_inst : FDRE
            generic map (
                INIT                =>  INIT_VALUE(3)                                                           ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_DST                                                                 ,   -- 1-bit input: Clock
                Q                   =>  meta_3_out(i)                                                           ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  meta_2_out(i)                                                           ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

        meta_4_inst : FDRE
            generic map (
                INIT                =>  INIT_VALUE(4)                                                           ,   -- Initial value of register, '0', '1'
                IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
                IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
                IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
            )
            port map (
                C                   =>  CLK_DST                                                                 ,   -- 1-bit input: Clock
                Q                   =>  meta_4_out(i)                                                           ,   -- 1-bit output: Data
                CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
                D                   =>  meta_3_out(i)                                                           ,   -- 1-bit input: Data
                R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
            );

    end generate;



    DATA_OUT <= meta_4_out;




end bit_syncer_fdre_arch;
