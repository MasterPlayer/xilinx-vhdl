library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";


library UNISIM;
    use UNISIM.VComponents.all;


entity axis_loader_ss is
    generic(
        WAIT_ABORT_LIMIT    :           integer := 100000000                                ;
        ASYNC_MODE          :           boolean := true                                     ;
        N_BYTES             :           integer := 2                                              -- Supports : 1/2/4/8 BYTES
    );
    port(
        CLK                 :   in      std_logic                                           ;
        RESET               :   in      std_logic                                           ;

        CLK_SS              :   in      std_logic                                           ;

        STS_PROG_GOOD       :   out     std_logic                                           ;
        STS_PROG_FAIL       :   out     std_logic                                           ;


        S_AXIS_TDATA        :   in      std_logic_Vector ( (N_BYTES*8)-1 downto 0 )         ;
        S_AXIS_TKEEP        :   in      std_logic_Vector (  N_BYTES-1 downto 0 )            ;
        S_AXIS_TVALID       :   in      std_logic                                           ;
        S_AXIS_TLAST        :   in      std_logic                                           ;
        S_AXIS_TREADY       :   out     std_logic                                           ;

        CCLK                :   out     std_logic                                           ;
        DIN                 :   out     std_logic                                           ;
        DONE                :   in      std_logic                                           ;
        INIT_B              :   in      std_logic                                           ;
        PROG_B              :   out     std_logic                                            
    );
end axis_loader_ss;



architecture axis_loader_ss_arch of axis_loader_ss is

    
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of RESET: SIGNAL is "xilinx.com:signal:reset:1.0 RESET RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of RESET: SIGNAL is "POLARITY ACTIVE_HIGH";

    constant version : string := "v1.2" ;

    constant DATA_WIDTH : integer := N_BYTES*8;

    constant BIT_CNT_LIMIT  :   integer := (N_BYTES*8)-1;
    constant BIT_CNT_WIDTH  :   integer := integer(ceil(log2(real(BIT_CNT_LIMIT))));
    signal  bit_cnt         :           std_logic_vector ( BIT_CNT_WIDTH-1 downto 0 )     := (others => '0')  ;
    signal  cnt_limit_reg   :           std_logic_vector ( BIT_CNT_WIDTH-1 downto 0 )     := (others => '1')  ;    

    component fifo_in_async_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            CDC_SYNC        :           integer         :=  4                           ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            S_AXIS_CLK      :   in      std_logic                                       ;
            S_AXIS_RESET    :   in      std_logic                                       ;
            M_AXIS_CLK      :   in      std_logic                                       ;
            
            S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            S_AXIS_TVALID   :   in      std_logic                                       ;
            S_AXIS_TLAST    :   in      std_logic                                       ;
            S_AXIS_TREADY   :   out     std_logic                                       ;

            IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            IN_DOUT_LAST    :   out     std_logic                                       ;
            IN_RDEN         :   in      std_logic                                       ;
            IN_EMPTY        :   out     std_logic                                   
        );
    end component;

    component fifo_in_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            
            S_AXIS_TDATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            S_AXIS_TKEEP    :   in      std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            S_AXIS_TVALID   :   in      std_logic                                       ;
            S_AXIS_TLAST    :   in      std_logic                                       ;
            S_AXIS_TREADY   :   out     std_logic                                       ;

            IN_DOUT_DATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            IN_DOUT_KEEP    :   out     std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            IN_DOUT_LAST    :   out     std_logic                                       ;
            IN_RDEN         :   in      std_logic                                       ;
            IN_EMPTY        :   out     std_logic                                   
        );
    end component;


    signal  in_dout_data    :           std_logic_vector ( (N_BYTES*8)-1 downto 0 )     ;
    signal  in_dout_keep    :           std_logic_Vector ( (N_BYTES-1) downto 0 )       ;
    signal  in_dout_last    :           std_logic                                       ;
    signal  in_rden         :           std_logic                                   := '0'      ;
    signal  in_empty        :           std_logic                                       ;

    type fsm is(
        WAIT_PROG_ST        ,
        RESET_FPGA_ST       ,
        WAIT_FOR_INITB_ST   ,
        PROG_FPGA_ST        ,
        WAIT_DATA_ST        --,
        --WAIT_DONE_ST         
    );

    signal  r_in_dout_data  :           std_logic_Vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;

    signal current_state : FSM := WAIT_PROG_ST;

    signal  prog_b_reg          :           std_logic                           := '1'              ;
    signal  clk_ss_sig          :           std_Logic                                               ;
    --signal  last_flaq           :           std_logic                           := '0'              ;
    signal  wait_abort_cnt      :           std_logic_Vector ( 31 downto  0 )   := (others => '0')  ;
    signal  S_AXIS_DATA_SWAP    :           std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0');

    component rst_syncer
        generic(
            INIT_VALUE                          :           bit             := '1'                                  
        );
        port(
            CLK                                 :   in      std_logic                                               ;
            RESET                               :   in      std_logic                                               ;
            RESET_OUT                           :   out     std_logic                                               
        );
    end component;

    signal  rst_ss                              :           std_logic   := '1'                                      ;

    signal  sts_prog_good_reg                   :           std_logic           := '0'                              ;
    signal  sts_prog_fail_reg                   :           std_logic           := '0'                              ;

