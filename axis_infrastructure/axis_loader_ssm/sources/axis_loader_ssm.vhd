library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_Logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;

entity axis_loader_ssm is
    generic(
        N_BYTES             :           integer := 1                                    ;
        ASYNC_MODE          :           boolean := true                                 ;
        CONTROL             :           string  := "SIZE"                               ;   -- "SIZE" "LAST"
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
end axis_loader_ssm;



architecture axis_loader_ssm_arch of axis_loader_ssm is

    type fsm is(
        IDLE_ST             ,
        RESET_FPGA_ST       ,
        WAIT_FOR_INITB_ST   ,
        LD_BITSTRM_ST       ,
        WAIT_DONE_ST        
    );

    signal  current_state   :           fsm := IDLE_ST;

    component fifo_in_async_user_xpm 
        generic(
            CDC_SYNC        :           integer         :=  4                                   ;
            DATA_WIDTH      :           integer         :=  16                                  ;
            USER_WIDTH      :           integer         :=  1                                   ;
            MEMTYPE         :           String          :=  "block"                             ;
            DEPTH           :           integer         :=  16                                  
        );
        port(
            S_AXIS_CLK      :   in      std_logic                                               ;
            S_AXIS_RESET    :   in      std_logic                                               ;
            M_AXIS_CLK      :   in      std_logic                                               ;
            
            S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
            S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )          ;
            S_AXIS_TUSER    :   in      std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
            S_AXIS_TVALID   :   in      std_logic                                               ;
            S_AXIS_TLAST    :   in      std_logic                                               ;
            S_AXIS_TREADY   :   out     std_logic                                               ;

            IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
            IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
            IN_DOUT_USER    :   out     std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
            IN_DOUT_LAST    :   out     std_logic                                               ;
            IN_RDEN         :   in      std_logic                                               ;
            IN_EMPTY        :   out     std_logic                                                
        );
    end component;

    component fifo_in_sync_user_xpm 
        generic(
            DATA_WIDTH      :           integer         :=  16                                  ;
            USER_WIDTH      :           integer         :=  1                                   ;
            MEMTYPE         :           String          :=  "block"                             ;
            DEPTH           :           integer         :=  16                                  
        );
        port(
            CLK                     :   in      std_logic                                               ;
            RESET                   :   in      std_logic                                               ;
            
            S_AXIS_TDATA            :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
            S_AXIS_TKEEP            :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )          ;
            S_AXIS_TUSER            :   in      std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
            S_AXIS_TVALID           :   in      std_logic                                               ;
            S_AXIS_TLAST            :   in      std_logic                                               ;
            S_AXIS_TREADY           :   out     std_logic                                               ;

            IN_DOUT_DATA            :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )              ;
            IN_DOUT_KEEP            :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 )         ;
            IN_DOUT_USER            :   out     std_logic_vector ( USER_WIDTH-1 downto 0 )              ;
            IN_DOUT_LAST            :   out     std_logic                                               ;
            IN_RDEN                 :   in      std_logic                                               ;
            IN_EMPTY                :   out     std_logic                                                
        );
    end component;

    signal  in_dout_data            :           std_logic_Vector (  7 downto 0 )                        ;
    signal  in_dout_data_swapped    :           std_logic_Vector (  7 downto 0 )                        ;
    signal  in_dout_keep            :           std_logic_Vector (  0 downto 0 )                        ;
    signal  in_dout_user            :           std_logic_vector (  7 downto 0 )                        ;
    signal  in_dout_last            :           std_logic                                               ;
    signal  in_rden                 :           std_logic                           := '0'              ;
    signal  in_empty                :           std_logic                                               ;

    signal  saved_dest              :           std_logic_VectoR (  7 downto 0 )    := (others => '0')  ;

    signal  cs_reg                  :           std_logic                           := '1'              ;

    signal  prog_b_reg              :           std_logic                           := '1'              ;

    signal  data_reg                :           std_logic_vector (  7 downto 0 )    := (others => '0')  ;

    signal  bitstream_size_cnt      :           std_logic_vector ( 31 downto 0 )    := (others => '0')  ;
    signal  bitstream_size_reg      :           std_logic_Vector ( 31 downto 0 )    := (others => '0')  ;

    signal  sts_done_reg            :           std_logic                           := '0'              ;
    signal  sts_event_reg           :           std_logic                           := '0'              ;

    signal  wait_done_limit_reg     :           std_logic_vector ( 31 downto 0 )    := (others => '0')  ;

