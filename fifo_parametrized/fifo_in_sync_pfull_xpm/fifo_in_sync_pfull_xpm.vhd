

-- XPM_FIFO instantiation template for Synchronous FIFO configurations
-- Refer to the targeted device family architecture libraries guide for XPM_FIFO documentation
-- =======================================================================================================================

-- Parameter usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Parameter name       | Data type          | Restrictions, if applicable                                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | DOUT_RESET_VALUE     | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset value of read data path.                                                                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "no_ecc" - Disables ECC                                                                                           |
-- |   "en_ecc" - Enables both ECC Encoder and Decoder                                                                   |
-- |                                                                                                                     |
-- | NOTE: ECC_MODE should be "no_ecc" if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed, ultra. Default value = auto.  |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Designate the fifo memory primitive (resource type) to use-                                                         |
-- |                                                                                                                     |
-- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
-- |   "block"- Block RAM FIFO                                                                                           |
-- |   "distributed"- Distributed RAM FIFO                                                                               |
-- |   "ultra"- URAM FIFO                                                                                                |
-- |                                                                                                                     |
-- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with FIFO_MEMORY_TYPE set to "auto".|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_READ_LATENCY    | Integer            | Range: 0 - 100. Default value = 1.                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Number of output register stages in the read data path                                                              |
-- |                                                                                                                     |
-- |   If READ_MODE = "fwft", then the only applicable value is 0                                                        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_WRITE_DEPTH     | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the FIFO Write Depth, must be power of two                                                                  |
-- |                                                                                                                     |
-- |   In standard READ_MODE, the effective depth = FIFO_WRITE_DEPTH                                                     |
-- |   In First-Word-Fall-Through READ_MODE, the effective depth = FIFO_WRITE_DEPTH+2                                    |
-- |                                                                                                                     |
-- | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FULL_RESET_VALUE     | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Sets full, almost_full and prog_full to FULL_RESET_VALUE during reset                                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | PROG_EMPTY_THRESH    | Integer            | Range: 3 - 4194304. Default value = 10.                                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the minimum number of read words in the FIFO at or below which prog_empty is asserted.                    |
-- |                                                                                                                     |
-- |   Min_Value = 3 + (READ_MODE_VAL*2)                                                                                 |
-- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2)                                                              |
-- |                                                                                                                     |
-- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
-- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
-- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | PROG_FULL_THRESH     | Integer            | Range: 3 - 4194301. Default value = 10.                                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the maximum number of write words in the FIFO at or above which prog_full is asserted.                    |
-- |                                                                                                                     |
-- |   Min_Value = 3 + (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))                                              |
-- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))                           |
-- |                                                                                                                     |
-- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
-- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
-- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the width of rd_data_count. To reflect the correct value, the width should be log2(FIFO_READ_DEPTH)+1.    |
-- |                                                                                                                     |
-- |   FIFO_READ_DEPTH = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH/READ_DATA_WIDTH                                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_DATA_WIDTH      | Integer            | Range: 1 - 4096. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the width of the read data port, dout                                                                       |
-- |                                                                                                                     |
-- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
-- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
-- |                                                                                                                     |
-- | NOTE:                                                                                                               |
-- |                                                                                                                     |
-- |   READ_DATA_WIDTH should be equal to WRITE_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
-- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_MODE            | String             | Allowed values: std, fwft. Default value = std.                         |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "std"- standard read mode                                                                                         |
-- |   "fwft"- First-Word-Fall-Through read mode                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Enables data_valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
-- | prog_full, overflow features.                                                                                       |
-- |                                                                                                                     |
-- |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag;     Default value of this bit is 1                        |
-- |   Setting USE_ADV_FEATURES[1]  to 1 enables prog_full flag;    Default value of this bit is 1                       |
-- |   Setting USE_ADV_FEATURES[2]  to 1 enables wr_data_count;     Default value of this bit is 1                       |
-- |   Setting USE_ADV_FEATURES[3]  to 1 enables almost_full flag;  Default value of this bit is 0                       |

-- |   Setting USE_ADV_FEATURES[4]  to 1 enables wr_ack flag;       Default value of this bit is 0                       |

-- |   Setting USE_ADV_FEATURES[8]  to 1 enables underflow flag;    Default value of this bit is 1                       |
-- |   Setting USE_ADV_FEATURES[9]  to 1 enables prog_empty flag;   Default value of this bit is 1                       |
-- |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count;     Default value of this bit is 1                       |
-- |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |

