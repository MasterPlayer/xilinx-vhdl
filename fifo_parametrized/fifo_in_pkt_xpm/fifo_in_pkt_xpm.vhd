library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

library UNISIM;
    use UNISIM.VComponents.all;

Library xpm;
    use xpm.vcomponents.all;


entity fifo_in_pkt_xpm is
    generic(
        MEMTYPE         :           string          :=  "distributed"               ;
        DEPTH           :           integer         :=  16                        
    );
    port(
        CLK             :   in      std_logic                                       ;
        RESET           :   in      std_logic                                       ;
        S_AXIS_TVALID   :   in      std_logic                                       ;
        S_AXIS_TLAST    :   in      std_logic                                       ;
        IN_RDEN         :   in      std_logic                                       ;
        IN_EMPTY        :   out     std_logic                                   
    );
end fifo_in_pkt_xpm;



architecture fifo_in_pkt_xpm_arch of fifo_in_pkt_xpm is

    constant VERSION : string := "v1.0";

    constant FIFO_DATA_COUNT_W  :   integer := integer(ceil(log2(real(DEPTH))));

    signal  full        :           std_logic                                       ;
    signal  din         :           std_logic_vector ( 0 downto 0 ) := "1"          ;
    signal  dout        :           std_logic_vector ( 0 downto 0 )                 ;
    signal  wren        :           std_logic                       := '0'          ;

begin

    din                 <=  "1"                                                     ;
    
    wren_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                wren <= '0';
            else
                if S_AXIS_TVALID = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        wren <= '1';
                    else
                        wren <= '0';
                    end if;
                else
                    wren <= '0';
                end if;
            end if;
        end if;
    end process;

    fifo_xpm_pkt_isnt : xpm_fifo_sync
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
            READ_DATA_WIDTH         =>  1                   ,
            READ_MODE               =>  "fwft"              ,
            SIM_ASSERT_CHK          =>  0                   ,
            USE_ADV_FEATURES        =>  "0000"              ,
            WAKEUP_TIME             =>  0                   ,
            WRITE_DATA_WIDTH        =>  1                   ,
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
            rd_data_count           =>  open                ,
            rd_rst_busy             =>  open                ,
            sbiterr                 =>  open                ,
            underflow               =>  open                ,
            wr_ack                  =>  open                ,
            wr_data_count           =>  open                ,
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



end fifo_in_pkt_xpm_arch;
