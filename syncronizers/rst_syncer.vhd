library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


library UNISIM;
    use UNISIM.VComponents.all;

-- set_false_path -to [get_cells -hierarchical -filter {NAME =~ *rst_syncer_inst*/FDPE*}]
entity rst_syncer is
    generic(
        INIT_VALUE                          :           bit             := '1'                                  
    );
    port(
        CLK                                 :   in      std_logic                                               ;
        RESET                               :   in      std_logic                                               ;
        RESET_OUT                           :   out     std_logic                                               
    );
    attribute dont_touch                    :           string                                                  ;
    attribute dont_touch of rst_syncer      :   entity is "true";
end rst_syncer;



architecture rst_syncer_arch of rst_syncer is

    signal  fdpe_0_out                  :           std_logic := '1'            ;
    signal  fdpe_1_out                  :           std_logic := '1'            ;
    signal  fdpe_2_out                  :           std_logic := '1'            ;


    attribute ASYNC_REG                 :           string                      ;
    attribute ASYNC_REG of fdpe_0_out   :           signal is "TRUE"            ;
    attribute ASYNC_REG of fdpe_1_out   :           signal is "TRUE"            ;
    attribute ASYNC_REG of fdpe_2_out   :           signal is "TRUE"            ;

    attribute MAX_FANOUT : integer;
    attribute MAX_FANOUT of fdpe_2_out: signal is 10;
             
begin



    FDPE0_inst : FDPE
        generic map (
            INIT                => INIT_VALUE               ,   -- Initial value of register, '0', '1'
            IS_C_INVERTED       => '0'                      ,   -- Optional inversion for C
            IS_D_INVERTED       => '0'                      ,   -- Optional inversion for D
            IS_PRE_INVERTED     => '0'                          -- Optional inversion for PRE
        )
        port map (
            Q                   => fdpe_0_out               ,   -- 1-bit output: Data
            C                   => CLK                      ,   -- 1-bit input: Clock
            CE                  => '1'                      ,   -- 1-bit input: Clock enable
            D                   => '0'                      ,   -- 1-bit input: Data
            PRE                 => RESET                        -- 1-bit input: Asynchronous preset
        );



    FDPE1_inst : FDPE
        generic map (
            INIT                => INIT_VALUE               ,   -- Initial value of register, '0', '1'
            IS_C_INVERTED       => '0'                      ,   -- Optional inversion for C
            IS_D_INVERTED       => '0'                      ,   -- Optional inversion for D
            IS_PRE_INVERTED     => '0'                          -- Optional inversion for PRE
        )
        port map (
            Q                   => fdpe_1_out               ,   -- 1-bit output: Data
            C                   => CLK                      ,   -- 1-bit input: Clock
            CE                  => '1'                      ,   -- 1-bit input: Clock enable
            D                   => fdpe_0_out               ,   -- 1-bit input: Data
            PRE                 => RESET                        -- 1-bit input: Asynchronous preset
        );



    FDPE2_inst : FDPE
        generic map (
            INIT                => INIT_VALUE               ,   -- Initial value of register, '0', '1'
            IS_C_INVERTED       => '0'                      ,   -- Optional inversion for C
            IS_D_INVERTED       => '0'                      ,   -- Optional inversion for D
            IS_PRE_INVERTED     => '0'                          -- Optional inversion for PRE
        )
        port map (
            Q                   => fdpe_2_out               ,   -- 1-bit output: Data
            C                   => CLK                      ,   -- 1-bit input: Clock
            CE                  => '1'                      ,   -- 1-bit input: Clock enable
            D                   => fdpe_1_out               ,   -- 1-bit input: Data
            PRE                 => RESET                        -- 1-bit input: Asynchronous preset
        );


    RESET_OUT <= fdpe_2_out; 



end rst_syncer_arch;