-- |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag;   Default value of this bit is 0                       |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WAKEUP_TIME          | Integer            | Range: 0 - 2. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   0 - Disable sleep                                                                                                 |
-- |   2 - Use Sleep Pin                                                                                                 |
-- |                                                                                                                     |
-- | NOTE: WAKEUP_TIME should be 0 if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_DATA_WIDTH     | Integer            | Range: 1 - 4096. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the width of the write data port, din                                                                       |
-- |                                                                                                                     |
-- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
-- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
-- |                                                                                                                     |
-- | NOTE:                                                                                                               |
-- |                                                                                                                     |
-- |   WRITE_DATA_WIDTH should be equal to READ_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
-- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the width of wr_data_count. To reflect the correct value, the width should be log2(FIFO_WRITE_DEPTH)+1.   |
-- +---------------------------------------------------------------------------------------------------------------------+

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | almost_empty   | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Almost Empty : When asserted, this signal indicates that only one more read can be performed before the FIFO goes to|
-- | empty.                                                                                                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | almost_full    | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Almost Full: When asserted, this signal indicates that only one more write can be performed before the FIFO is full.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | data_valid     | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data Valid: When asserted, this signal indicates that valid data is available on the output bus (dout).        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dbiterr        | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Double Bit Error: Indicates that the ECC decoder detected a double-bit error and data in the FIFO core is corrupted.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | din            | Input     | WRITE_DATA_WIDTH                      | wr_clk  | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Data: The input data bus used when writing the FIFO.                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dout           | Output    | READ_DATA_WIDTH                       | wr_clk  | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data: The output data bus is driven when reading the FIFO.                                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | empty          | Output    | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Empty Flag: When asserted, this signal indicates that the FIFO is empty.                                            |
-- | Read requests are ignored when the FIFO is empty, initiating a read while empty is not destructive to the FIFO.     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | full           | Output    | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Full Flag: When asserted, this signal indicates that the FIFO is full.                                              |
-- | Write requests are ignored when the FIFO is full, initiating a write when the FIFO is full is not destructive       |
-- | to the contents of the FIFO.                                                                                        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectdbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Double Bit Error Injection: Injects a double bit error if the ECC feature is used on block RAMs or                  |
-- | UltraRAM macros.                                                                                                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectsbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Single Bit Error Injection: Injects a single bit error if the ECC feature is used on block RAMs or                  |
-- | UltraRAM macros.                                                                                                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | overflow       | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Overflow: This signal indicates that a write request (wren) during the prior clock cycle was rejected,              |
-- | because the FIFO is full. Overflowing the FIFO is not destructive to the contents of the FIFO.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | prog_empty     | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Programmable Empty: This signal is asserted when the number of words in the FIFO is less than or equal              |
-- | to the programmable empty threshold value.                                                                          |
-- | It is de-asserted when the number of words in the FIFO exceeds the programmable empty threshold value.              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | prog_full      | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Programmable Full: This signal is asserted when the number of words in the FIFO is greater than or equal            |
-- | to the programmable full threshold value.                                                                           |
-- | It is de-asserted when the number of words in the FIFO is less than the programmable full threshold value.          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_data_count  | Output    | RD_DATA_COUNT_WIDTH                   | wr_clk  | NA          | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data Count: This bus indicates the number of words read from the FIFO.                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_en          | Input     | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Enable: If the FIFO is not empty, asserting this signal causes data (on dout) to be read from the FIFO.        |
-- |                                                                                                                     |
-- |   Must be held active-low when rd_rst_busy is active high.                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_rst_busy    | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Reset Busy: Active-High indicator that the FIFO read domain is currently in a reset state.                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rst            | Input     | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset: Must be synchronous to wr_clk. The clock(s) can be unstable at the time of applying reset, but reset must be released only after the clock(s) is/are stable.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sbiterr        | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Single Bit Error: Indicates that the ECC decoder detected and fixed a single-bit error.                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Dynamic power saving- If sleep is High, the memory/fifo block is in power saving mode.                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | underflow      | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Underflow: Indicates that the read request (rd_en) during the previous clock cycle was rejected                     |
-- | because the FIFO is empty. Under flowing the FIFO is not destructive to the FIFO.                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_ack         | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Acknowledge: This signal indicates that a write request (wr_en) during the prior clock cycle is succeeded.    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_clk         | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write clock: Used for write operation. wr_clk must be a free running clock.                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_data_count  | Output    | WR_DATA_COUNT_WIDTH                   | wr_clk  | NA          | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Data Count: This bus indicates the number of words written into the FIFO.                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_en          | Input     | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Enable: If the FIFO is not full, asserting this signal causes data (on din) to be written to the FIFO         |
-- |                                                                                                                     |
-- |   Must be held active-low when rst or wr_rst_busy or rd_rst_busy is active high                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_rst_busy    | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Reset Busy: Active-High indicator that the FIFO write domain is currently in a reset state.                   |
-- +---------------------------------------------------------------------------------------------------------------------+
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

Library xpm;
    use xpm.vcomponents.all;


-- Внимание : ДЛЯ ДАННОЙ ОЧЕРЕДИ НЕ ИСПОЛЬЗУЕТСЯ KEEP/LAST 
entity fifo_in_sync_pfull_xpm is
    generic(
        DATA_WIDTH      :           integer         :=  16                          ;
        MEMTYPE         :           String          :=  "block"                     ;
        DEPTH           :           integer         :=  16                           
    );
    port(
        CLK             :   in      std_logic                                       ;
        RESET           :   in      std_logic                                       ;
        
        S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
        --S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
        S_AXIS_TVALID   :   in      std_logic                                       ;
        --S_AXIS_TLAST    :   in      std_logic                                       ;
        S_AXIS_TREADY   :   out     std_logic                                       ;

        IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
        --IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
        --IN_DOUT_LAST    :   out     std_logic                                       ;
        IN_RDEN         :   in      std_logic                                       ;
        IN_EMPTY        :   out     std_logic                                       ;

        DATA_COUNT      :   out     std_logic_Vector ( 31 downto 0 )                

    );