begin

    STS_PROG_GOOD <= sts_prog_good_reg;
    STS_PROG_FAIL <= sts_prog_fail_reg;

    STS_PROG_GOOD_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            case current_state is

                when WAIT_DATA_ST => 
                    if DONE = '1' then 
                        sts_prog_good_reg <= '1';
                    elsif in_empty = '0' then 
                        sts_prog_good_reg <= sts_prog_good_reg;
                    else
                        if wait_abort_cnt = WAIT_ABORT_LIMIT then 
                            sts_prog_good_reg <=sts_prog_good_reg ;
                        else
                            sts_prog_good_reg <= sts_prog_good_reg;    
                        end if;
                    end if;

                when WAIT_PROG_ST => 
                    if (in_empty = '0') then 
                        sts_prog_good_reg <= '0';
                    else
                        sts_prog_good_reg <= sts_prog_good_reg;
                    end if; 

                when others => 
                    sts_prog_good_reg <= sts_prog_good_reg;
            end case;
        end if;
    end process;

    STS_PROG_FAIL_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            case current_state is
                when WAIT_DATA_ST => 
                    if DONE = '1' then 
                        sts_prog_fail_reg <= sts_prog_fail_reg;
                    elsif in_empty = '0' then 
                        sts_prog_fail_reg <= sts_prog_fail_reg;
                    else
                        if wait_abort_cnt = WAIT_ABORT_LIMIT then 
                            sts_prog_fail_reg <= '1';
                        else
                            sts_prog_fail_reg <= sts_prog_fail_reg;    
                        end if;
                    end if;


                when WAIT_PROG_ST => 
                    if (in_empty = '0') then 
                        sts_prog_fail_reg <= '0';
                    else
                        sts_prog_fail_reg <= sts_prog_fail_reg;
                    end if; 

                when others => 
                    sts_prog_fail_reg <= sts_prog_fail_reg;
            end case;
        end if;
    end process;

    
    SWAP_GEN : for i in 0 to N_BYTES-1 generate
        S_AXIS_DATA_SWAP( (i*8) + 7 downto (i*8) ) <= S_AXIS_TDATA( ((DATA_WIDTH - (i*8))-1)  downto (DATA_WIDTH - ((i+1)*8)) ) ;
    end generate; 

    clk_ss_sig      <=  CLK_SS                                      ;

    CCLK            <=  not(clk_ss_sig) when current_state = PROG_FPGA_ST else '0' ;
    PROG_B          <=  prog_b_reg                                  ;
    DIN             <=  r_in_dout_data(DATA_WIDTH-1)                          ;

    ASYNC_GEN_ON : if ASYNC_MODE = true generate 
        
        fifo_in_async_xpm_inst : fifo_in_async_xpm
            generic map (
                DATA_WIDTH      =>  N_BYTES*8                           ,
                CDC_SYNC        =>  4                                   ,
                MEMTYPE         =>  "distributed"                       ,
                DEPTH           =>  16                           
            )
            port map (
                S_AXIS_CLK      =>  CLK                                 ,
                S_AXIS_RESET    =>  RESET                               ,
                M_AXIS_CLK      =>  CLK_SS                              ,
                
                S_AXIS_TDATA    =>  S_AXIS_DATA_SWAP                    ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP                        ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                        ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY                       ,

                IN_DOUT_DATA    =>  in_dout_data                        ,
                IN_DOUT_KEEP    =>  in_dout_keep                        ,
                IN_DOUT_LAST    =>  in_dout_last                        ,
                IN_RDEN         =>  in_rden                             ,
                IN_EMPTY        =>  in_empty                            
            );


        rst_syncer_inst_ss : rst_syncer
            generic map (
                INIT_VALUE      =>  '1'                  
            )
            port map (
                CLK             =>  CLK_SS              ,
                RESET           =>  RESET               ,
                RESET_OUT       =>  rst_ss               
            );


    end generate;

    ASYNC_GEN_OFF : if ASYNC_MODE = false generate 
            
        fifo_in_sync_xpm_inst : fifo_in_sync_xpm
            generic map (
                DATA_WIDTH      =>  N_BYTES*8                           ,
                MEMTYPE         =>  "distributed"                       ,
                DEPTH           =>  16                                   
            )
            port map (
                CLK             =>  CLK                                 ,
                RESET           =>  RESET                               ,
                
                S_AXIS_TDATA    =>  S_AXIS_DATA_SWAP                    ,
                S_AXIS_TKEEP    =>  S_AXIS_TKEEP                        ,
                S_AXIS_TVALID   =>  S_AXIS_TVALID                       ,
                S_AXIS_TLAST    =>  S_AXIS_TLAST                        ,
                S_AXIS_TREADY   =>  S_AXIS_TREADY                       ,

                IN_DOUT_DATA    =>  in_dout_data                        ,
                IN_DOUT_KEEP    =>  in_dout_keep                        ,
                IN_DOUT_LAST    =>  in_dout_last                        ,
                IN_RDEN         =>  in_rden                             ,
                IN_EMPTY        =>  in_empty                            
            );

        rst_ss <= RESET;

    end generate;

    wait_abort_cnt_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if rst_ss = '1' then 
                wait_abort_cnt <= (others => '0');
            else
                case current_state is
                    
                    when WAIT_DATA_ST =>
                        wait_abort_cnt <= wait_abort_cnt + 1;

                    when others =>
                        wait_abort_cnt <= (others => '0')   ;

                end case;
            end if;
        end if;
    end process;


    current_state_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if rst_ss = '1' then 
                current_state <= WAIT_PROG_ST;
            else
                case current_state is
                    when WAIT_PROG_ST =>
                        if (in_empty = '0') then 
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
                            current_state <= PROG_FPGA_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when PROG_FPGA_ST =>
                        if bit_cnt = cnt_limit_reg then 
                            if in_empty = '1' then 
                                current_state <= WAIT_DATA_ST;
                            else
                                current_state <= current_state;    
                            end if;
                        else
                            current_state <= current_state;    
                        end if;

                    when WAIT_DATA_ST =>
                        if DONE = '1' then 
                            current_state <= WAIT_PROG_ST;
                        elsif in_empty = '0' then 
                            current_state <= PROG_FPGA_ST;
                        else
                            if wait_abort_cnt = WAIT_ABORT_LIMIT then 
                                current_state <= WAIT_PROG_ST;
                            else
                                current_state <= current_state;    
                            end if;
                        end if;

                    when others =>
                        current_state <= current_state;
                        
                end case;   
            end if;
        end if;
    end process;

    prog_b_reg_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if rst_ss = '1' then 
                prog_b_reg <= '1';
            else
                case current_state is
                    when RESET_FPGA_ST =>
                        prog_b_reg <= '0';

                    when others =>
                        prog_b_reg <= '1';
                end case;
            end if;
        end if;
    end process;

    in_rden_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if rst_ss = '1' then 
                in_rden <= '0';
            else
                case current_state is
                    when PROG_FPGA_ST =>
                        if bit_cnt = 0 then 
                            in_rden <= '1';
                        else
                            in_rden <= '0';    
                        end if;

                    when others =>
                        in_rden <= '0';
                end case;
            end if;
        end if;
    end process;

    r_in_dout_data_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            case current_state is
              
                when WAIT_PROG_ST | WAIT_DATA_ST =>
                    if (in_empty = '0') then 
                        r_in_dout_data <= in_dout_data;
                    else
                        r_in_dout_data <= r_in_dout_data;
                    end if;

                when PROG_FPGA_ST =>
                    if bit_cnt = cnt_limit_reg then 
                        r_in_dout_data <= in_dout_data;    
                    else
                        r_in_dout_data <= r_in_dout_data(DATA_WIDTH-2 downto 0 ) & r_in_dout_data(DATA_WIDTH-1);
                    end if;

                when others =>
                    r_in_dout_data <= r_in_dout_data;

            end case;
        end if;
    end process;

    bit_cnt_processing : process(CLK_SS)
    begin
        if CLK_SS'event AND CLK_SS = '1' then 
            if RESET = '1' then 
                bit_cnt <= (others => '0') ;
            else
                
                case current_state is
                    when PROG_FPGA_ST =>
                        if bit_cnt < cnt_limit_reg then 
                            bit_cnt <= bit_cnt + 1;
                        else
                            bit_cnt <= (others => '0');
                        end if; 

                    when others =>
                        bit_cnt <= (others => '0');
                
                end case;
            end if;
        end if; 
    end process;

    GEN_LIMITS_x8 : if N_BYTES = 1 generate 
        cnt_limit_reg <= "111";
    end generate;

    GEN_LIMITS_x16 : if N_BYTES = 2 generate 
        cnt_limit_reg_processing : process(CLK_SS)
        begin 
            if CLK_SS'event AND CLK_SS = '1' then 
                if in_rden = '1' then 
                    case in_dout_keep is
                        when "11"   => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                        when "01"   => cnt_limit_reg <= conv_std_logic_Vector (  7, cnt_limit_reg'length);
                        when others => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                    end case;
                else
                    cnt_limit_reg <= cnt_limit_reg;
                end if;
            end if;
        end process;
    end generate;

    GEN_LIMITS_x32 : if N_BYTES = 4 generate 
        cnt_limit_reg_processing : process(CLK_SS)
        begin 
            if CLK_SS'event AND CLK_SS = '1' then 
                if in_rden = '1' then 
                    case in_dout_keep is
                        when "1111" => cnt_limit_reg <= conv_std_logic_Vector ( 31, cnt_limit_reg'length);
                        when "0111" => cnt_limit_reg <= conv_std_logic_Vector ( 23, cnt_limit_reg'length);
                        when "0011" => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                        when "0001" => cnt_limit_reg <= conv_std_logic_Vector (  7, cnt_limit_reg'length);
                        when others => cnt_limit_reg <= conv_std_logic_Vector ( 31, cnt_limit_reg'length);
                    end case;
                else
                    cnt_limit_reg <= cnt_limit_reg;    
                end if;
            end if;
        end process;
    end generate;

    GEN_LIMITS_x64 : if N_BYTES = 8 generate 
        cnt_limit_reg_processing : process(CLK_SS)
        begin 
            if CLK_SS'event AND CLK_SS = '1' then 
                if in_rden = '1' then 
                    case in_dout_keep is
                        when "11111111" => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                        when "01111111" => cnt_limit_reg <= conv_std_logic_Vector ( 55, cnt_limit_reg'length);
                        when "00111111" => cnt_limit_reg <= conv_std_logic_Vector ( 47, cnt_limit_reg'length);
                        when "00011111" => cnt_limit_reg <= conv_std_logic_Vector ( 39, cnt_limit_reg'length);
                        when "00001111" => cnt_limit_reg <= conv_std_logic_Vector ( 31, cnt_limit_reg'length);
                        when "00000111" => cnt_limit_reg <= conv_std_logic_Vector ( 23, cnt_limit_reg'length);
                        when "00000011" => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                        when "00000001" => cnt_limit_reg <= conv_std_logic_Vector (  7, cnt_limit_reg'length);
                        when others     => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                    end case;
                else
                    cnt_limit_reg <= cnt_limit_reg;    
                end if;
            end if;
        end process;
    end generate;


    GEN_LIMITS_x128 : if N_BYTES = 16 generate 
        cnt_limit_reg_processing : process(CLK_SS)
        begin 
            if CLK_SS'event AND CLK_SS = '1' then 
                if in_rden = '1' then 
                    case in_dout_keep is

                        when "1111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (127, cnt_limit_reg'length);
                        when "0111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (119, cnt_limit_reg'length);
                        when "0011111111111111" => cnt_limit_reg <= conv_std_logic_Vector (111, cnt_limit_reg'length);
                        when "0001111111111111" => cnt_limit_reg <= conv_std_logic_Vector (103, cnt_limit_reg'length);
                        when "0000111111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 95, cnt_limit_reg'length);
                        when "0000011111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 87, cnt_limit_reg'length);
                        when "0000001111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 79, cnt_limit_reg'length);
                        when "0000000111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 71, cnt_limit_reg'length);
                        when "0000000011111111" => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                        when "0000000001111111" => cnt_limit_reg <= conv_std_logic_Vector ( 55, cnt_limit_reg'length);
                        when "0000000000111111" => cnt_limit_reg <= conv_std_logic_Vector ( 47, cnt_limit_reg'length);
                        when "0000000000011111" => cnt_limit_reg <= conv_std_logic_Vector ( 39, cnt_limit_reg'length);
                        when "0000000000001111" => cnt_limit_reg <= conv_std_logic_Vector ( 31, cnt_limit_reg'length);
                        when "0000000000000111" => cnt_limit_reg <= conv_std_logic_Vector ( 23, cnt_limit_reg'length);
                        when "0000000000000011" => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                        when "0000000000000001" => cnt_limit_reg <= conv_std_logic_Vector (  7, cnt_limit_reg'length);
                        when others     => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                    end case;
                else
                    cnt_limit_reg <= cnt_limit_reg;    
                end if;
            end if;
        end process;
    end generate;

    GEN_LIMITS_x256 : if N_BYTES = 32 generate 
        cnt_limit_reg_processing : process(CLK_SS)
        begin 
            if CLK_SS'event AND CLK_SS = '1' then 
                if in_rden = '1' then 
                    case in_dout_keep is
                        when "11111111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (255, cnt_limit_reg'length);
                        when "01111111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (247, cnt_limit_reg'length);
                        when "00111111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (239, cnt_limit_reg'length);
                        when "00011111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (231, cnt_limit_reg'length);
                        when "00001111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (223, cnt_limit_reg'length);
                        when "00000111111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (215, cnt_limit_reg'length);
                        when "00000011111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (207, cnt_limit_reg'length);
                        when "00000001111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (199, cnt_limit_reg'length);
                        when "00000000111111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (191, cnt_limit_reg'length);
                        when "00000000011111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (183, cnt_limit_reg'length);
                        when "00000000001111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (175, cnt_limit_reg'length);
                        when "00000000000111111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (167, cnt_limit_reg'length);
                        when "00000000000011111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (159, cnt_limit_reg'length);
                        when "00000000000001111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (151, cnt_limit_reg'length);
                        when "00000000000000111111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (143, cnt_limit_reg'length);
                        when "00000000000000011111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (135, cnt_limit_reg'length);
                        when "00000000000000001111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (127, cnt_limit_reg'length);
                        when "00000000000000000111111111111111" => cnt_limit_reg <= conv_std_logic_Vector (119, cnt_limit_reg'length);
                        when "00000000000000000011111111111111" => cnt_limit_reg <= conv_std_logic_Vector (111, cnt_limit_reg'length);
                        when "00000000000000000001111111111111" => cnt_limit_reg <= conv_std_logic_Vector (103, cnt_limit_reg'length);
                        when "00000000000000000000111111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 95, cnt_limit_reg'length);
                        when "00000000000000000000011111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 87, cnt_limit_reg'length);
                        when "00000000000000000000001111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 79, cnt_limit_reg'length);
                        when "00000000000000000000000111111111" => cnt_limit_reg <= conv_std_logic_Vector ( 71, cnt_limit_reg'length);
                        when "00000000000000000000000011111111" => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                        when "00000000000000000000000001111111" => cnt_limit_reg <= conv_std_logic_Vector ( 55, cnt_limit_reg'length);
                        when "00000000000000000000000000111111" => cnt_limit_reg <= conv_std_logic_Vector ( 47, cnt_limit_reg'length);
                        when "00000000000000000000000000011111" => cnt_limit_reg <= conv_std_logic_Vector ( 39, cnt_limit_reg'length);
                        when "00000000000000000000000000001111" => cnt_limit_reg <= conv_std_logic_Vector ( 31, cnt_limit_reg'length);
                        when "00000000000000000000000000000111" => cnt_limit_reg <= conv_std_logic_Vector ( 23, cnt_limit_reg'length);
                        when "00000000000000000000000000000011" => cnt_limit_reg <= conv_std_logic_Vector ( 15, cnt_limit_reg'length);
                        when "00000000000000000000000000000001" => cnt_limit_reg <= conv_std_logic_Vector (  7, cnt_limit_reg'length);
                        when others     => cnt_limit_reg <= conv_std_logic_Vector ( 63, cnt_limit_reg'length);
                    end case;
                else
                    cnt_limit_reg <= cnt_limit_reg;    
                end if;
            end if;
        end process;
    end generate;

end axis_loader_ss_arch;
