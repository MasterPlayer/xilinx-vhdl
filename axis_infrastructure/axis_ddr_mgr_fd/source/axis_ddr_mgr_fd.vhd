library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";


library UNISIM;
    use UNISIM.VComponents.all;

entity axis_ddr_mgr_fd is
    generic(
        DATA_WIDTH          :           integer := 32                                       ; -- 
        ADDR_WIDTH          :           integer := 32                                       ;
        BURST_LIMIT         :           integer := 16                                        
    );
    port(
        CLK                 :   in      std_logic                                           ;
        RESET               :   in      std_logic                                           ;

        CMD_START_ADDRESS   :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )          ;
        CMD_SIZE            :   in      std_logic_Vector ( 63 downto 0 )                    ;
        CMD_MODE            :   in      std_logic_vector (  1 downto 0 )                    ;
        CMD_VALID           :   in      std_logic                                           ;
        -- INPUT IF
        S_AXIS_TDATA        :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )          ;
        S_AXIS_TVALID       :   in      std_logic                                           ;
        S_AXIS_TLAST        :   in      std_Logic                                           ;
        S_AXIS_TREADY       :   out     std_logic                                           ;
        --OUTPUT IF
        M_AXIS_TDATA        :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )          ;
        M_AXIS_TVALID       :   out     std_logic                                           ;
        M_AXIS_TLAST        :   out     std_logic                                           ;
        M_AXIS_TREADY       :   in      std_logic                                           ;

        M_AXI_AWADDR        :   out     std_logic_vector ( ADDR_WIDTH-1 downto 0 )          ;
        M_AXI_AWLEN         :   out     std_logic_vector (  7 downto 0 )                    ;
        M_AXI_AWSIZE        :   out     std_logic_vector (  2 downto 0 )                    ; -- Константа 
        M_AXI_AWBURST       :   out     std_logic_vector (  1 downto 0 )                    ; 
        M_AXI_AWLOCK        :   out     std_logic                                           ; -- Константа 
        M_AXI_AWCACHE       :   out     std_logic_vector (  3 downto 0 )                    ; -- Константа 
        M_AXI_AWPROT        :   out     std_logic_vector (  2 downto 0 )                    ; -- Константа 
        M_AXI_AWVALID       :   out     std_logic                                           ;
        M_AXI_AWREADY       :   in      std_logic                                           ;

        M_AXI_WDATA         :   out     std_logic_vector ( DATA_WIDTH-1 downto 0 )          ;
        M_AXI_WSTRB         :   out     std_logic_vector ( (DATA_WIDTH/8)-1 downto 0 )      ; -- Константа 
        M_AXI_WLAST         :   out     std_logic                                           ;
        M_AXI_WVALID        :   out     std_logic                                           ;
        M_AXI_WREADY        :   in      std_logic                                           ;

        M_AXI_BRESP         :   in      std_logic_vector (  1 downto 0 )                    ;
        M_AXI_BVALID        :   in      std_logic                                           ;
        M_AXI_BREADY        :   out     std_logic                                           ;

        M_AXI_ARADDR        :   out     std_logic_vector ( ADDR_WIDTH-1 downto 0 )          ;
        M_AXI_ARLEN         :   out     std_logic_vector (  7 downto 0 )                    ; 
        M_AXI_ARSIZE        :   out     std_logic_vector (  2 downto 0 )                    ; -- Константа 
        M_AXI_ARBURST       :   out     std_logic_vector (  1 downto 0 )                    ; 
        M_AXI_ARLOCK        :   out     std_logic                                           ; -- Константа 
        M_AXI_ARCACHE       :   out     std_logic_vector (  3 downto 0 )                    ; -- Константа 
        M_AXI_ARPROT        :   out     std_logic_vector (  2 downto 0 )                    ; -- Константа 
        M_AXI_ARVALID       :   out     std_logic                                           ;
        M_AXI_ARREADY       :   in      std_logic                                           ;

        M_AXI_RDATA         :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )          ;
        M_AXI_RRESP         :   in      std_logic_vector (  1 downto 0 )                    ;
        M_AXI_RLAST         :   in      std_logic                                           ;
        M_AXI_RVALID        :   in      std_logic                                           ;
        M_AXI_RREADY        :   out     std_logic                                           
    );
end axis_ddr_mgr_fd;