end fifo_in_sync_pfull_xpm;



architecture fifo_in_sync_pfull_xpm_arch of fifo_in_sync_pfull_xpm is


    constant VERSION : string := "v1.0";

    --constant FIFO_WIDTH         :   integer := DATA_WIDTH + ((DATA_WIDTH/8) + 1)    ;
    constant FIFO_WIDTH         :   integer := DATA_WIDTH                           ;
    constant FIFO_DATA_COUNT_W  :   integer := integer(ceil(log2(real(DEPTH))))     ;

    signal  full        :           std_logic                                       ;
    signal  din         :           std_logic_vector ( FIFO_WIDTH-1 downto 0 ) ;
    signal  dout        :           std_logic_vector ( FIFO_WIDTH-1 downto 0 ) ;
    
    signal  wren        :           std_logic ;

    signal  rd_data_count   : std_logic_Vector ( FIFO_DATA_COUNT_W-1 downto 0 ) ;
    signal  wr_data_count   : std_logic_Vector ( FIFO_DATA_COUNT_W-1 downto 0 ) ;

    signal  data_count_reg   :           std_logic_Vector ( 31 downto 0 ) := (others => '0');

begin


    S_AXIS_TREADY <= not (full);
    wren <= '1' when full = '0' and S_AXIS_TVALID = '1' else '0' ;

    DATA_COUNT <= EXT(data_count_reg, DATA_COUNT'length);
    --din <= S_AXIS_TLAST & S_AXIS_TKEEP & S_AXIS_TDATA;
    din <= S_AXIS_TDATA;
    
    IN_DOUT_DATA <= dout( DATA_WIDTH-1 downto 0 ) ;
    --IN_DOUT_KEEP <= dout( ((DATA_WIDTH + (DATA_WIDTH/8))-1) downto DATA_WIDTH );
    --IN_DOUT_LAST <= dout( DATA_WIDTH + (DATA_WIDTH/8));

    data_count_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                data_count_reg <= (others => '0');
            else
                if wren = '1' then 
                    if IN_RDEN = '1' then 
                        data_count_reg <= data_count_reg;
                    else
                        data_count_reg <= data_count_reg + 1;
                    end if;
                elsif IN_RDEN = '1' then 
                    data_count_reg <= data_count_reg - 1;
                else
                    data_count_reg <= data_count_reg;
                end if;
            end if;
        end if;
    end process;

    fifo_in_sync_xpm_isnt : xpm_fifo_sync
        generic map (
            DOUT_RESET_VALUE        =>  "0"                 ,
            ECC_MODE                =>  "no_ecc"            ,
            FIFO_MEMORY_TYPE        =>  MEMTYPE             ,
            FIFO_READ_LATENCY       =>  0                   ,
            FIFO_WRITE_DEPTH        =>  DEPTH               ,
            FULL_RESET_VALUE        =>  1                   ,
            PROG_EMPTY_THRESH       =>  10                  ,
            PROG_FULL_THRESH        =>  10                  ,
            RD_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   ,
            READ_DATA_WIDTH         =>  FIFO_WIDTH          ,
            READ_MODE               =>  "fwft"              ,
            USE_ADV_FEATURES        =>  x"0000"             ,
            WAKEUP_TIME             =>  0                   ,
            WRITE_DATA_WIDTH        =>  FIFO_WIDTH          ,
            WR_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   
        )
        port map (
            almost_empty            =>  open                ,
            almost_full             =>  open                ,
            data_valid              =>  open                ,
            dbiterr                 =>  open                ,
            dout                    =>  DOUT                ,
            empty                   =>  IN_EMPTY            ,
            full                    =>  full                ,
            overflow                =>  open                ,
            prog_empty              =>  open                ,
            prog_full               =>  open                ,
            rd_data_count           =>  rd_data_count       ,
            rd_rst_busy             =>  open                ,
            sbiterr                 =>  open                ,
            underflow               =>  open                ,
            wr_ack                  =>  open                ,
            wr_data_count           =>  wr_data_count       ,
            wr_rst_busy             =>  open                ,
            din                     =>  din                 ,
            injectdbiterr           =>  '0'                 ,
            injectsbiterr           =>  '0'                 ,
            rd_en                   =>  IN_RDEN             ,
            rst                     =>  RESET               ,
            sleep                   =>  '0'                 ,
            wr_clk                  =>  CLK                 ,
            wr_en                   =>  wren                 
        );


   -- End of xpm_fifo_sync_inst instantiation
                
            
end fifo_in_sync_pfull_xpm_arch;
