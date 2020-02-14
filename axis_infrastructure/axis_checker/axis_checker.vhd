library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;



entity axis_checker is
    generic(
        FILL_ZEROS              :           boolean   := true                               ;
        TIMER_LIMIT             :           integer   := 156250000                          ;
        DATA_WIDTH              :           integer   := 32                                 ;
        IGNORE_LAST             :           boolean   := true                               ;   --игнорировать TREADY(не пересчитывать размер пакета)
        SIMPLE_COUNTER          :           boolean   := true                                
    );
    port(
        ACLK                    :   in      std_logic                                       ;
        ARESETN                 :   in      std_logic                                       ;
        S_AXIS_TDATA            :   in      std_logic_vector ( DATA_WIDTH-1 downto 0 )      ;
        S_AXIS_TKEEP            :   in      std_logic_vector ( DATA_WIDTH/8-1 downto 0 )    ;
        S_AXIS_TVALID           :   in      std_logic                                       ;
        S_AXIS_TREADY           :   out     std_logic                                       ;
        S_AXIS_TLAST            :   in      std_logic                                       ;
        ENABLE                  :   in      std_logic                                       ;
        PACKET_SIZE             :   in      std_logic_vector ( 31 downto 0 )                ;
        DATA_ERROR              :   out     std_logic_vector ( 31 downto 0 )                ;
        PACKET_ERROR            :   out     std_logic_vector ( 31 downto 0 )                ;
        DATA_SPEED              :   out     std_logic_vector ( 31 downto 0 )                ;
        PACKET_SPEED            :   out     std_logic_vector ( 31 downto 0 )                ;
        HAS_PACKET_ERR          :   out     std_logic                                       ;
        HAS_DATA_ERR            :   out     std_logic                           
    );
end axis_checker;



architecture axis_checker_arch of axis_checker is

    signal  sready_reg          :   std_logic                        := '0';

    signal  cnt0                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt1                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt2                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt3                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt4                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt5                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt6                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt7                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt8                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt9                :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt10               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt11               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt12               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt13               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt14               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt15               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt16               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt17               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt18               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt19               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt20               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt21               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt22               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt23               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt24               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt25               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt26               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt27               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt28               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt29               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt30               :   std_logic_Vector (  7 downto 0 ) := (others => '0');
    signal  cnt31               :   std_logic_Vector (  7 downto 0 ) := (others => '0');


    signal  data_cnt_reg        :   std_logic_vector ( 31 downto 0 ) := (others => '0');

    signal  data_error_reg      :   std_logic_Vector ( 31 downto 0 ) := (others => '0');
    signal  packet_error_reg    :   std_logic_Vector ( 31 downto 0 ) := (others => '0');
    
    signal  timer               :   std_logic_Vector ( 31 downto 0 ) := (others => '0');
    signal  packet_speed_cnt    :   std_logic_Vector ( 31 downto 0 ) := (others => '0');
    signal  data_speed_cnt      :   std_logic_vector ( 31 downto 0 ) := (others => '0');

    signal  data_speed_reg      :   std_logic_Vector ( 31 downto 0 ) := (others => '0');
    signal  packet_speed_reg    :   std_logic_Vector ( 31 downto 0 ) := (others => '0');

    signal  has_packet_err_reg  :   std_logic := '0'; 
    signal  has_data_err_reg    :   std_logic := '0';   

    signal  cnt_fill            :   std_logic_vector ( DATA_WIDTH-1 downto 0 ) := (others => '0')   ;

