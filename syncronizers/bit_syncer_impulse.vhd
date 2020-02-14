
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


library UNISIM;
    use UNISIM.VComponents.all;



-- set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_syncer_impulse*/GEN_VECTOR[*].meta_0_inst}]
-- FREQ CLK_SRC must be less than CLK_DST, else lost of data events
entity bit_syncer_impulse is
    generic(
        INIT_VALUE          :           bit_vector ( 4 downto 0 ) := "00000"  ;
        IMPULSE_EVENT       :           STRING                    := "0_to_1" -- "1_to_0" "BOTH" 
    );
    port(
        CLK_SRC             :   in      std_logic                                               ;
        CLK_DST             :   in      std_logic                                               ;
        DATA_IN             :   in      std_logic                                               ;
        DATA_OUT            :   out     std_logic                                                
    );
    attribute dont_touch    : string;
    attribute dont_touch of bit_syncer_impulse  : entity is "true";

end bit_syncer_impulse;



architecture bit_syncer_impulse_arch of bit_syncer_impulse is

    constant  init_value_v : std_logic_vector := to_stdlogicvector(INIT_VALUE);

    signal  meta_0_out                  :           std_logic := init_value_v(0);
    signal  meta_1_out                  :           std_logic := init_value_v(1);
    signal  meta_2_out                  :           std_logic := init_value_v(2);
    signal  meta_3_out                  :           std_logic := init_value_v(3);
    signal  meta_4_out                  :           std_logic := init_value_v(4);
    signal  d_meta_4_out                :           std_logic := init_value_v(4);

    signal  data_vector_src             :           std_logic := '0'            ;


    attribute ASYNC_REG     : string;
    attribute ASYNC_REG of data_vector_src   : signal is "TRUE";
    attribute ASYNC_REG of meta_0_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_1_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_2_out   : signal is "TRUE";
    attribute ASYNC_REG of meta_3_out   : signal is "TRUE";

    attribute shreg_extract : string;
    attribute shreg_extract of data_vector_src : signal is "no";
    attribute shreg_extract of meta_0_out : signal is "no";
    attribute shreg_extract of meta_1_out : signal is "no";
    attribute shreg_extract of meta_2_out : signal is "no";
    attribute shreg_extract of meta_3_out : signal is "no";
    attribute shreg_extract of meta_4_out : signal is "no";

begin



    fdre_src_inst : FDRE
        generic map (
            INIT                =>  '0'                                                                     ,   -- Initial value of register, '0', '1'
            IS_C_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for C
            IS_D_INVERTED       =>  '0'                                                                     ,   -- Optional inversion for D
            IS_R_INVERTED       =>  '0'                                                                         -- Optional inversion for R
        )
        port map (
            C                   =>  CLK_SRC                                                                 ,   -- 1-bit input: Clock
            Q                   =>  data_vector_src                                                         ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  DATA_IN                                                                 ,   -- 1-bit input: Data
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
            Q                   =>  meta_0_out                                                              ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  data_vector_src                                                         ,   -- 1-bit input: Data
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
            Q                   =>  meta_1_out                                                              ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  meta_0_out                                                              ,   -- 1-bit input: Data
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
            Q                   =>  meta_2_out                                                              ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  meta_1_out                                                              ,   -- 1-bit input: Data
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
            Q                   =>  meta_3_out                                                              ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  meta_2_out                                                              ,   -- 1-bit input: Data
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
            Q                   =>  meta_4_out                                                              ,   -- 1-bit output: Data
            CE                  =>  '1'                                                                     ,   -- 1-bit input: Clock enable
            D                   =>  meta_3_out                                                              ,   -- 1-bit input: Data
            R                   =>  '0'                                                                         -- 1-bit input: Synchronous reset
        );



    d_meta_4_out_processing : process(CLK_DST)
    begin
        if CLK_DST'event AND CLK_DST = '1' then 
            d_meta_4_out <= meta_4_out;
        end if;
    end process;



    EVENT_01_GEN : if IMPULSE_EVENT = "0_TO_1" generate 
        DATA_OUT <= '1' when meta_4_out = '1' and d_meta_4_out = '0' else '0';
    end generate;

    EVENT_10_GEN : if IMPULSE_EVENT = "1_TO_0" generate 
        DATA_OUT <= '1' when meta_4_out = '0' and d_meta_4_out = '1' else '0';
    end generate;

    EVENT_BOTH_GEN : if IMPULSE_EVENT = "BOTH" generate 
        DATA_OUT <= '1' when (meta_4_out = '1' and d_meta_4_out = '0') or (meta_4_out = '0' and d_meta_4_out = '1') else '0';
    end generate;



end bit_syncer_impulse_arch;