architecture axis_ddr_mgr_fd_arch of axis_ddr_mgr_fd is

    function clogb2 (bit_depth : integer) return integer is            
        variable depth  : integer := bit_depth;                               
        variable count  : integer := 1;                                       
    begin                                                                   
        for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
            if (bit_depth <= 2) then                                           
                count := 1;                                                      
            else                                                               
                if(depth <= 1) then                                              
                    count := count;                                                
                else                                                             
                    depth := depth / 2;                                            
                    count := count + 1;                                            
                end if;                                                          
            end if;                                                            
        end loop;                                                             
        return(count);                                                         
    end;                               
    
    -- функция для вычисления размера фифо, нужна только для того чтобы корректно задать глубину входной фифо на запись, так как при размере меньше 
    -- 16 могут выдаваться ошибки.     
    function get_fifo_size(burst_len : integer ) return integer is
        variable depth : integer := 16;
    begin
        if burst_len <= 16 then
            depth := 16 * 2;
        else
            depth := burst_len * 2;
        end if;
        return(depth);
    end;

    constant  FIFO_DEPTH                :           integer                                     := get_fifo_size(BURST_LIMIT);

    -- AxSIZE задается в соответствии с длиной - в данном случае мы не поддерживаем 
    -- слова которые не кратны ширине шины
    constant  C_AXSIZE_INT              :           integer                                     := clogb2((DATA_WIDTH/8)-1);

    -- Инкремент для адреса задается через константу
    constant  C_AXSIZE_SHIFT            :           std_logic_Vector ( C_AXSIZE_INT-1 downto 0 ):= (others => '0');
    constant  C_AXADDR_INCREMENT_VEC    :           std_logic_Vector ( ADDR_WIDTH-1 downto 0 )  := conv_std_logic_Vector ( BURST_LIMIT, (ADDR_WIDTH-C_AXSIZE_INT)) & C_AXSIZE_SHIFT;

    component fifo_in_sync_counted_xpm
        generic(
            DATA_WIDTH                  :           integer         :=  16                                                  ;
            MEMTYPE                     :           String          :=  "block"                                             ;
            DEPTH                       :           integer         :=  16                                                   
        );
        port(
            CLK                         :   in      std_logic                                                               ;
            RESET                       :   in      std_logic                                                               ;
            
            S_AXIS_TDATA                :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )                              ;
            S_AXIS_TVALID               :   in      std_logic                                                               ;
            S_AXIS_TLAST                :   in      std_logic                                                               ;
            S_AXIS_TREADY               :   out     std_logic                                                               ;

            IN_DOUT_DATA                :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )                              ;
            IN_DOUT_LAST                :   out     std_logic                                                               ;
            IN_RDEN                     :   in      std_logic                                                               ;
            IN_EMPTY                    :   out     std_logic                                                               ;

            DATA_COUNT                  :   out     std_logic_Vector ( 31 downto 0 )                                         
        );
    end component;

    signal  fifo_reset                  :           std_logic                                        := '0'                 ;

    signal  write_ability               :           std_logic                                        := '0'                 ;

    signal  in_dout_data                :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )                              ;
    signal  in_dout_last                :           std_logic                                                               ;
    signal  in_rden                     :           std_logic                                        := '0'                 ;
    signal  in_empty                    :           std_logic                                                               ;

    -- Поддержка побайтовая в данном случае не обеспечивается, 
    -- в данной реализации ТОЛЬКО поддержка на уровне слов. 
    signal  fifo_data_count             :           std_logic_Vector ( 31 downto 0 )                                        ;
    signal  fifo_word_count             :           std_logic_Vector ( 31 downto 0 )                                        ;
    
    -- состояния конечного автомата на чтение

    type rd_fsm is(
        IDLE_ST                         ,
        WAIT_FOR_WRITE_ST               ,
        WAIT_FOR_FIFO_ABILITY_RCV_ST    ,
        READ_ST                          
    );

    signal  current_state_read          :           rd_fsm                                          := IDLE_ST              ;

    -- состояния конечного автомата на запись

    type wr_fsm is(
        IDLE_ST                         ,
        WAIT_FOR_DATA_ST                ,
        WRITE_ST                        ,
        WRITE_WAIT_BRESP_ST              
        
    );
    
    signal  current_state_write         :           wr_fsm                                          := IDLE_ST              ;

    signal  m_axi_awaddr_reg            :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )      := (others => '0')      ;
    signal  m_axi_awlen_reg             :           std_logic_vector (  7 downto 0 )                := (others => '0')      ;
    signal  m_axi_awsize_reg            :           std_logic_vector (  2 downto 0 )                := (others => '0')      ;
    signal  m_axi_awburst_reg           :           std_logic_vector (  1 downto 0 )                := (others => '0')      ;
    signal  m_axi_awvalid_reg           :           std_logic                                       := '0'                  ;

    signal  m_axi_wdata_reg             :           std_logic_vector ( DATA_WIDTH-1 downto 0 )      := (others => '0')      ;
    signal  m_axi_wstrb_reg             :           std_logic_vector ( (DATA_WIDTH/8)-1 downto 0 )  := (others => '0')      ;
    signal  m_axi_wlast_reg             :           std_logic                                                               ;
    signal  m_axi_wvalid_reg            :           std_logic                                                               ;

    signal  m_axi_bready_reg            :           std_logic                                       := '0'                  ;

    signal  awburst_counter             :           std_logic_Vector ( 7 downto 0 )                 := (others => '0')      ;
    signal  word_counter_write          :           std_logic_vector ( 63 downto 0 )                := (others => '0')      ;
    signal  awlen_reg                   :           std_logic_vector (  8 downto 0 )                := (others => '0')      ;


    signal  burst_read_active           :           std_logic                                       := '0'                  ;
    signal  start_burst_read            :           std_logic                                       := '0'                  ;

    signal  word_counter_read           :           std_logic_vector ( 63 downto 0 )                := (others => '0')      ;

    signal  arlen_reg                   :           std_logic_vector (  8 downto 0 )                := (others => '0')      ;

    signal  m_axi_araddr_reg            :           std_logic_Vector ( ADDR_WIDTH-1 downto 0 )      := (others => '0')      ;
    signal  m_axi_arlen_reg             :           std_logic_vector (  7 downto 0 )                := (others => '0')      ;
    signal  m_axi_arburst_reg           :           std_logic_Vector (  1 downto 0 )                := (others => '0')      ;
    signal  m_axi_arvalid_reg           :           std_logic                                       := '0'                  ;
        
    signal  m_axi_rready_reg            :           std_logic                                       := '0';

    signal  has_bresp_flaq              :           std_logic                                       := '0';



    component fifo_out_pfull_sync_xpm
        generic(
            DATA_WIDTH      :           integer         :=  16                          ;
            MEMTYPE         :           String          :=  "block"                     ;
            DEPTH           :           integer         :=  16                          ;
            PFULL_ASSERT    :           integer         := 10                           
        );
        port(
            CLK             :   in      std_logic                                       ;
            RESET           :   in      std_logic                                       ;
            
            OUT_DIN_DATA    :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            OUT_DIN_KEEP    :   in      std_logic_Vector ( ( DATA_WIDTH/8)-1 downto 0 ) ;
            OUT_DIN_LAST    :   in      std_logic                                       ;
            OUT_WREN        :   in      std_logic                                       ;
            OUT_PFULL       :   out     std_logic                                       ;
            OUT_FULL        :   out     std_logic                                       ;

            M_AXIS_TDATA    :   out     std_logic_Vector ( DATA_WIDTH-1 downto 0 )      ;
            M_AXIS_TKEEP    :   out     std_logic_Vector (( DATA_WIDTH/8)-1 downto 0 )  ;
            M_AXIS_TVALID   :   out     std_logic                                       ;
            M_AXIS_TLAST    :   out     std_logic                                       ;
            M_AXIS_TREADY   :   in      std_logic                                        

        );
    end component;

    signal  out_din_data        :           std_logic_Vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')       ;
    signal  out_din_last        :           std_logic                                  := '0'                   ;
    signal  out_wren            :           std_logic                                  := '0'                   ;
    signal  out_pfull           :           std_logic                                       ;
    signal  out_full            :           std_logic                                       ;