begin


    PACKET_SPEED    <=  packet_speed_reg    ;
    DATA_SPEED      <=  data_speed_reg      ;

    PACKET_ERROR    <=  packet_error_reg    ;
    DATA_ERROR      <=  data_error_reg      ;

    HAS_DATA_ERR    <=  has_data_err_reg     ;
    HAS_PACKET_ERR  <=  has_packet_err_reg   ;


    has_data_err_reg_processing : process(ACLK)
    begin
        if ACLK'event AND ACLK = '1' then 
            if ARESETN = '0' then 
                has_data_err_reg     <= '0';
            else
                
                if data_error_reg > 0 then 
                    has_data_err_reg    <= '1';
                else
                    has_data_err_reg    <= has_data_err_reg    ;    
                end if;

            end if;
        end if;
    end process;



    timer_processing : process(ACLK)
    begin

        if ACLK'event AND ACLK = '1' then 
            if ARESETN = '0' then
                timer <= (others => '0');
            else
                if timer < TIMER_LIMIT-1 then 
                    timer <= timer + 1;
                else
                    timer <= (others => '0');
                end if;
            end if;
        end if;
    end process;




    data_speed_cnt_processing : process(ACLK)
    begin
        if ACLK'event AND ACLK = '1' then 
            if ARESETN = '0' then 
                data_speed_cnt <= (others => '0');
            else
                if timer < TIMER_LIMIT-1 then 

                    if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                        data_speed_cnt <= data_speed_cnt + 1;
                    else
                        data_speed_cnt <= data_speed_cnt; 
                    end if;

                else
                    data_speed_cnt <= (others => '0');        
                end if;    
            end if;
        end if;
    end process;



    data_speed_reg_processing : process(ACLK)
    begin
        if ACLK'event AND ACLK = '1' then 
            if ARESETN =  '0' then 
                data_speed_reg   <= (others => '0');
            else
                
                if timer = TIMER_LIMIT-1 then 
                    data_speed_reg <= data_speed_cnt;
                else
                    data_speed_reg <= data_speed_reg;
                end if;

            end if;
        end if;
    end process;





    S_AXIS_TREADY <= sready_reg ;




    IGNORE_LAST_GEN : if IGNORE_LAST = true generate 
        has_packet_err_reg      <= '0';
        packet_speed_cnt        <= (others => '0');
        packet_speed_reg        <= (others => '0');
        PACKET_ERROR            <= packet_error_reg;
        packet_error_reg        <= (others => '0');
        data_cnt_reg            <= (others => '0');
    end generate;



    NOT_IGNORE_LAST_GEN : if IGNORE_LAST = false generate 



        has_packet_err_reg_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    has_packet_err_reg   <= '0';
                else
                    
                    if packet_error_reg > 0 then 
                        has_packet_err_reg  <= '1';
                    else
                        has_packet_err_reg  <= has_packet_err_reg  ;    
                    end if;

                end if;
            end if;
        end process;



        packet_speed_cnt_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    packet_speed_cnt <= (others => '0');
                else
                    if timer < TIMER_LIMIT-1 then 
                        if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                            
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
            end if;
        end process;



        packet_speed_reg_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN =  '0' then 
                    packet_speed_reg <= (others => '0');
                else
                    
                    if timer = TIMER_LIMIT-1 then 
                        packet_speed_reg <= packet_speed_cnt;
                    else
                        packet_speed_reg <= packet_speed_reg;
                    end if;

                end if;
            end if;
        end process;



        PACKET_ERROR <= packet_error_reg;



        packet_error_reg_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    packet_error_reg <= (others => '0');
                else
                    
                    if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                        if S_AXIS_TLAST = '1' then 
                            if data_cnt_reg /= PACKET_SIZE-1 then 
                                packet_error_reg <= packet_error_reg + 1;
                            else
                                packet_error_reg <= packet_error_reg;
                            end if;
                        else
                            packet_error_reg <= packet_error_reg;
                        end if;
                    else
                        packet_error_reg <= packet_error_reg ;
                    end if;

                end if;
            end if;
        end process;


    
        data_cnt_reg_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    data_cnt_reg <= (others => '0');
                else
                    
                    if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                        if S_AXIS_TLAST = '1' then 
                            data_cnt_reg <= (others => '0');
                        else
                            data_cnt_reg <= data_cnt_reg + 1;
                        end if;
                    else
                        data_cnt_reg <= data_cnt_reg;    
                    end if;

                end if;
            end if;
        end process;

    end generate;



    sready_reg_processing : process(ACLK)
    begin
        if ACLK'event AND ACLK = '1' then 
            if ARESETN = '0' then 
                sready_reg <= '0';    
            else
                sready_reg <= ENABLE;
            end if;
        end if;
    end process;


    GEN_SIMPLE_COUNTER_OFF : if SIMPLE_COUNTER = false generate

        W8_GEN : if DATA_WIDTH = 8 generate

            FILL_ZEROS_off : if FILL_ZEROS = false generate 

                data_error_reg8_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 

                                if (cnt0 /= S_AXIS_TDATA( 7 downto 0 )) then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;




                cnt8_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            cnt0 <= x"00";
                        else
                            if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                                cnt0 <= cnt0 + 1 ;
                            else
                                cnt0 <= cnt0 ;
                            end if;

                        end if;
                    end if;
                end process;

            end generate ;
        


            FILL_ZEROS_on : if FILL_ZEROS = true generate 

                data_error_reg8_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 

                                if ( S_AXIS_TDATA( 7 downto 0 ) /= 0) then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;

            end generate ;
        
        


        end generate;




        W32_GEN : if DATA_WIDTH = 32 generate


            FILL_ZEROS_off : if FILL_ZEROS = false generate 

                data_error_reg32_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 

                                if (cnt0 /= S_AXIS_TDATA( 7 downto 0 )) or (cnt1 /= S_AXIS_TDATA( 15 downto 8 )) or (cnt2 /= S_AXIS_TDATA( 23 downto 16 )) or (cnt3 /= S_AXIS_TDATA( 31 downto 24 ))  then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;




                cnt32_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            cnt0 <= x"00";
                            cnt1 <= x"01";
                            cnt2 <= x"02";
                            cnt3 <= x"03";
                        else
                            if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                                cnt0 <= cnt0 + 4;
                                cnt1 <= cnt1 + 4;
                                cnt2 <= cnt2 + 4;
                                cnt3 <= cnt3 + 4;
                            else
                                cnt0 <= cnt0 ;
                                cnt1 <= cnt1 ;
                                cnt2 <= cnt2 ;
                                cnt3 <= cnt3 ;
                            end if;

                        end if;
                    end if;
                end process;

            end generate;



            FILL_ZEROS_on : if FILL_ZEROS = true generate 

                data_error_reg8_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 

                                if ( S_AXIS_TDATA /= 0) then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;
            end generate;



        end generate;



        W64_GEN : if DATA_WIDTH = 64 generate


            FILL_ZEROS_off : if FILL_ZEROS = false generate 


                data_error_reg64_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                if (cnt0 /= S_AXIS_TDATA( 7 downto 0 )) or 
                                (cnt1 /= S_AXIS_TDATA( 15 downto 8 )) or 
                                (cnt2 /= S_AXIS_TDATA( 23 downto 16 )) or (cnt3 /= S_AXIS_TDATA( 31 downto 24 )) or (cnt4 /= S_AXIS_TDATA( 39 downto 32 )) or (cnt5 /= S_AXIS_TDATA( 47 downto 40 )) or (cnt6 /= S_AXIS_TDATA( 55 downto 48 )) or (cnt7 /= S_AXIS_TDATA( 63 downto 56 )) then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;



                cnt64_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            cnt0    <= x"00";
                            cnt1    <= x"01";
                            cnt2    <= x"02";
                            cnt3    <= x"03";
                            cnt4    <= x"04";
                            cnt5    <= x"05";
                            cnt6    <= x"06";
                            cnt7    <= x"07";
                        else
                            if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                                cnt0 <= cnt0 + 8;
                                cnt1 <= cnt1 + 8;
                                cnt2 <= cnt2 + 8;
                                cnt3 <= cnt3 + 8;
                                cnt4 <= cnt4 + 8;
                                cnt5 <= cnt5 + 8;
                                cnt6 <= cnt6 + 8;
                                cnt7 <= cnt7 + 8;
                            else
                                cnt0 <= cnt0 ;
                                cnt1 <= cnt1 ;
                                cnt2 <= cnt2 ;
                                cnt3 <= cnt3 ;
                                cnt4 <= cnt4 ;
                                cnt5 <= cnt5 ;
                                cnt6 <= cnt6 ;
                                cnt7 <= cnt7 ;
                            end if;
                        end if;
                    end if;
                end process;


            end generate;

                FILL_ZEROS_on : if FILL_ZEROS = true generate 

                    data_error_reg64_processing : process(ACLK)
                    begin
                        if ACLK'event AND ACLK = '1' then 
                            if ARESETN = '0' then 
                                data_error_reg <= (others => '0');
                            else
                                if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                    if S_AXIS_TDATA /= 0 then 
                                        data_error_reg <= data_error_reg + 1;
                                    else
                                        data_error_reg <= data_error_reg;        
                                    end if; 
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 

                            end if;
                        end if;
                    end process;
                end generate;

        end generate;


        W128_GEN : if DATA_WIDTH = 128 generate


            fill_zeros_off : if FILL_ZEROS = false generate 
                data_error_reg128_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                if (cnt0 /= S_AXIS_TDATA( 7 downto 0 )) or 
                                (cnt1    /= S_AXIS_TDATA(  15 downto 8  )) or 
                                (cnt2    /= S_AXIS_TDATA(  23 downto 16 )) or 
                                (cnt3    /= S_AXIS_TDATA(  31 downto 24 )) or 
                                (cnt4    /= S_AXIS_TDATA(  39 downto 32 )) or 
                                (cnt5    /= S_AXIS_TDATA(  47 downto 40 )) or 
                                (cnt6    /= S_AXIS_TDATA(  55 downto 48 )) or 
                                (cnt7    /= S_AXIS_TDATA(  63 downto 56 )) or 
                                (cnt8    /= S_AXIS_TDATA(  71 downto 64 )) or
                                (cnt9    /= S_AXIS_TDATA(  79 downto 72 )) or
                                (cnt10   /= S_AXIS_TDATA(  87 downto 80 )) or
                                (cnt11   /= S_AXIS_TDATA(  95 downto 88 )) or
                                (cnt12   /= S_AXIS_TDATA( 103 downto 96 )) or
                                (cnt13   /= S_AXIS_TDATA( 111 downto 104)) or
                                (cnt14   /= S_AXIS_TDATA( 119 downto 112)) or
                                (cnt15   /= S_AXIS_TDATA( 127 downto 120)) then 
                                data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;



                cnt128_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            cnt0    <= x"00";
                            cnt1    <= x"01";
                            cnt2    <= x"02";
                            cnt3    <= x"03";
                            cnt4    <= x"04";
                            cnt5    <= x"05";
                            cnt6    <= x"06";
                            cnt7    <= x"07";
                            cnt8    <= x"08";
                            cnt9    <= x"09";
                            cnt10   <= x"0A";
                            cnt11   <= x"0B";
                            cnt12   <= x"0C";
                            cnt13   <= x"0D";
                            cnt14   <= x"0E";
                            cnt15   <= x"0F";
                        else
                            if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                                cnt0    <=  cnt0    + 16;
                                cnt1    <=  cnt1    + 16;
                                cnt2    <=  cnt2    + 16;
                                cnt3    <=  cnt3    + 16;
                                cnt4    <=  cnt4    + 16;
                                cnt5    <=  cnt5    + 16;
                                cnt6    <=  cnt6    + 16;
                                cnt7    <=  cnt7    + 16;
                                cnt8    <=  cnt8    + 16;
                                cnt9    <=  cnt9    + 16;
                                cnt10   <=  cnt10   + 16;
                                cnt11   <=  cnt11   + 16;
                                cnt12   <=  cnt12   + 16;
                                cnt13   <=  cnt13   + 16;
                                cnt14   <=  cnt14   + 16;
                                cnt15   <=  cnt15   + 16;
                            else
                                cnt1    <=  cnt1    ;
                                cnt2    <=  cnt2    ;
                                cnt3    <=  cnt3    ;
                                cnt4    <=  cnt4    ;
                                cnt5    <=  cnt5    ;
                                cnt6    <=  cnt6    ;
                                cnt7    <=  cnt7    ;
                                cnt8    <=  cnt8    ;
                                cnt9    <=  cnt9    ;
                                cnt10   <=  cnt10   ;
                                cnt11   <=  cnt11   ;
                                cnt12   <=  cnt12   ;
                                cnt13   <=  cnt13   ;
                                cnt14   <=  cnt14   ;
                                cnt15   <=  cnt15   ;
                            end if;
                        end if;
                    end if;
                end process;
            end generate;



            FILL_ZEROS_on : if FILL_ZEROS = true generate 

                data_error_reg128_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                if S_AXIS_TDATA /= 0 then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;
            end generate;


        end generate;



        W256_GEN : if DATA_WIDTH = 256 generate


            fill_zeros_off : if FILL_ZEROS = false generate 
                data_error_reg256_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                if (cnt0 /= S_AXIS_TDATA( 7 downto 0 )) or 
                                (cnt1 /= S_AXIS_TDATA(  15 downto 8  )) or 
                                (cnt2 /= S_AXIS_TDATA(  23 downto 16 )) or 
                                (cnt3 /= S_AXIS_TDATA(  31 downto 24 )) or 
                                (cnt4 /= S_AXIS_TDATA(  39 downto 32 )) or 
                                (cnt5 /= S_AXIS_TDATA(  47 downto 40 )) or 
                                (cnt6 /= S_AXIS_TDATA(  55 downto 48 )) or 
                                (cnt7 /= S_AXIS_TDATA(  63 downto 56 )) or 
                                (cnt8 /= S_AXIS_TDATA(  71 downto 64 )) or
                                (cnt9 /= S_AXIS_TDATA(  79 downto 72 )) or
                                (cnt10/= S_AXIS_TDATA(  87 downto 80 )) or
                                (cnt11/= S_AXIS_TDATA(  95 downto 88 )) or
                                (cnt12/= S_AXIS_TDATA( 103 downto 96 )) or
                                (cnt13/= S_AXIS_TDATA( 111 downto 104)) or
                                (cnt14/= S_AXIS_TDATA( 119 downto 112)) or
                                (cnt15/= S_AXIS_TDATA( 127 downto 120)) or
                                (cnt16/= S_AXIS_TDATA( 135 downto 128)) or
                                (cnt17/= S_AXIS_TDATA( 143 downto 136)) or
                                (cnt18/= S_AXIS_TDATA( 151 downto 144)) or
                                (cnt19/= S_AXIS_TDATA( 159 downto 152)) or
                                (cnt20/= S_AXIS_TDATA( 167 downto 160)) or
                                (cnt21/= S_AXIS_TDATA( 175 downto 168)) or
                                (cnt22/= S_AXIS_TDATA( 183 downto 176)) or
                                (cnt23/= S_AXIS_TDATA( 191 downto 184)) or
                                (cnt24/= S_AXIS_TDATA( 199 downto 192)) or
                                (cnt25/= S_AXIS_TDATA( 207 downto 200)) or
                                (cnt26/= S_AXIS_TDATA( 215 downto 208)) or
                                (cnt27/= S_AXIS_TDATA( 223 downto 216)) or
                                (cnt28/= S_AXIS_TDATA( 231 downto 224)) or
                                (cnt29/= S_AXIS_TDATA( 239 downto 232)) or
                                (cnt30/= S_AXIS_TDATA( 247 downto 240)) or
                                (cnt31/= S_AXIS_TDATA( 255 downto 248)) then 
                                data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;



                cnt256_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            cnt0    <= x"00";
                            cnt1    <= x"01";
                            cnt2    <= x"02";
                            cnt3    <= x"03";
                            cnt4    <= x"04";
                            cnt5    <= x"05";
                            cnt6    <= x"06";
                            cnt7    <= x"07";
                            cnt8    <= x"08";
                            cnt9    <= x"09";
                            cnt10   <= x"0A";
                            cnt11   <= x"0B";
                            cnt12   <= x"0C";
                            cnt13   <= x"0D";
                            cnt14   <= x"0E";
                            cnt15   <= x"0F";
                            cnt16   <= x"10";
                            cnt17   <= x"11";
                            cnt18   <= x"12";
                            cnt19   <= x"13";
                            cnt20   <= x"14";
                            cnt21   <= x"15";
                            cnt22   <= x"16";
                            cnt23   <= x"17";
                            cnt24   <= x"18";
                            cnt25   <= x"19";
                            cnt26   <= x"1A";
                            cnt27   <= x"1B";
                            cnt28   <= x"1C";
                            cnt29   <= x"1D";
                            cnt30   <= x"1E";
                            cnt31   <= x"1F";
                        else
                            if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                                cnt0    <=  cnt0    + 32;
                                cnt1    <=  cnt1    + 32;
                                cnt2    <=  cnt2    + 32;
                                cnt3    <=  cnt3    + 32;
                                cnt4    <=  cnt4    + 32;
                                cnt5    <=  cnt5    + 32;
                                cnt6    <=  cnt6    + 32;
                                cnt7    <=  cnt7    + 32;
                                cnt8    <=  cnt8    + 32;
                                cnt9    <=  cnt9    + 32;
                                cnt10   <=  cnt10   + 32;
                                cnt11   <=  cnt11   + 32;
                                cnt12   <=  cnt12   + 32;
                                cnt13   <=  cnt13   + 32;
                                cnt14   <=  cnt14   + 32;
                                cnt15   <=  cnt15   + 32;
                                cnt16   <=  cnt16   + 32;
                                cnt17   <=  cnt17   + 32;
                                cnt18   <=  cnt18   + 32;
                                cnt19   <=  cnt19   + 32;
                                cnt20   <=  cnt20   + 32;
                                cnt21   <=  cnt21   + 32;
                                cnt22   <=  cnt22   + 32;
                                cnt23   <=  cnt23   + 32;
                                cnt24   <=  cnt24   + 32;
                                cnt25   <=  cnt25   + 32;
                                cnt26   <=  cnt26   + 32;
                                cnt27   <=  cnt27   + 32;
                                cnt28   <=  cnt28   + 32;
                                cnt29   <=  cnt29   + 32;
                                cnt30   <=  cnt30   + 32;
                                cnt31   <=  cnt31   + 32;
                            else
                                cnt1    <=  cnt1    ;
                                cnt2    <=  cnt2    ;
                                cnt3    <=  cnt3    ;
                                cnt4    <=  cnt4    ;
                                cnt5    <=  cnt5    ;
                                cnt6    <=  cnt6    ;
                                cnt7    <=  cnt7    ;
                                cnt8    <=  cnt8    ;
                                cnt9    <=  cnt9    ;
                                cnt10   <=  cnt10   ;
                                cnt11   <=  cnt11   ;
                                cnt12   <=  cnt12   ;
                                cnt13   <=  cnt13   ;
                                cnt14   <=  cnt14   ;
                                cnt15   <=  cnt15   ;
                                cnt16   <=  cnt16   ;
                                cnt17   <=  cnt17   ;
                                cnt18   <=  cnt18   ;
                                cnt19   <=  cnt19   ;
                                cnt20   <=  cnt20   ;
                                cnt21   <=  cnt21   ;
                                cnt22   <=  cnt22   ;
                                cnt23   <=  cnt23   ;
                                cnt24   <=  cnt24   ;
                                cnt25   <=  cnt25   ;
                                cnt26   <=  cnt26   ;
                                cnt27   <=  cnt27   ;
                                cnt28   <=  cnt28   ;
                                cnt29   <=  cnt29   ;
                                cnt30   <=  cnt30   ;
                                cnt31   <=  cnt31   ;
                            end if;
                        end if;
                    end if;
                end process;
            end generate;



            FILL_ZEROS_on : if FILL_ZEROS = true generate 

                data_error_reg64_processing : process(ACLK)
                begin
                    if ACLK'event AND ACLK = '1' then 
                        if ARESETN = '0' then 
                            data_error_reg <= (others => '0');
                        else
                            if S_AXIS_TVALID = '1' AND sready_reg = '1' then 
                                if S_AXIS_TDATA /= 0 then 
                                    data_error_reg <= data_error_reg + 1;
                                else
                                    data_error_reg <= data_error_reg;        
                                end if; 
                            else
                                data_error_reg <= data_error_reg;        
                            end if; 

                        end if;
                    end if;
                end process;
            end generate;


        end generate;
    end generate;



    GEN_SIMPLE_COUNTER_ON : if SIMPLE_COUNTER = true generate

        data_error_reg_fill_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    data_error_reg <= (others => '0');
                else
                    if S_AXIS_TVALID = '1' AND sready_reg = '1' then 

                        if (cnt_fill /= S_AXIS_TDATA) then 
                            data_error_reg <= data_error_reg + 1;
                        else
                            data_error_reg <= data_error_reg;        
                        end if; 
                    else
                        data_error_reg <= data_error_reg;        
                    end if; 

                end if;
            end if;
        end process;

        cnt_fill_processing : process(ACLK)
        begin
            if ACLK'event AND ACLK = '1' then 
                if ARESETN = '0' then 
                    cnt_fill <= (others => '0');
                else
                    if S_AXIS_TVALID = '1' and sready_reg = '1' then 
                        cnt_fill <= cnt_fill + 1 ;
                    else
                        cnt_fill <= cnt_fill ;
                    end if;

                end if;
            end if;
        end process;


    end generate;



end axis_checker_arch;