begin



    STS_DONE  <= sts_done_reg;
    STS_EVENT <= sts_event_reg;

    BITSTREAM_COUNTER <= bitstream_size_cnt;

    bitstream_size_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            bitstream_size_reg <= BITSTREAM_SIZE-1;
        end if;
    end process;

    DATA <= data_reg;

    CS <= cs_reg;

    in_dout_data_swapped_loop : for i in 0 to 7 generate 
        in_dout_data_swapped(7-i) <= in_dout_data(i);
    end generate;

    sts_event_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when RESET_FPGA_ST => 
                    if INIT_B = '0' then 
                        sts_event_reg <= '1';
                    else
                        sts_event_reg <= '0';
                    end if;

                when WAIT_DONE_ST => 
                    if DONE = '1' then 
                        sts_event_reg <= '1';
                    else
                        sts_event_reg <= '0';
                    end if;

                when others => 
                    sts_event_reg <= '0';

            end case;
        end if;
    end process;

    sts_done_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is

                when RESET_FPGA_ST => 
                    if INIT_B = '0' then 
                        sts_done_reg <= '0';
                    else
                        sts_done_reg <= sts_done_reg;
                    end if;

                when WAIT_DONE_ST => 
                    if DONE = '1' then 
                        sts_done_reg <= '1';
                    else
                        sts_done_reg <= sts_done_reg;
                    end if;

                when others => 
                    sts_done_reg <= sts_done_reg;

            end case;
        end if;
    end process;

    ODDRE1_inst : ODDRE1
        generic map (
            IS_C_INVERTED   =>  '0'             ,   -- Optional inversion for C
            IS_D1_INVERTED  =>  '0'             ,   -- Unsupported, do not use
            IS_D2_INVERTED  =>  '0'             ,   -- Unsupported, do not use
            SIM_DEVICE      =>  "ULTRASCALE"    ,   -- Set the device version (ULTRASCALE)
            SRVAL           =>  '0'                 -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
        )
        port map (
            Q               =>  CCLK            ,   -- 1-bit output: Data output to IOB
            C               =>  SM_CLK          ,   -- 1-bit input: High-speed clock input
            D1              =>  '0'             ,   -- 1-bit input: Parallel data input 1
            D2              =>  '1'             ,   -- 1-bit input: Parallel data input 2
            SR              =>  '0'                 -- 1-bit input: Active High Async Reset
        );

    PROG_B <= prog_b_reg;

    BITSTREAM_SIZE_CONTROL_GEN : if CONTROL = "SIZE" generate 

        current_state_processing : process(SM_CLK)
        begin
            if SM_CLK'event AND SM_CLK = '1' then 
                if SM_RESET = '1' then 
                    current_state <= IDLE_ST;
                else                
                    case current_state is
                        -- if input fifo isn't empty
                        when IDLE_ST => 
                            if in_empty = '0' then 
                                current_state <= RESET_FPGA_ST;
                            else
                                current_state <= current_state;
                            end if;

                        -- do reset selected FPGA over PROG_B signal 
                        -- performing reset while INITB isnt asserted
                        -- for selected fpga 
                        when RESET_FPGA_ST => 
                            if INIT_B = '0' then 
                                current_state <= WAIT_FOR_INITB_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when WAIT_FOR_INITB_ST => 
                            if INIT_B = '1' then 
                                current_state <= LD_BITSTRM_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when LD_BITSTRM_ST => 
                            if in_empty = '0' then 
                                if bitstream_size_cnt = bitstream_size_reg then 
                                    current_state <= WAIT_DONE_ST;
                                else
                                    current_state <= current_state;
                                end if;
                            else
                                current_state <= current_state;
                            end if;

                        when WAIT_DONE_ST => 
                            if DONE = '1' then 
                                current_state <= IDLE_ST;
                            else
                                if WAIT_DONE_LIMIT = 0 then 
                                    current_state <= current_state;
                                else
                                    if wait_done_limit_reg < WAIT_DONE_LIMIT then 
                                        current_state <= current_state;
                                    else
                                        current_state <= IDLE_ST;
                                    end if;
                                end if;
                            end if;

                        when others => 
                            current_state <= current_state;

                    end case;
                end if;
            end if;
        end process;
    end generate;

    LAST_CONTROL_GEN : if CONTROL = "LAST" generate 

        current_state_processing : process(SM_CLK)
        begin
            if SM_CLK'event AND SM_CLK = '1' then 
                if SM_RESET = '1' then 
                    current_state <= IDLE_ST;
                else                
                    case current_state is
                        when IDLE_ST => 
                            if in_empty = '0' then 
                                current_state <= RESET_FPGA_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when RESET_FPGA_ST => 
                            if INIT_B = '0' then 
                                current_state <= WAIT_FOR_INITB_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when WAIT_FOR_INITB_ST => 
                            if INIT_B = '1' then 
                                current_state <= LD_BITSTRM_ST;
                            else
                                current_state <= current_state;
                            end if;

                        when LD_BITSTRM_ST => 
                            if in_empty = '0' then 
                                if in_dout_last = '1' then 
                                    current_state <= WAIT_DONE_ST;
                                else
                                    current_state <= current_state;
                                end if;
                            else
                                current_state <= current_state;
                            end if;

                        when WAIT_DONE_ST => 
                            if DONE = '1' then 
                                current_state <= IDLE_ST;
                            else
                                if WAIT_DONE_LIMIT = 0 then 
                                    current_state <= current_state;
                                else
                                    if wait_done_limit_reg < WAIT_DONE_LIMIT then 
                                        current_state <= current_state;
                                    else
                                        current_state <= IDLE_ST;
                                    end if;
                                end if;
                            end if;

                        when others => 
                            current_state <= current_state;

                    end case;
                end if;
            end if;
        end process;
    end generate;

    wait_done_limit_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when WAIT_DONE_ST => 
                    if wait_done_limit_reg < WAIT_DONE_LIMIT then 
                        wait_done_limit_reg <= wait_done_limit_reg + 1;
                    else
                        wait_done_limit_reg <= wait_done_limit_reg;
                    end if;

                when others => 
                    wait_done_limit_reg <= (others => '0');

            end case;
        end if;
    end process;

    bitstream_size_cnt_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is

                when IDLE_ST => 
                    bitstream_size_cnt <= (others => '0');

                when LD_BITSTRM_ST => 
                    if in_empty = '0' then 
                        if (bitstream_size_cnt < bitstream_size_reg) then 
                            bitstream_size_cnt <= bitstream_size_cnt + 1;
                        else
                            bitstream_size_cnt <= bitstream_size_cnt;    
                        end if;
                    else
                        bitstream_size_cnt <= bitstream_size_cnt;
                    end if;

                when others => 
                    bitstream_size_cnt <= bitstream_size_cnt;
            end case;
        end if;
    end process;

    data_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when LD_BITSTRM_ST => 
                    if in_empty = '0' then 
                        data_reg <= in_dout_data_swapped;
                    else
                        data_reg <= data_reg;
                    end if;

                when others => 
                    data_reg <= data_reg;

            end case;
        end if;
    end process;

    cs_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when IDLE_ST => 
                    cs_reg <= '1';

                when LD_BITSTRM_ST =>
                    if in_empty = '0' then 
                        cs_reg <= '0';
                    else
                        cs_reg <= '1';
                    end if;

                when WAIT_DONE_ST => 
                    if DONE = '1' then 
                        cs_reg <= '1';
                    else
                        cs_reg <= cs_reg;
                    end if;

                when others => 
                    cs_reg <= '1';

            end case;
        end if;
    end process;

    prog_b_reg_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when RESET_FPGA_ST => 
                    prog_b_reg <= '0';
                
                when others => 
                    prog_b_reg <= '1';

            end case;
        end if;
    end process;

    saved_dest_processing : process(SM_CLK)
    begin
        if SM_CLK'event AND SM_CLK = '1' then 
            case current_state is
                when IDLE_ST => 
                    if in_empty = '0' then 
                        saved_dest <= in_dout_user( 7 downto 0 );
                    else
                        saved_dest <= saved_dest;
                    end if;

                when others => 
                    saved_dest <= saved_dest;

            end case;
        end if;
    end process;

    ASYNC_MODE_GEN : if ASYNC_MODE = true generate
        fifo_in_async_user_xpm_inst : fifo_in_async_user_xpm 
            generic map (
                CDC_SYNC        =>  4                       ,
                DATA_WIDTH      =>  8                       ,
                USER_WIDTH      =>  8                       ,
                MEMTYPE         =>  "distributed"           ,
                DEPTH           =>  16                      
            )
            port map (
                S_AXIS_CLK      =>  CLK                     ,
                S_AXIS_RESET    =>  RESET                   ,
                M_AXIS_CLK      =>  SM_CLK                  ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA            ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP            ,
                S_AXIS_TUSER    =>  S_AXIS_TDEST            ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID           ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST            ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY           ,

                IN_DOUT_DATA    =>  in_dout_data            ,
                IN_DOUT_KEEP    =>  in_dout_keep            ,
                IN_DOUT_USER    =>  in_dout_user            ,
                IN_DOUT_LAST    =>  in_dout_last            ,
                IN_RDEN         =>  in_rden                 ,
                IN_EMPTY        =>  in_empty                
            );
    end generate;

    SYNC_MODE_GEN : if ASYNC_MODE = false generate 

        fifo_in_sync_user_xpm_inst : fifo_in_sync_user_xpm 
            generic map (
                DATA_WIDTH      =>  8                       ,
                USER_WIDTH      =>  8                       ,
                MEMTYPE         =>  "distributed"           ,
                DEPTH           =>  16                      
            )
            port map (
                CLK             =>  CLK                     ,
                RESET           =>  RESET                   ,
                
                S_AXIS_TDATA    =>  S_AXIS_TDATA            ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP            ,
                S_AXIS_TUSER    =>  S_AXIS_TDEST            ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID           ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST            ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY           ,

                IN_DOUT_DATA    =>  in_dout_data            ,
                IN_DOUT_KEEP    =>  in_dout_keep            ,
                IN_DOUT_USER    =>  in_dout_user            ,
                IN_DOUT_LAST    =>  in_dout_last            ,
                IN_RDEN         =>  in_rden                 ,
                IN_EMPTY        =>  in_empty                
            );

    end generate;

    in_rden <= '1' when in_empty = '0' and current_state = LD_BITSTRM_ST else '0';

end axis_loader_ssm_arch;