begin


    -- READ port assignments:
    M_AXI_ARSIZE    <= conv_std_logic_vector ( C_AXSIZE_INT, M_AXI_AWSIZE'length);
    M_AXI_ARADDR    <= m_axi_araddr_reg;
    M_AXI_ARLEN     <= m_axi_arlen_reg;
    M_AXI_ARBURST   <= m_axi_arburst_reg;
    M_AXI_ARLOCK    <= '0';
    M_AXI_ARCACHE   <= (others => '0');
    M_AXI_ARPROT    <= (others => '0');
    M_AXI_ARVALID   <= m_axi_arvalid_reg;
    
    M_AXI_RREADY    <= m_axi_rready_reg;


    M_AXI_AWSIZE    <=  conv_std_logic_vector ( C_AXSIZE_INT, M_AXI_AWSIZE'length);
    M_AXI_AWCACHE   <= (others => '0') ;
    M_AXI_AWPROT    <= (others => '0') ;
    M_AXI_AWLOCK    <= '0';
    M_AXI_AWADDR    <=  m_axi_awaddr_reg;
    M_AXI_AWLEN     <=  m_axi_awlen_reg;
    M_AXI_AWBURST   <=  m_axi_awburst_reg;
    M_AXI_AWVALID   <=  m_axi_awvalid_reg;


    M_AXI_WDATA     <=  m_axi_wdata_reg     ;      
    M_AXI_WSTRB     <=  m_axi_wstrb_reg     ;      
    M_AXI_WLAST     <=  m_axi_wlast_reg     ;      
    M_AXI_WVALID    <=  m_axi_wvalid_reg    ;     

    M_AXI_BREADY    <=  m_axi_bready_reg    ;

    m_axi_awburst_reg <= "01";
    m_axi_arburst_reg <= "01";

    m_axi_wdata_reg <= in_dout_data;    
    m_axi_wstrb_reg <= (others => '1');



    word_counter_read_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_read is

                when IDLE_ST => 
                    if CMD_VALID = '1' and CMD_MODE(0) = '1' then 
                        if CMD_SIZE( C_AXSIZE_INT-1 downto 0 ) = 0 then -- добивание на кратность слову 
                            word_counter_read <= EXT(CMD_SIZE(63 downto C_AXSIZE_INT), 64);
                        else
                            word_counter_read <= EXT(CMD_SIZE(63 downto C_AXSIZE_INT), 64) + 1;
                        end if;
                    else
                        word_counter_read <= word_counter_read;
                    end if;

                when READ_ST => 
                    if m_axi_arvalid_reg = '1' and M_AXI_ARREADY = '1' then 
                        if word_counter_read = 0 then 
                            word_counter_read <= word_counter_read;
                        else
                            word_counter_read <= word_counter_read - arlen_reg;
                        end if;
                    else
                        word_counter_read <= word_counter_read;
                    end if;

                when others => 
                    word_counter_read <= word_counter_read;

            end case;
        end if;
    end process;

    word_counter_write_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is

                when IDLE_ST => 
                    if CMD_VALID = '1' then 
                        if CMD_SIZE( C_AXSIZE_INT-1 downto 0 ) = 0 then -- добивание на кратность слову 
                            word_counter_write <= EXT(CMD_SIZE(63 downto C_AXSIZE_INT), 64);
                        else
                            word_counter_write <= EXT(CMD_SIZE(63 downto C_AXSIZE_INT), 64) + 1;
                        end if;
                    else
                        word_counter_write <= word_counter_write;
                    end if;

                when WRITE_ST => 
                    if m_axi_wvalid_reg = '1' and M_AXI_WREADY = '1' and m_axi_wlast_reg = '1' then
                        word_counter_write <= word_counter_write - awlen_reg;
                    else
                        word_counter_write <= word_counter_write;
                    end if;

                when others => 
                    word_counter_write <= word_counter_write;

            end case;
        end if;
    end process;


    m_axi_awaddr_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is
                when IDLE_ST => 
                    m_axi_awaddr_reg <= CMD_START_ADDRESS;

                when WRITE_WAIT_BRESP_ST => 
                    if M_AXI_BVALID = '1' and m_axi_bready_reg = '1' then 
                        m_axi_awaddr_reg <= m_axi_awaddr_reg + C_AXADDR_INCREMENT_VEC;
                    else
                        m_axi_awaddr_reg <= m_axi_awaddr_reg;    
                    end if;

                when others => 
                    m_axi_awaddr_reg <= m_axi_awaddr_reg;

            end case;
        end if;
    end process;

    m_axi_araddr_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_read is
                when IDLE_ST => 
                    m_axi_araddr_reg <= CMD_START_ADDRESS;

                when READ_ST => 
                    if m_axi_arvalid_reg = '1' and M_AXI_ARREADY = '1' then 
                        m_axi_araddr_reg <= m_axi_araddr_reg + C_AXADDR_INCREMENT_VEC;
                    else
                        m_axi_araddr_reg <= m_axi_araddr_reg;
                    end if;

                when others => 
                    m_axi_araddr_reg <= m_axi_araddr_reg;

            end case;
        end if;
    end process;

    -- ТУТ выводится количество слов которые мы хотим записать в память
    -- Пока поставим что оперируем только с величиной 16 слов на burst, 
    -- отом надо будет настраивать лимиты

    m_axi_awlen_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then
            case current_state_write is
                when WAIT_FOR_DATA_ST => 
                    if word_counter_write <= conv_std_logic_vector(BURST_LIMIT, 64) then 
                        m_axi_awlen_reg <= word_counter_write(7 downto 0) - 1;
                    else
                        m_axi_awlen_reg <= conv_std_logic_vector(BURST_LIMIT-1, 8);
                    end if;

                when WRITE_WAIT_BRESP_ST =>
                    if in_empty = '0' then 
                        if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                            if fifo_word_count < word_counter_write then 
                                m_axi_awlen_reg <= m_axi_awlen_reg;
                            else
                                m_axi_awlen_reg <= word_counter_write(7 downto 0) - 1;
                            end if;
                        else
                            if fifo_word_count < BURST_LIMIT then 
                                m_axi_awlen_reg <= m_axi_awlen_reg;
                            else
                                m_axi_awlen_reg <= conv_std_logic_vector(BURST_LIMIT-1, 8);
                            end if;
                        end if;
                    else
                        m_axi_awlen_reg <= m_axi_awlen_reg;
                    end if;

                when others => 
                    m_axi_awlen_reg <= m_axi_awlen_reg;

            end case;
        end if;
    end process;

    m_axi_arlen_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_read is

                when IDLE_ST =>
                    if CMD_VALID = '1' and CMD_MODE(0) = '1' then
                        -- Условие - если есть младшая часть в единицах
                        if CMD_SIZE( C_AXSIZE_INT-1 downto 0 ) = 0 then -- добивание на кратность слову 
                            if CMD_SIZE(CMD_SIZE'length-1 downto C_AXSIZE_INT) <= conv_std_logic_vector(BURST_LIMIT-1, (CMD_SIZE'length-C_AXSIZE_INT)) then
                                m_axi_arlen_reg <= CMD_SIZE((m_axi_arlen_reg'length + C_AXSIZE_INT)-1 downto C_AXSIZE_INT)-1;
                            else
                                m_axi_arlen_reg <= conv_std_logic_vector ( BURST_LIMIT-1, 8);
                            end if;
                        else

                            if CMD_SIZE(CMD_SIZE'length-1 downto C_AXSIZE_INT) <= conv_std_logic_vector(BURST_LIMIT-1, (CMD_SIZE'length-C_AXSIZE_INT)) then
                                m_axi_arlen_reg <= CMD_SIZE((m_axi_arlen_reg'length + C_AXSIZE_INT)-1 downto C_AXSIZE_INT);
                            else
                                m_axi_arlen_reg <= conv_std_logic_vector ( BURST_LIMIT-1, m_axi_arlen_reg'length);
                            end if;
                        end if;
                    else
                        m_axi_arlen_reg <= m_axi_arlen_reg;
                    end if;

                when WAIT_FOR_WRITE_ST => 
                    if word_counter_read < conv_std_logic_vector ( BURST_LIMIT, word_counter_read'length) then 
                        m_axi_arlen_reg <= word_counter_read(m_axi_arlen_reg'length-1 downto 0 )-1;
                    else
                        m_axi_arlen_reg <= conv_std_logic_vector ( BURST_LIMIT-1, m_axi_arlen_reg'length);
                    end if;


                when READ_ST => 
                    if M_AXI_RVALID = '1' and m_axi_rready_reg = '1' and M_AXI_RLAST = '1' then
                        if word_counter_read < conv_std_logic_vector ( BURST_LIMIT, word_counter_read'length) then 
                            m_axi_arlen_reg <= word_counter_read(m_axi_arlen_reg'length-1 downto 0 )-1;
                        else
                            m_axi_arlen_reg <= conv_std_logic_vector ( BURST_LIMIT-1, m_axi_arlen_reg'length);
                        end if;
                    else
                        m_axi_arlen_reg <= m_axi_arlen_reg;
                    end if;

                when others => 
                    m_axi_arlen_reg <= m_axi_arlen_reg;
            end case;
        end if;
    end process;

    --нужен только для декремента счетчика при записи. 
    awlen_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 

            case current_state_write is
                when WAIT_FOR_DATA_ST => 
                    if word_counter_write <= conv_std_logic_vector(BURST_LIMIT, word_counter_write'length) then 
                        awlen_reg <= word_counter_write(awlen_reg'length-1 downto 0);
                    else
                        awlen_reg <= conv_std_logic_vector(BURST_LIMIT, awlen_reg'length);
                    end if;

                when WRITE_WAIT_BRESP_ST => 
                    if in_empty = '0' then 
                        if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                            if fifo_word_count < word_counter_write then 
                                awlen_reg <= awlen_reg;
                            else
                                awlen_reg <= word_counter_write(awlen_reg'length-1 downto 0);
                            end if;
                        else
                            if fifo_word_count < BURST_LIMIT then 
                                awlen_reg <= awlen_reg;
                            else
                                awlen_reg <= conv_std_logic_vector(BURST_LIMIT, awlen_reg'length);
                            end if;
                        end if;
                    else
                        awlen_reg <= awlen_reg;
                    end if;

                when others => 
                    awlen_reg <= awlen_reg;

            end case;
        end if;
    end process;

    arlen_reg_processing : process(CLK)
    begin
        if CLK'event aND CLK = '1' then 
            case current_state_read is


                when IDLE_ST =>
                    if word_counter_read < conv_std_logic_vector ( BURST_LIMIT, 64) then 
                        arlen_reg <= word_counter_read(arlen_reg'length-1 downto 0);
                    else
                        arlen_reg <= conv_std_logic_vector (BURST_LIMIT, arlen_reg'length);
                    end if;

                when WAIT_FOR_WRITE_ST => 
                    if word_counter_read < conv_std_logic_vector ( BURST_LIMIT, 64) then 
                        arlen_reg <= word_counter_read(arlen_reg'length-1 downto 0);
                    else
                        arlen_reg <= conv_std_logic_vector (BURST_LIMIT, arlen_reg'length);
                    end if;

                when READ_ST => 
                    if word_counter_read < conv_std_logic_vector ( BURST_LIMIT, 64) then 
                        arlen_reg <= word_counter_read(arlen_reg'length-1 downto 0);
                    else
                        arlen_reg <= conv_std_logic_vector (BURST_LIMIT, arlen_reg'length);
                    end if;

                when others => 
                    arlen_reg <= arlen_reg;
            end case;
        end if;
    end process;

    m_axi_awvalid_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then

            case current_state_write is

                when WAIT_FOR_DATA_ST => 
                    if in_empty = '0' then 
                        if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                            if fifo_word_count < word_counter_write then 
                                m_axi_awvalid_reg <= m_axi_awvalid_reg;
                            else
                                m_axi_awvalid_reg <= '1';
                            end if;
                        else
                            if fifo_word_count < BURST_LIMIT then 
                                m_axi_awvalid_reg <= m_axi_awvalid_reg;
                            else
                                m_axi_awvalid_reg <= '1';
                            end if;
                        end if;
                    else
                        m_axi_awvalid_reg <= m_axi_awvalid_reg;
                    end if;

                when WRITE_ST => 
                    if m_axi_awvalid_reg = '1' and M_AXI_AWREADY = '1' then 
                        m_axi_awvalid_reg <= '0';
                    else
                        m_axi_awvalid_reg <= m_axi_awvalid_reg;
                    end if;

                when WRITE_WAIT_BRESP_ST =>
                    if (M_AXI_BVALID = '1' and m_axi_bready_reg = '1') or has_bresp_flaq = '1' then 
                        if word_counter_write = 0 then 
                            m_axi_awvalid_reg <= '0';
                        else
                            if in_empty = '0' then 
                                if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                                    if fifo_word_count < word_counter_write then 
                                        m_axi_awvalid_reg <= '0';
                                    else
                                        m_axi_awvalid_reg <= '1';
                                    end if;
                                else
                                    if fifo_word_count < BURST_LIMIT then 
                                        m_axi_awvalid_reg <= '0';
                                    else
                                        m_axi_awvalid_reg <= '1';
                                    end if;
                                end if;
                            else
                                m_axi_awvalid_reg <= '0';
                            end if;
                        end if;
                    else
                        m_axi_awvalid_reg <= '0';
                    end if;

                when others => 
                    m_axi_awvalid_reg <= '0';

            end case;                 
        end if;
    end process;

    m_axi_arvalid_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_read is
                when IDLE_ST =>
                    if CMD_VALID = '1' then 
                        if CMD_MODE = "11" then 
                            m_axi_arvalid_reg <= '0';
                        elsif CMD_MODE = "01" then 
                            m_axi_arvalid_reg <= '1';
                        else
                            m_axi_arvalid_reg <= m_axi_arvalid_reg;
                        end if;  
                    else
                        m_axi_arvalid_reg <= m_axi_arvalid_reg;    
                    end if;

                when WAIT_FOR_WRITE_ST => 
                    if current_state_write = IDLE_ST then 
                        m_axi_arvalid_reg <= '1';
                    else
                        m_axi_arvalid_reg <= '0';
                    end if;


                when READ_ST => 
                    if M_AXI_RVALID = '1' and M_AXI_RLAST = '1' then 
                        if word_counter_read = 0 then 
                            m_axi_arvalid_reg <= '0';
                        else
                            if out_pfull = '0' then 
                                m_axi_arvalid_reg <= '1';
                            else
                                m_axi_arvalid_reg <= '0';
                            end if;        
                        end if;
                    else
                        if M_AXI_ARREADY = '1' and m_axi_arvalid_reg = '1' then 
                            m_axi_arvalid_reg <= '0';
                        else
                            m_axi_arvalid_reg <= m_axi_arvalid_reg;
                        end if;
                    end if;

                when WAIT_FOR_FIFO_ABILITY_RCV_ST => 
                    if out_pfull = '0' then  
                        m_axi_arvalid_reg <= '1';
                    else
                        m_axi_arvalid_reg <= '0';
                    end if;

                when others => 
                    m_axi_arvalid_reg <= m_axi_arvalid_reg;

            end case;
        end if;
    end process;

    m_axi_bready_reg_processing : process(CLK)
    begin
        if cLK'event AND CLK = '1' then 
            m_axi_bready_reg <= '1';
        end if;
    end process;

    m_axi_wvalid_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is

                when WAIT_FOR_DATA_ST => 
                    if in_empty = '0' then 
                        if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                            if fifo_word_count < word_counter_write then 
                                m_axi_wvalid_reg <= m_axi_wvalid_reg;
                            else
                                m_axi_wvalid_reg <= '1';
                            end if;
                        else
                            if fifo_word_count < BURST_LIMIT then 
                                m_axi_wvalid_reg <= m_axi_wvalid_reg;
                            else
                                m_axi_wvalid_reg <= '1';
                            end if;
                        end if;
                    else
                        m_axi_wvalid_reg <= m_axi_wvalid_reg;
                    end if;


                when WRITE_ST =>
                    if m_axi_wlast_reg = '1' and M_AXI_WREADY = '1' then 
                        m_axi_wvalid_reg <= '0';
                    else    
                        m_axi_wvalid_reg <= '1';
                    end if;

                when WRITE_WAIT_BRESP_ST =>
                    if (M_AXI_BVALID = '1' and m_axi_bready_reg = '1') or has_bresp_flaq = '1' then 
                        if word_counter_write = 0 then 
                            m_axi_wvalid_reg <= '0';
                        else
                            if in_empty = '0' then 
                                if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                                    if fifo_word_count < word_counter_write then 
                                        m_axi_wvalid_reg <= '0';
                                    else
                                        m_axi_wvalid_reg <= '1';
                                    end if;
                                else
                                    if fifo_word_count < BURST_LIMIT then 
                                        m_axi_wvalid_reg <= '0';
                                    else
                                        m_axi_wvalid_reg <= '1';
                                    end if;
                                end if;
                            else
                                m_axi_wvalid_reg <= '0';
                            end if;
                        end if;
                    else
                        m_axi_wvalid_reg <= '0';
                    end if;


                when others => 
                    m_axi_wvalid_reg <= '0';

            end case;
        end if;
    end process;    
    
    m_axi_wlast_reg <= '1' when awburst_counter = m_axi_awlen_reg and current_state_write = WRITE_ST else '0';

    awburst_counter_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is
                when WRITE_ST => 
                    if m_axi_wvalid_reg = '1' and M_AXI_WREADY = '1' then 
                        awburst_counter <= awburst_counter + 1;
                    else
                        awburst_counter <= awburst_counter;
                    end if;

                when others => 
                    awburst_counter <= (others => '0');
            end case;
        end if;
    end process;

    m_axi_rready_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_read is

                when IDLE_ST =>

                    if CMD_VALID = '1' then 
                        if CMD_MODE = "11" then 
                            m_axi_rready_reg <= '0';
                        elsif CMD_MODE = "01" then 
                            m_axi_rready_reg <= '1';
                        else
                            m_axi_rready_reg <= '0';
                        end if;  
                    else
                        m_axi_rready_reg <= '0';    
                    end if;

                when WAIT_FOR_WRITE_ST => 
                    if current_state_write = IDLE_ST then 
                        m_axi_rready_reg <= '1';
                    else
                        m_axi_rready_reg <= '0';
                    end if;


                when READ_ST => 
                    if M_AXI_RVALID = '1' and M_AXI_RLAST = '1' and m_axi_rready_reg = '1' then 
                        if word_counter_read = 0 then 
                            m_axi_rready_reg <= '0';
                        else
                            if out_pfull = '0' then 
                                m_axi_rready_reg <= '1';
                            else
                                m_axi_rready_reg <= '0';
                            end if;
                        end if;
                    else
                        m_axi_rready_reg <= m_axi_rready_reg;
                    end if;

                when WAIT_FOR_FIFO_ABILITY_RCV_ST => 
                    if out_pfull = '0' then 
                        m_axi_rready_reg <= '1';
                    else
                        m_axi_rready_reg <= '0';
                    end if;

                when others => 
                    m_axi_rready_reg <= '0';
            end case;
        end if;
    end process;

    fifo_in_sync_counted_xpm_inst : fifo_in_sync_counted_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                      ,
            MEMTYPE         =>  "block"                         ,
            DEPTH           =>  FIFO_DEPTH                              
        )
        port map (
            CLK             =>  CLK                             ,
            RESET           =>  fifo_reset                      ,
            
            S_AXIS_TDATA    =>  S_AXIS_TDATA                    ,
            S_AXIS_TVALID   =>  S_AXIS_TVALID and write_ability ,
            S_AXIS_TLAST    =>  S_AXIS_TLAST                    ,
            S_AXIS_TREADY   =>  S_AXIS_TREADY                   ,

            IN_DOUT_DATA    =>  IN_DOUT_DATA                    ,
            IN_DOUT_LAST    =>  IN_DOUT_LAST                    ,
            IN_RDEN         =>  IN_RDEN                         ,
            IN_EMPTY        =>  IN_EMPTY                        ,

            DATA_COUNT      =>  fifo_data_count                  
        );

    fifo_reset_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then
            if RESET = '1' then 
                fifo_reset <= '1';
            else
                case current_state_write is

                    when IDLE_ST =>
                        fifo_reset <= '1';

                    when others => 
                        fifo_reset <= '0';

                end case;
            end if; 
        end if;
    end process;

    write_ability_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is
                when IDLE_ST => 
                    write_ability <= '0';

                when others =>
                    write_ability <= '1';

            end case;
        end if;
    end process;

    fifo_word_count         <= EXT(fifo_data_count(31 downto C_AXSIZE_INT), 32);

    in_rden <= '1' when m_axi_wvalid_reg = '1' and M_AXI_WREADY = '1' else '0';

    current_state_read_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                current_state_read <= IDLE_ST;
            else
                
                case current_state_read is
                    when IDLE_ST =>
                        if CMD_VALID = '1' then 
                            if CMD_MODE = "11" then 
                                current_state_read <= WAIT_FOR_WRITE_ST;
                            elsif CMD_MODE = "01" then 
                                current_state_read <= READ_ST;
                            else
                                current_state_read <= current_state_read;
                            end if;  
                        else
                            current_state_read <= current_state_read;    
                        end if;

                    when WAIT_FOR_WRITE_ST => 
                        if current_state_write = IDLE_ST then 
                            current_state_read <= READ_ST;
                        else
                            current_state_read <= current_state_read;
                        end if;

                    when READ_ST => 
                        if M_AXI_RVALID = '1' and m_axi_rready_reg = '1' and M_AXI_RLAST = '1' then 
                            if word_counter_read = 0 then 
                                current_state_read <= IDLE_ST;
                            else
                                if out_pfull = '0' then 
                                    current_state_read <= current_state_read;
                                else
                                    current_state_read <= WAIT_FOR_FIFO_ABILITY_RCV_ST;
                                end if;
                            end if;
                        else
                            current_state_read <= current_state_read;
                        end if;

                    when WAIT_FOR_FIFO_ABILITY_RCV_ST => 
                        if out_pfull = '0' then 
                            current_state_read <= READ_ST;
                        else
                            current_state_read <= current_state_read;
                        end if;
                    
                    when others => 
                        current_state_read <= current_state_read;
                end case;
            end if;
        end if;
    end process;

    current_state_write_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                current_state_write <= IDLE_ST;
            else
                
                case current_state_write is
                    when IDLE_ST =>
                        if CMD_VALID = '1' then 
                            if CMD_MODE(1) = '1' then 
                                current_state_write <= WAIT_FOR_DATA_ST;
                            else
                                current_state_write <= current_state_write;        
                            end if;  
                        else
                            current_state_write <= current_state_write;    
                        end if;

                    when WAIT_FOR_DATA_ST => 
                        if in_empty = '0' then 
                            if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                                if fifo_word_count < word_counter_write then 
                                    current_state_write <= current_state_write;
                                else
                                    current_state_write <= WRITE_ST;
                                end if;
                            else
                                if fifo_word_count < BURST_LIMIT then 
                                    current_state_write <= current_state_write;
                                else
                                    current_state_write <= WRITE_ST;
                                end if;
                            end if;
                        else
                            current_state_write <= current_state_write;
                        end if;

                    when WRITE_ST =>
                        if m_axi_wvalid_reg = '1' and M_AXI_WREADY = '1' and m_axi_wlast_reg = '1' then 
                            current_state_write <= WRITE_WAIT_BRESP_ST;
                        else
                            current_state_write <= current_state_write;
                        end if;

                    when WRITE_WAIT_BRESP_ST => 
                        if (M_AXI_BVALID = '1' and m_axi_bready_reg = '1') or has_bresp_flaq = '1' then 
                            if word_counter_write = 0 then 
                                -- Здесь надо анализировать еще команду, возможно надо будет сразу переходить к чтению 
                                current_state_write <= IDLE_ST;
                            else
                                if in_empty = '0' then 
                                    if word_counter_write <= conv_std_logic_Vector ( BURST_LIMIT-1, word_counter_write'length) then 
                                        if fifo_word_count < word_counter_write then 
                                            current_state_write <= current_state_write;
                                        else
                                            current_state_write <= WRITE_ST;
                                        end if;
                                    else
                                        if fifo_word_count < BURST_LIMIT then 
                                            current_state_write <= current_state_write;
                                        else
                                            current_state_write <= WRITE_ST;
                                        end if;
                                    end if;
                                else
                                    current_state_write <= current_state_write;
                                end if;
                            end if;
                        else
                            current_state_write <= current_state_write;
                        end if;

                    when others => 
                        current_state_write <= current_state_write;
                end case;
            end if;
        end if;
    end process;

    has_bresp_flaq_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state_write is
                when WRITE_WAIT_BRESP_ST =>
                    if M_AXI_BVALID = '1' and m_axi_bready_reg = '1' then 
                        has_bresp_flaq <= '1';
                    else
                        has_bresp_flaq <= has_bresp_flaq;
                    end if;

                when others => 
                    has_bresp_flaq <= '0';

            end case;
        end if;
    end process;

    fifo_out_pfull_sync_xpm_inst : fifo_out_pfull_sync_xpm
        generic map (
            DATA_WIDTH      =>  DATA_WIDTH                      ,
            MEMTYPE         =>   "block"                        ,
            DEPTH           =>  FIFO_DEPTH                      ,
            PFULL_ASSERT    =>  BURST_LIMIT                                                 
        )
        port map (
            CLK             =>  CLK                             ,
            RESET           =>  RESET                           ,
            
            OUT_DIN_DATA    =>  out_din_data                    ,
            OUT_DIN_KEEP    =>  (others => '0')                 ,
            OUT_DIN_LAST    =>  out_din_last                    ,
            OUT_WREN        =>  out_wren                        ,
            OUT_PFULL       =>  out_pfull                       ,
            OUT_FULL        =>  out_full                        ,

            M_AXIS_TDATA    =>  M_AXIS_TDATA                    ,
            M_AXIS_TKEEP    =>  open                            ,
            M_AXIS_TVALID   =>  M_AXIS_TVALID                   ,
            M_AXIS_TLAST    =>  M_AXIS_TLAST                    ,
            M_AXIS_TREADY   =>  M_AXIS_TREADY                    

        );

    out_din_data    <=  M_AXI_RDATA             ;
    out_wren        <=  M_AXI_RVALID            ;
    out_din_last    <= '1' when word_counter_read = 0 and M_AXI_RVALID = '1' and M_AXI_RLAST = '1' else '0';



end axis_ddr_mgr_fd_arch;
