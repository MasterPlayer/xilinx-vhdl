library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

library xpm;
    use xpm.vcomponents.all;

entity sdpram_xpm is
    generic(
        WORDA_WIDTH         :           integer                 := 32       ; -- word width in bits
        WORDB_WIDTH         :           integer                 := 256      ;
        SIZE_IN_BYTES       :           integer                 := 2048     ; -- Size in bytes for one channel
        N_CHANNELS          :           integer                 := 32       ; 
        ASYNC               :           boolean                 := true     ;
        ADDRA_WIDTH         :           integer                 := 14       ;
        ADDRB_WIDTH         :           integer                 := 11       ;
        MEMTYPE             :           string                  := "distributed" -- block ultra
    );
    port(
        CLKA                :   in      std_logic                                       ;
        CLKB                :   in      std_logic                                       ;
        RESETB              :   in      std_logic                                       ;
        ADDRA               :   in      std_logic_Vector ( ADDRA_WIDTH-1 downto 0 )     ;
        DINA                :   in      std_logic_Vector ( WORDA_WIDTH-1 downto 0 )     ;
        WEA                 :   in      std_logic                                       ;
        ADDRB               :   in      std_logic_Vector ( ADDRB_WIDTH-1 downto 0 )     ;
        DOUTB               :   out     std_logic_vector ( WORDB_WIDTH-1 downto 0 )     
    );
end sdpram_xpm;



architecture sdpram_xpm_arch of sdpram_xpm is

    constant MEM_DEPTH              :           integer := (SIZE_IN_BYTES * N_CHANNELS)*8;
    constant READ_DATA_WIDTH_B      :           integer := DOUTB'length;

