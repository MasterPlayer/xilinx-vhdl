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
        INPUT_DATA_WIDTH    :           integer         :=  16                              ;
        OUTPUT_DATA_WIDTH   :           integer         :=  16                              ;
        MEMTYPE             :           String          :=  "block"                         ;
        DEPTH               :           integer         :=  16                              
    );
    port(
        CLK             :   in      std_logic                                               ;
        RESET           :   in      std_logic                                               ;
        
        S_AXIS_TDATA    :   in      std_logic_Vector ( INPUT_DATA_WIDTH-1 downto 0 )        ;
        --S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
        S_AXIS_TVALID   :   in      std_logic                                               ;
        --S_AXIS_TLAST    :   in      std_logic                                       ;
        S_AXIS_TREADY   :   out     std_logic                                               ;

        IN_DOUT_DATA    :   out     std_logic_Vector ( OUTPUT_DATA_WIDTH-1 downto 0 )       ;
        --IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
        --IN_DOUT_LAST    :   out     std_logic                                       ;
        IN_RDEN         :   in      std_logic                                               ;
        IN_EMPTY        :   out     std_logic                                               ;

        DBG_FULL        :   out     std_logic                                               ;

        DATA_COUNT      :   out     std_logic_Vector ( 31 downto 0 )                         -- Размер в байтах


    );
end fifo_in_sync_pfull_xpm;



architecture fifo_in_sync_pfull_xpm_arch of fifo_in_sync_pfull_xpm is


    constant VERSION : string := "v1.1";

    --constant FIFO_WIDTH         :   integer := DATA_WIDTH + ((DATA_WIDTH/8) + 1)    ;
    --constant FIFO_WIDTH         :   integer := DATA_WIDTH                           ;
    constant FIFO_DATA_COUNT_W  :   integer := integer(ceil(log2(real(DEPTH))))             ;

    signal  full        :           std_logic                                               ;
    signal  din         :           std_logic_vector ( INPUT_DATA_WIDTH-1 downto 0 )        ;
    signal  dout        :           std_logic_vector ( OUTPUT_DATA_WIDTH-1 downto 0 )       ;
    
    signal  wren        :           std_logic  := '0'                                       ;

    signal  rd_data_count   : std_logic_Vector ( FIFO_DATA_COUNT_W-1 downto 0 ) ;
    signal  wr_data_count   : std_logic_Vector ( FIFO_DATA_COUNT_W-1 downto 0 ) ;

    signal  data_count_reg   :           std_logic_Vector ( 31 downto 0 ) := (others => '0');

    constant  INPUT_DATA_WIDTH_VEC      : std_logic_Vector ( 31 downto 0 ) := conv_std_logic_Vector( INPUT_DATA_WIDTH, 32 );
    constant  OUTPUT_DATA_WIDTH_VEC     : std_logic_Vector ( 31 downto 0 ) := conv_std_logic_Vector( OUTPUT_DATA_WIDTH, 32 );

    constant  data_inc          :           std_logic_vector ( 31 downto 0 ) := EXT(INPUT_DATA_WIDTH_VEC(31 downto 3), 32);
    constant  data_dec          :           std_logic_vector ( 31 downto 0 ) := EXT(OUTPUT_DATA_WIDTH_VEC(31 downto 3), 32);
    signal  one_time            :           std_logic_vector ( 31 downto 0 ) := (others => '0');

begin

    


    S_AXIS_TREADY <= not (full);
    DBG_FULL <= full;

    wren <= '1' when full = '0' and S_AXIS_TVALID = '1' else '0' ;
    --wren <= '1' when S_AXIS_TVALID = '1' else '0' ;

    DATA_COUNT <= EXT(data_count_reg, DATA_COUNT'length);
    --din <= S_AXIS_TLAST & S_AXIS_TKEEP & S_AXIS_TDATA;
    din <= S_AXIS_TDATA;
    
    IN_DOUT_DATA <= dout( OUTPUT_DATA_WIDTH-1 downto 0 ) ;
    --IN_DOUT_KEEP <= dout( ((DATA_WIDTH + (DATA_WIDTH/8))-1) downto DATA_WIDTH );
    --IN_DOUT_LAST <= dout( DATA_WIDTH + (DATA_WIDTH/8));

    IN_GREAT_OUT : if data_inc > data_dec generate

        one_time_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                one_time <= data_inc - data_dec;
            end if;
        end process;

        data_count_reg_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    data_count_reg <= (others => '0');
                else
                    if wren = '1' then 
                        if IN_RDEN = '1' then 
                            data_count_reg <= data_count_reg + one_time;
                        else
                            data_count_reg <= data_count_reg + data_inc;
                        end if;
                    elsif IN_RDEN = '1' then 
                        if data_count_reg = 0 then 
                            data_count_reg <= data_count_reg;
                        else
                            data_count_reg <= data_count_reg - data_dec;
                        end if ;
                    else
                        data_count_reg <= data_count_reg;
                    end if;
                end if;
            end if;
        end process;

    end generate;

    OUT_GREAT_IN : if data_inc <= data_dec generate

        one_time_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                one_time <= data_dec - data_inc;
            end if;
        end process;

        data_count_reg_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    data_count_reg <= (others => '0');
                else
                    if wren = '1' then 
                        if IN_RDEN = '1' then 
                            if data_count_reg < one_time then 
                                data_count_reg <= (others => '0');
                            else    
                                data_count_reg <= data_count_reg - one_time;
                            end if;
                        else
                            data_count_reg <= data_count_reg + data_inc;
                        end if;
                    elsif IN_RDEN = '1' then 
                        if data_count_reg = 0 then 
                            data_count_reg <= data_count_reg;
                        else
                            data_count_reg <= data_count_reg - data_dec;
                        end if ;
                    else
                        data_count_reg <= data_count_reg;
                    end if;
                end if;
            end if;
        end process;

    end generate; 

    fifo_in_sync_xpm_isnt : xpm_fifo_sync
        generic map (
            DOUT_RESET_VALUE        =>  "0"                 ,
            ECC_MODE                =>  "no_ecc"            ,
            FIFO_MEMORY_TYPE        =>  MEMTYPE             ,
            FIFO_READ_LATENCY       =>  0                   ,
            FIFO_WRITE_DEPTH        =>  DEPTH               ,
            FULL_RESET_VALUE        =>  0                   ,
            PROG_EMPTY_THRESH       =>  10                  ,
            PROG_FULL_THRESH        =>  10                  ,
            RD_DATA_COUNT_WIDTH     =>  FIFO_DATA_COUNT_W   ,
            READ_DATA_WIDTH         =>  OUTPUT_DATA_WIDTH   ,
            READ_MODE               =>  "fwft"              ,
            USE_ADV_FEATURES        =>  x"0000"             ,
            WAKEUP_TIME             =>  0                   ,
            WRITE_DATA_WIDTH        =>  INPUT_DATA_WIDTH    ,
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

            
end fifo_in_sync_pfull_xpm_arch;
