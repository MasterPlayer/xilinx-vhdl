library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

entity axis_checker is
    generic (
        N_BYTES                 :           integer   := 4                                  ;
        TIMER_LIMIT             :           integer   := 156250000                          ;
        MODE                    :           string    := "SINGLE"  -- "ZEROS" "BYTE"
    );
    port(
        CLK                     :   in      std_logic                                       ;
        RESET                   :   in      std_logic                                       ;
        
        S_AXIS_TDATA            :   in      std_logic_vector ( (N_BYTES*8)-1 downto 0 )     ;
        S_AXIS_TKEEP            :   in      std_logic_vector ( N_BYTES-1 downto 0 )         ;
        S_AXIS_TVALID           :   in      std_logic                                       ;
        S_AXIS_TREADY           :   out     std_logic                                       ;
        S_AXIS_TLAST            :   in      std_logic                                       ;
        
        ENABLE                  :   in      std_logic                                       ;
        PACKET_SIZE             :   in      std_logic_vector ( 31 downto 0 )                ;

        READY_LIMIT             :   in      std_logic_Vector ( 31 downto 0 )                ;
        NOT_READY_LIMIT         :   in      std_logic_Vector ( 31 downto 0 )                ;

        DATA_ERROR              :   out     std_logic_vector ( 31 downto 0 )                ;
        PACKET_ERROR            :   out     std_logic_vector ( 31 downto 0 )                ;
        DATA_SPEED              :   out     std_logic_vector ( 31 downto 0 )                ;
        PACKET_SPEED            :   out     std_logic_vector ( 31 downto 0 )                ;
        HAS_PACKET_ERR          :   out     std_logic                                       ;
        HAS_DATA_ERR            :   out     std_logic                           
    );
end axis_checker;



architecture axis_checker_arch of axis_checker is

    constant DATA_WIDTH         :           integer := (N_BYTES*8);

    -- счетчик по которому будут сравниваться значения по ошибке. Настраивается по функции MODE
    signal  cnt_fill            :           std_logic_vector ( DATA_WIDTH-1 downto 0 )  := (others => '0')      ;

    signal  has_data_err_reg    :           std_logic                           := '0'                  ;

    -- Готовность блока к приему данных - конфигуратор READY сигналов
    signal  ready_1_cnt         :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;
    signal  ready_0_cnt         :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;
    signal  s_axis_tready_reg   :           std_logic                           := '0'                  ;

    type fsm is(
        IDLE_ST             ,
        CHK_IS_READY_ST     ,
        CHk_NOT_RDY_ST    
    );

    signal  current_state       :           fsm                                 := IDLE_ST;

    signal  save_for_first      :           std_logic                           := '1';

    signal  data_error_reg      :           std_logic_vector ( 31 downto 0 )    := (others => '0')                 ;
    signal  packet_error_reg    :           std_logic_vector ( 31 downto 0 )    := (others => '0')                 ;
    
    signal  timer_cnt           :           std_logic_Vector ( 31 downto 0 )    := (others => '0')                  ;

    signal  data_speed_reg      :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;
    signal  data_speed_cnt      :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;

    signal  packet_speed_reg    :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;
    signal  packet_speed_cnt    :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;

    signal  has_packet_err_reg  :           std_logic                           := '0'                              ;
    signal  packet_size_cnt     :           std_logic_vector ( 31 downto 0 )    := x"00000001"                      ;        
    signal  packet_size_reg     :           std_logic_vector ( 31 downto 0 )    := (others => '0')                  ;