begin

    
    CLOCKING_MODE_ASYNC_GEN : if ASYNC = true generate 
        xpm_memory_sdpram_inst : xpm_memory_sdpram
            generic map (
                ADDR_WIDTH_A                =>  ADDRA_WIDTH             ,   -- DECIMAL
                ADDR_WIDTH_B                =>  ADDRB_WIDTH             ,   -- DECIMAL
                AUTO_SLEEP_TIME             =>  0                       ,   -- DECIMAL
                BYTE_WRITE_WIDTH_A          =>  WORDA_WIDTH             ,   -- DECIMAL
                CLOCKING_MODE               =>  "independent_clock"     ,   -- String
                ECC_MODE                    =>  "no_ecc"                ,   -- String
                MEMORY_INIT_FILE            =>  "none"                  ,   -- String
                MEMORY_INIT_PARAM           =>  "0"                     ,   -- String
                MEMORY_OPTIMIZATION         =>  "true"                  ,   -- String
                MEMORY_PRIMITIVE            =>  MEMTYPE                 ,   -- String ||
                MEMORY_SIZE                 =>  MEM_DEPTH               ,   -- DECIMAL
                MESSAGE_CONTROL             =>  0                       ,   -- DECIMAL
                READ_DATA_WIDTH_B           =>  READ_DATA_WIDTH_B       ,   -- DECIMAL
                READ_LATENCY_B              =>  3                       ,   -- DECIMAL
                READ_RESET_VALUE_B          =>  "0"                     ,   -- String
                RST_MODE_A                  =>  "ASYNC"                 ,   -- String
                RST_MODE_B                  =>  "ASYNC"                 ,   -- String
                USE_EMBEDDED_CONSTRAINT     =>  0                       ,   -- DECIMAL
                USE_MEM_INIT                =>  0                       ,   -- DECIMAL
                WAKEUP_TIME                 =>  "disable_sleep"         ,   -- String
                WRITE_DATA_WIDTH_A          =>  WORDA_WIDTH             ,   -- DECIMAL
                WRITE_MODE_B                =>  "read_first"                -- String
            )
            port map (
                dbiterrb                    =>  open                    ,   -- 1-bit output: Status signal to indicate double bit error occurrence on the data output of port B.
                doutb                       =>  doutb                   ,   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
                sbiterrb                    =>  open                    ,   -- 1-bit output: Status signal to indicate single bit error occurrence on the data output of port B.
                addra                       =>  ADDRA                   ,   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
                addrb                       =>  ADDRB                   ,   -- ADDR_WIDTH_B-bit input: Address for port B read operations.
                clka                        =>  CLKA                    ,   -- 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
                clkb                        =>  CLKB                    ,   -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
                dina                        =>  DINA                    ,   -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
                ena                         =>  '1'                     ,   -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
                enb                         =>  '1'                     ,   -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
                injectdbiterra              =>  '0'                     ,   -- 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                injectsbiterra              =>  '0'                     ,   -- 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                regceb                      =>  '1'                     ,   -- 1-bit input: Clock Enable for the last register stage on the output data path.
                rstb                        =>  RESETB                  ,   -- 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
                sleep                       =>  '0'                     ,   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
                wea(0)                      =>  wea                         -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.

            );
    end generate;


    
    CLOCKING_MODE_SYNC_GEN : if ASYNC = false generate 
        xpm_memory_sdpram_inst : xpm_memory_sdpram
            generic map (
                ADDR_WIDTH_A                =>  ADDRA_WIDTH             ,   -- DECIMAL
                ADDR_WIDTH_B                =>  ADDRB_WIDTH             ,   -- DECIMAL
                AUTO_SLEEP_TIME             =>  0                       ,   -- DECIMAL
                BYTE_WRITE_WIDTH_A          =>  WORDA_WIDTH             ,   -- DECIMAL
                CLOCKING_MODE               =>  "common_clock"          ,   -- String
                ECC_MODE                    =>  "no_ecc"                ,   -- String
                MEMORY_INIT_FILE            =>  "none"                  ,   -- String
                MEMORY_INIT_PARAM           =>  "0"                     ,   -- String
                MEMORY_OPTIMIZATION         =>  "true"                  ,   -- String
                MEMORY_PRIMITIVE            =>  MEMTYPE                 ,   -- String ||
                MEMORY_SIZE                 =>  MEM_DEPTH               ,   -- DECIMAL
                MESSAGE_CONTROL             =>  0                       ,   -- DECIMAL
                READ_DATA_WIDTH_B           =>  READ_DATA_WIDTH_B       ,   -- DECIMAL
                READ_LATENCY_B              =>  2                       ,   -- DECIMAL
                READ_RESET_VALUE_B          =>  "0"                     ,   -- String
                RST_MODE_A                  =>  "SYNC"                  ,   -- String
                RST_MODE_B                  =>  "SYNC"                  ,   -- String
                USE_EMBEDDED_CONSTRAINT     =>  0                       ,   -- DECIMAL
                USE_MEM_INIT                =>  0                       ,   -- DECIMAL
                WAKEUP_TIME                 =>  "disable_sleep"         ,   -- String
                WRITE_DATA_WIDTH_A          =>  WORDA_WIDTH             ,   -- DECIMAL
                WRITE_MODE_B                =>  "read_first"                -- String
            )
            port map (
                dbiterrb                    =>  open                    ,   -- 1-bit output: Status signal to indicate double bit error occurrence on the data output of port B.
                doutb                       =>  doutb                   ,   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
                sbiterrb                    =>  open                    ,   -- 1-bit output: Status signal to indicate single bit error occurrence on the data output of port B.
                addra                       =>  ADDRA                   ,   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
                addrb                       =>  ADDRB                   ,   -- ADDR_WIDTH_B-bit input: Address for port B read operations.
                clka                        =>  CLKA                    ,   -- 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
                clkb                        =>  CLKB                    ,   -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
                dina                        =>  DINA                    ,   -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
                ena                         =>  '1'                     ,   -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
                enb                         =>  '1'                     ,   -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
                injectdbiterra              =>  '0'                     ,   -- 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                injectsbiterra              =>  '0'                     ,   -- 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                regceb                      =>  '1'                     ,   -- 1-bit input: Clock Enable for the last register stage on the output data path.
                rstb                        =>  RESETB                  ,   -- 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
                sleep                       =>  '0'                     ,   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
                wea(0)                      =>  wea                         -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.

            );
    end generate;





end sdpram_xpm_arch;