begin

    S_AXIS_TREADY <= s_axis_tready_reg;

    s_axis_tready_reg <= '1' when current_state = CHK_IS_READY_ST else '0';

    DATA_SPEED      <= data_speed_reg       ;
    PACKET_SPEED    <= packet_speed_reg     ;

    DATA_ERROR      <= data_error_reg       ;
    HAS_DATA_ERR    <= has_data_err_reg     ;

    PACKET_ERROR    <= packet_error_reg     ;
    HAS_PACKET_ERR  <= has_packet_err_reg   ;

    packet_size_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when IDLE_ST =>
                    if ENABLE = '1' then
                        packet_size_reg <= PACKET_SIZE;
                    else
                        packet_size_reg <= packet_size_reg;
                    end if;

                when others => 
                    packet_size_reg <= packet_size_reg;

            end case;
        end if;
    end process;

    current_state_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                current_state <= IDLE_ST;
            else

                case current_state is
                    when IDLE_ST =>
                        if ENABLE = '1' then 
                            current_state <= CHK_IS_READY_ST;
                        else
                            current_state <= current_state;
                        end if;

                    when CHK_IS_READY_ST =>
                        if ready_1_cnt < READY_LIMIT-1 then 
                            current_state <= current_state;
                        else
                            if NOT_READY_LIMIT = 0 then 
                                current_state <= current_state;
                            else
                                if ENABLE = '0' then 
                                    current_state <= IDLE_ST;
                                else    
                                    current_state <= CHk_NOT_RDY_ST;
                                end if;
                            end if;
                        end if;

                    when CHk_NOT_RDY_ST => 
                        if ready_0_cnt < NOT_READY_LIMIT-1 then 
                            current_state <= current_state;
                        else
                            if ENABLE = '0' then 
                                current_state <= IDLE_ST;
                            else
                                current_state <= CHK_IS_READY_ST;
                            end if;
                        end if;

                    when others => 
                        current_state <= IDLE_ST;

                end case;
            end if;
        end if;
    end process;

    ready_1_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case current_state is
                when CHK_IS_READY_ST =>
                    if s_axis_tready_reg = '1' and S_AXIS_TVALID = '1' then 
                        if ready_1_cnt < READY_LIMIT then 
                            ready_1_cnt <= ready_1_cnt + 1;
                        else
                            ready_1_cnt <= (others => '0');
                        end if;
                    else
                        ready_1_cnt <= ready_1_cnt;
                    end if;

                when others => 
                    ready_1_cnt <= (others => '0');
            end case;
        end if; 
    end process;

    ready_0_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 

            case current_state is
                when CHk_NOT_RDY_ST =>
                    if ready_0_cnt < NOT_READY_LIMIT then 
                        ready_0_cnt <= ready_0_cnt + 1;
                    else
                        ready_0_cnt <= ready_0_cnt;
                    end if;

                when others => 
                    ready_0_cnt <= (others => '0');

            end case;
        end if;
    end process;


    MODE_ZEROS_GEN : if MODE = "ZEROS" generate
        
        cnt_fill <= (others => '0');

        has_data_err_reg_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if ENABLE = '1' then 
                    if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                        if S_AXIS_TDATA = cnt_fill then 
                            has_data_err_reg <= '0'; 
                        else
                            has_data_err_reg <= '1';
                        end if;
                    else
                        has_data_err_reg <= '0';                        
                    end if;
                else
                    has_data_err_reg <= '0';
                end if;
            end if;
        end process;

    end generate;


    MODE_SINGLE_GEN : if MODE = "SINGLE" generate

        cnt_fill_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    cnt_fill <= (others => '0') ;
                else
                    if ENABLE = '1' then 
                        if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                            if save_for_first = '1' then 
                                cnt_fill <= S_AXIS_TDATA + 1;
                            else
                                if cnt_fill /= S_AXIS_TDATA then 
                                    cnt_fill <= S_AXIS_TDATA + 1;
                                else
                                    cnt_fill <= cnt_fill + 1;
                                end if;
                            end if;
                        else
                            cnt_fill <= cnt_fill;
                        end if;
                    else
                        cnt_fill <= (others => '0') ;
                    end if;

                end if;
            end if;
        end process;

        save_for_first_processing : process(CLK)
        begin
            if CLK'event aND CLK = '1' then 
                if RESET = '1' then 
                    save_for_first <= '1';
                else
                    
                    if ENABLE = '1' then 
                        if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                            save_for_first <= '0';
                        else
                            save_for_first <= save_for_first;
                        end if;
                    else
                        save_for_first <= '1';
                    end if;

                end if;
            end if;
        end process;

        has_data_err_reg_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    has_data_err_reg <= '0';
                else
                    if ENABLE = '1' then 
                        if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                            if save_for_first = '1' then 
                                has_data_err_reg <= '0';
                            else
                                if S_AXIS_TDATA = cnt_fill then 
                                    has_data_err_reg <= '0';
                                else
                                    has_data_err_reg <= '1';
                                end if;
                            end if;
                        else
                            has_data_err_reg <= '0';
                        end if;
                    else
                        has_data_err_reg <= '0';
                    end if;
                end if;
            end if;
        end process;

    end generate;



    BYTE_MODE_GEN : if MODE = "BYTE" generate
           
        BYTE_CNT_GEN : for i in 0 to N_BYTES-1 generate 

            cnt_fill_processing : process(CLK)
            begin
                if CLK'event AND CLK = '1' then 
                    if RESET = '1' then 
                        cnt_fill( (((i+1)*8)-1) downto  (i*8)) <= conv_std_logic_Vector( ((256 - N_BYTES) + i) , 8);
                    else
                        if ENABLE = '1' then
                            if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                                if save_for_first = '1' then 
                                    cnt_fill((((i+1)*8)-1) downto  (i*8)) <= S_AXIS_TDATA((((i+1)*8)-1) downto  (i*8)) + conv_std_logic_Vector(N_BYTES, 8);
                                else
                                    if cnt_fill((((i+1)*8)-1) downto  (i*8)) /= S_AXIS_TDATA((((i+1)*8)-1) downto  (i*8)) then
                                        cnt_fill((((i+1)*8)-1) downto  (i*8)) <= S_AXIS_TDATA((((i+1)*8)-1) downto  (i*8)) + conv_std_logic_Vector(N_BYTES, 8);
                                    else
                                        cnt_fill((((i+1)*8)-1) downto  (i*8)) <= cnt_fill((((i+1)*8)-1) downto  (i*8)) + conv_std_logic_Vector(N_BYTES, 8);
                                    end if;
                                
                                end if;
                            else        
                                cnt_fill((((i+1)*8)-1) downto  (i*8)) <= cnt_fill((((i+1)*8)-1) downto  (i*8));
                            end if;
                        else
                            cnt_fill((((i+1)*8)-1) downto  (i*8)) <= cnt_fill((((i+1)*8)-1) downto  (i*8));
                        end if;
                    end if;
                end if;
            end process;

        end generate;


        save_for_first_processing : process(CLK)
        begin
            if CLK'event aND CLK = '1' then 
                if RESET = '1' then 
                    save_for_first <= '1';
                else
                    
                    if ENABLE = '1' then 
                        if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                            save_for_first <= '0';
                        else
                            save_for_first <= save_for_first;
                        end if;
                    else
                        save_for_first <= '1';
                    end if;

                end if;
            end if;
        end process;

        has_data_err_reg_processing : process(CLK)
        begin
            if CLK'event AND CLK = '1' then 
                if RESET = '1' then 
                    has_data_err_reg <= '0';
                else
                    if ENABLE = '1' then 
                        if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                            if save_for_first = '1' then 
                                has_data_err_reg <= '0';
                            else
                                if S_AXIS_TDATA = cnt_fill then 
                                    has_data_err_reg <= '0';
                                else
                                    has_data_err_reg <= '1';
                                end if;
                            end if;
                        else
                            has_data_err_reg <= '0';
                        end if;
                    else
                        has_data_err_reg <= '0';
                    end if;
                end if;
            end if;
        end process;

    end generate;

    data_error_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                data_error_reg <= (others => '0') ;
            else
                if ENABLE = '1' then 

                    if has_data_err_reg = '1' then 
                        data_error_reg <= data_error_reg + 1;
                    else
                        data_error_reg <= data_error_reg;
                    end if;

                else
                    data_error_reg <= (others => '0') ;
                end if;
                
            end if;
        end if;
    end process;

    timer_cnt_processing : process(CLK)
    begin
        if CLK'event aND CLK = '1' then 
            if RESET = '1' then 
                timer_cnt <= (others => '0') ;
            else
                if timer_cnt < TIMER_LIMIT-1 then 
                    timer_cnt <= timer_cnt + 1;
                else
                    timer_cnt <= (others => '0') ;
                end if;
            end if;
        end if;
    end process;

    data_speed_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                data_speed_cnt <= (others => '0');
            else
                if timer_cnt < TIMER_LIMIT-1 then 
                    if s_axis_tready_reg = '1' and S_AXIS_TVALID = '1' then 
                        data_speed_cnt <= data_speed_cnt + N_BYTES;
                    else
                        data_speed_cnt <= data_speed_cnt;
                    end if;
                else
                    data_speed_cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    data_speed_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                data_speed_reg <= (others => '0') ;
            else
                if timer_cnt < TIMER_LIMIT-1 then 
                    data_speed_reg <= data_speed_reg;
                else
                    if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                        data_speed_reg <= data_speed_cnt + N_BYTES;
                    else
                        data_speed_reg <= data_speed_cnt;
                    end if;
                end if;
            end if;
        end if;
    end process;


    packet_size_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                packet_size_cnt <= x"00000001";
            else
                if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        packet_size_cnt <= x"00000001";
                    else
                        packet_size_cnt <= packet_size_cnt + 1;
                    end if;
                else
                    packet_size_cnt <= packet_size_cnt;
                end if;
            end if;
        end if;
    end process;

    has_packet_err_reg_processing : process(CLK)
    begin
        if CLK'event aND CLK = '1' then 
            if RESET = '1' then 
                has_packet_err_reg <= '0';
            else
                if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        if packet_size_reg = 0 then 
                            has_packet_err_reg <= '0';
                        else
                            if packet_size_cnt = packet_size_reg then 
                                has_packet_err_reg <= '0';
                            else
                                has_packet_err_reg <= '1';
                            end if;
                        end if;
                    else
                        has_packet_err_reg <= '0';
                    end if;
                else
                    has_packet_err_reg <= '0';
                end if;

            end if;
        end if; 
    end process;

    packet_error_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                packet_error_reg <= (others => '0');
            else
                if has_packet_err_reg = '1' then 
                    packet_error_reg <= packet_error_reg + 1;
                else
                    packet_error_reg <= packet_error_reg;
                end if;
            end if;
        end if;
    end process;

    packet_speed_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if timer_cnt < TIMER_LIMIT-1 then 
                packet_speed_reg <= packet_speed_reg;
            else
                if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        packet_speed_reg <= packet_speed_cnt + 1;
                    else
                        packet_speed_reg <= packet_speed_cnt;
                    end if;
                else
                    packet_speed_reg <= packet_speed_cnt;
                end if;
            end if;
        end if;
    end process;

    packet_speed_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if timer_cnt < TIMER_LIMIT-1 then 
                if S_AXIS_TVALID = '1' and s_axis_tready_reg = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        packet_speed_cnt <= packet_speed_cnt + 1;
                    else
                        packet_speed_cnt <= packet_speed_cnt;
                    end if;
                else
                    packet_speed_cnt <= packet_speed_cnt;
                end if;
            else
                packet_speed_cnt <= (others => '0');
            end if;
        end if;
    end process;


end axis_checker_arch;
