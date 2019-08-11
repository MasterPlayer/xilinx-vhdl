library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;

entity axis_icmp_chksum_calc is
    port(
        CLK                 :   in      std_logic                                   ;
        RESET               :   in      std_logic                                   ;
        S_AXIS_TDATA        :   in      std_logic_vector ( 255 downto 0 )           ;
        S_AXIS_TKEEP        :   in      std_logic_Vector (  31 downto 0 )           ;
        S_AXIS_TVALID       :   in      std_logic                                   ;
        S_AXIS_TLAST        :   in      std_logic                                   ;
        S_AXIS_TREADY       :   in      std_logic                                   ;

        ICMP_CHKSUM         :   out     std_logic_vector (  15 downto 0 )           ;
        ICMP_CHKSUM_DONE    :   out     std_logic                                    
    );
end axis_icmp_chksum_calc;



architecture axis_icmp_chksum_calc_arch of axis_icmp_chksum_calc is

    signal  icmp_chksum_int             :           std_logic_vector ( 16 downto 0 )    := (others => '0')      ;    
    
    signal  icmp_chksum_acc             :           std_logic_Vector ( 31 downto 0 )    := (others => '0')      ;

    signal  icmp_chksum_vector          :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  icmp_chksum_out             :           std_logic_Vector ( 15 downto 0 )    := (others => '0')      ;
    signal  icmp_chksum_done_reg        :           std_logic                           := '0'                  ;    

    signal  pdata_st0_0                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_1                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_2                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_3                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_4                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_5                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_6                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;
    signal  pdata_st0_7                 :           std_logic_Vector ( 16 downto 0 )    := (others => '0')      ;

    signal  pdata_st1_0                 :           std_logic_Vector ( 17 downto 0 )    := (others => '0')      ;
    signal  pdata_st1_1                 :           std_logic_Vector ( 17 downto 0 )    := (others => '0')      ;
    signal  pdata_st1_2                 :           std_logic_Vector ( 17 downto 0 )    := (others => '0')      ;
    signal  pdata_st1_3                 :           std_logic_Vector ( 17 downto 0 )    := (others => '0')      ;

    signal  pdata_st2_0                 :           std_logic_Vector ( 18 downto 0 )    := (others => '0')      ;
    signal  pdata_st2_1                 :           std_logic_Vector ( 18 downto 0 )    := (others => '0')      ;
    signal  pdata_st3_0                 :           std_logic_Vector ( 19 downto 0 )    := (others => '0')      ;
    signal  first_flaq                  :           std_logic                           := '0'                  ;

    signal  valid_vector                :           std_logic_vector ( 8 downto 0 )     := (others => '0')      ;
    signal  last_vector                 :           std_logic_Vector ( 8 downto 0 )     := (others => '0')      ;


begin



    ICMP_CHKSUM_DONE <= icmp_chksum_done_reg;



    icmp_chksum_done_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                icmp_chksum_done_reg <= '0';    
            else
                if valid_vector(6) = '1' then 
                    if last_vector(6) = '1' then 
                        icmp_chksum_done_reg <= '1';
                    else
                        icmp_chksum_done_reg <= '0';
                    end if;
                else
                    icmp_chksum_done_reg <= '0';
                end if;
            end if;
        end if;
    end process;



    last_vector_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            last_vector(8 downto 0) <= last_vector( 7 downto 0 ) & S_AXIS_TLAST;
        end if;
    end process;    



    valid_vector_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            valid_vector( 8 downto 0 ) <= valid_vector(7 downto 0) & S_AXIS_TVALID;
        end if;
    end process;



    first_flaq_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                first_flaq <= '0';    
            else
                if S_AXIS_TVALID = '1' and S_AXIS_TREADY = '1' then 
                    if S_AXIS_TLAST = '1' then 
                        first_flaq <= '0';
                    else
                        first_flaq <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;



    pdata_st0_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1'  AND S_AXIS_TREADY = '1' then 
                if first_flaq = '0' then 
                    pdata_st0_0 <= (others => '0');
                else
                    if S_AXIS_TLAST = '1' then 
                        case S_AXIS_TKEEP( 3 downto 0 ) is

                            when "0001" => pdata_st0_0 <= EXT(S_AXIS_TDATA(  7 downto  0 ), 17 );
                            when "0011" => pdata_st0_0 <= EXT(S_AXIS_TDATA( 15 downto  0 ), 17 );
                            when "0111" => pdata_st0_0 <= EXT(S_AXIS_TDATA( 15 downto  0 ), 17 ) + EXT(S_AXIS_TDATA( 23 downto 16 ), 17);
                            when "1111" => pdata_st0_0 <= EXT(S_AXIS_TDATA( 15 downto  0 ), 17 ) + EXT(S_AXIS_TDATA( 31 downto 16 ), 17);
                            when others => pdata_st0_0 <= (others => '0') ;
                        end case;
                    else
                        pdata_st0_0 <= EXT(S_AXIS_TDATA(15 downto 0 ), 17) + EXT(S_AXIS_TDATA(31 downto 16), 17);
                    end if;
                end if;
            else
                pdata_st0_0 <= pdata_st0_0;
            end if;
        end if;
    end process;    


    pdata_st0_1_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if first_flaq = '0' then
                    pdata_st0_1 <= EXT(S_AXIS_TDATA( 63 downto 48 ), 17);
                else
                    if S_AXIS_TLAST = '1' then 
                        case S_AXIS_TKEEP( 7 downto 4 ) is
                            when "0001" => pdata_st0_1 <= EXT(S_AXIS_TDATA( 39 downto 32 ), 17 );
                            when "0011" => pdata_st0_1 <= EXT(S_AXIS_TDATA( 47 downto 32 ), 17 );
                            when "0111" => pdata_st0_1 <= EXT(S_AXIS_TDATA( 47 downto 32 ), 17 ) + EXT(S_AXIS_TDATA( 55 downto 48 ), 17);
                            when "1111" => pdata_st0_1 <= EXT(S_AXIS_TDATA( 47 downto 32 ), 17 ) + EXT(S_AXIS_TDATA( 63 downto 48 ), 17);
                            when others => pdata_st0_1 <= (others => '0') ;
                        end case;
                    else
                        pdata_st0_1 <= EXT(S_AXIS_TDATA(47 downto 32 ), 17) + EXT(S_AXIS_TDATA( 63 downto 48), 17);
                    end if;
                end if;
            else
                pdata_st0_1 <= pdata_st0_1;
            end if; 
        end if;
    end process;    



    pdata_st0_2_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 11 downto 8 ) is
                        when "0001" => pdata_st0_2 <= EXT(S_AXIS_TDATA( 71 downto 64 ), 17 );
                        when "0011" => pdata_st0_2 <= EXT(S_AXIS_TDATA( 79 downto 64 ), 17 );
                        when "0111" => pdata_st0_2 <= EXT(S_AXIS_TDATA( 79 downto 64 ), 17 ) + EXT(S_AXIS_TDATA( 87 downto 80 ), 17);
                        when "1111" => pdata_st0_2 <= EXT(S_AXIS_TDATA( 79 downto 64 ), 17 ) + EXT(S_AXIS_TDATA( 95 downto 80 ), 17);
                        when others => pdata_st0_2 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_2 <= EXT(S_AXIS_TDATA(79 downto 64 ), 17) + EXT(S_AXIS_TDATA( 95 downto 80 ), 17);
                end if;  
            else
                pdata_st0_2 <= pdata_st0_2;
            end if;
        end if;
    end process;    


    pdata_st0_3_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 15 downto 12 ) is
                        when "0001" => pdata_st0_3 <= EXT(S_AXIS_TDATA( 103 downto 96 ), 17 );
                        when "0011" => pdata_st0_3 <= EXT(S_AXIS_TDATA( 111 downto 96 ), 17 );
                        when "0111" => pdata_st0_3 <= EXT(S_AXIS_TDATA( 111 downto 96 ), 17 ) + EXT(S_AXIS_TDATA( 119 downto 112 ), 17);
                        when "1111" => pdata_st0_3 <= EXT(S_AXIS_TDATA( 111 downto 96 ), 17 ) + EXT(S_AXIS_TDATA( 127 downto 112 ), 17);
                        when others => pdata_st0_3 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_3 <= EXT(S_AXIS_TDATA(111 downto 96 ), 17) + EXT(S_AXIS_TDATA( 127 downto 112 ), 17);
                end if;
            else
                pdata_st0_3 <= pdata_st0_3;
            end if; 
        end if;
    end process;    


    pdata_st0_4_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 19 downto 16 ) is
                        when "0001" => pdata_st0_4 <= EXT(S_AXIS_TDATA( 135 downto 128 ), 17 );
                        when "0011" => pdata_st0_4 <= EXT(S_AXIS_TDATA( 143 downto 128 ), 17 );
                        when "0111" => pdata_st0_4 <= EXT(S_AXIS_TDATA( 143 downto 128 ), 17 ) + EXT(S_AXIS_TDATA( 151 downto 144 ), 17);
                        when "1111" => pdata_st0_4 <= EXT(S_AXIS_TDATA( 143 downto 128 ), 17 ) + EXT(S_AXIS_TDATA( 159 downto 144 ), 17);
                        when others => pdata_st0_4 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_4 <= EXT(S_AXIS_TDATA(143 downto 128 ), 17) + EXT(S_AXIS_TDATA( 159 downto 144 ), 17);
                end if;
            else
                pdata_st0_4 <= pdata_st0_4;
            end if;
        end if;
    end process;    


    pdata_st0_5_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 23 downto 20 ) is
                        when "0001" => pdata_st0_5 <= EXT(S_AXIS_TDATA( 167 downto 160 ), 17 );
                        when "0011" => pdata_st0_5 <= EXT(S_AXIS_TDATA( 175 downto 160 ), 17 );
                        when "0111" => pdata_st0_5 <= EXT(S_AXIS_TDATA( 175 downto 160 ), 17) + EXT(S_AXIS_TDATA( 183 downto 176 ), 17);
                        when "1111" => pdata_st0_5 <= EXT(S_AXIS_TDATA( 175 downto 160 ), 17) + EXT(S_AXIS_TDATA( 191 downto 176 ), 17);
                        when others => pdata_st0_5 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_5 <= EXT(S_AXIS_TDATA(175 downto 160 ), 17) + EXT(S_AXIS_TDATA( 191 downto 176 ), 17);
                end if;
            else
                pdata_st0_5 <= pdata_st0_5;
            end if;
        end if;
    end process;    

    pdata_st0_6_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 27 downto 24 ) is
                        when "0001" => pdata_st0_6 <= EXT(S_AXIS_TDATA( 199 downto 192 ), 17 );
                        when "0011" => pdata_st0_6 <= EXT(S_AXIS_TDATA( 207 downto 192 ), 17 );
                        when "0111" => pdata_st0_6 <= EXT(S_AXIS_TDATA( 207 downto 192 ), 17 ) + EXT(S_AXIS_TDATA( 215 downto 208 ), 17);
                        when "1111" => pdata_st0_6 <= EXT(S_AXIS_TDATA( 207 downto 192 ), 17 ) + EXT(S_AXIS_TDATA( 223 downto 208 ), 17);
                        when others => pdata_st0_6 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_6 <= EXT(S_AXIS_TDATA(207 downto 192 ), 17) + EXT(S_AXIS_TDATA( 223 downto 208 ), 17);
                end if;
            else
                pdata_st0_6 <= pdata_st0_6;
            end if;
        end if;
    end process;    

    pdata_st0_7_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            
            if S_AXIS_TVALID = '1' AND S_AXIS_TREADY = '1' then 
                if S_AXIS_TLAST = '1' then 
                    case S_AXIS_TKEEP( 31 downto 28 ) is
                        when "0001" => pdata_st0_7 <= EXT(S_AXIS_TDATA( 231 downto 224 ), 17 );
                        when "0011" => pdata_st0_7 <= EXT(S_AXIS_TDATA( 239 downto 224 ), 17 );
                        when "0111" => pdata_st0_7 <= EXT(S_AXIS_TDATA( 239 downto 224 ), 17) + EXT(S_AXIS_TDATA( 247 downto 240 ), 17);
                        when "1111" => pdata_st0_7 <= EXT(S_AXIS_TDATA( 239 downto 224 ), 17) + EXT(S_AXIS_TDATA( 255 downto 240 ), 17);
                        when others => pdata_st0_7 <= (others => '0') ;
                    end case;
                else
                    pdata_st0_7 <= EXT(S_AXIS_TDATA(239 downto 224 ), 17) + EXT(S_AXIS_TDATA( 255 downto 240 ), 17);
                end if;
            else
                pdata_st0_7 <= pdata_st0_7;
            end if;
        end if;
    end process;    



    pdata_st1_0_processing : process(CLK)
    begin
        if cLK'event AND CLK = '1' then 
            pdata_st1_0 <= EXT(pdata_st0_0, 18) + EXT(pdata_st0_1, 18);
        end if;
    end process;      



    pdata_st1_1_processing : process(CLK)
    begin
        if cLK'event AND CLK = '1' then 
            pdata_st1_1 <= EXT(pdata_st0_2, 18) + EXT(pdata_st0_3, 18); 
        end if;
    end process;      



    pdata_st1_2_processing : process(CLK)
    begin
        if cLK'event AND CLK = '1' then 
            pdata_st1_2 <= EXT(pdata_st0_4, 18) + EXT(pdata_st0_5, 18);
        end if;
    end process;      



    pdata_st1_3_processing : process(CLK)
    begin
        if cLK'event AND CLK = '1' then 
            pdata_st1_3 <= EXT(pdata_st0_6, 18) + EXT(pdata_st0_7, 18);
        end if;
    end process;      



    pdata_st2_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            pdata_st2_0 <= EXT(pdata_st1_0, 19) + EXT(pdata_st1_1, 19);
        end if;
    end process;



    pdata_st2_1_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            pdata_st2_1 <= EXT(pdata_st1_2, 19) + EXT(pdata_st1_3, 19);
        end if;
    end process;



    pdata_st3_0_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            pdata_st3_0 <= EXT(pdata_st2_0, 20) + EXT(pdata_st2_1, 20);
        end if;
    end process;



    icmp_chksum_int_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            icmp_chksum_int <= EXT(pdata_st3_0 (15 downto 0), 17) + EXT(pdata_st3_0 (19 downto 16 ), 17); 
        end if;
    end process;



    icmp_chksum_acc_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case valid_vector( 5 downto 4 ) is 
                when "00"   =>  icmp_chksum_acc <= icmp_chksum_acc;                                 --ovr_icmp_chksum_acc <= ovr_icmp_chksum_acc ;
                when "01"   =>  icmp_chksum_acc <= icmp_chksum_acc + EXT(icmp_chksum_int, 32);      --ovr_icmp_chksum_acc <= ovr_icmp_chksum_acc + EXT(icmp_chksum_int, 33);      
                when "10"   =>  
                    if last_vector(5) = '1' then 
                        icmp_chksum_acc <= (others => '0') ;                                        --ovr_icmp_chksum_acc <= (others => '0') ;                                        
                    else 
                        icmp_chksum_acc  <= icmp_chksum_acc;                                        --ovr_icmp_chksum_acc <= ovr_icmp_chksum_acc;                                        
                    end if;
                when "11"   =>  
                    if last_vector(5) = '1' then 
                        icmp_chksum_acc <= EXT(icmp_chksum_int, 32);                                --ovr_icmp_chksum_acc <= EXT(icmp_chksum_int, 33);                                
                    else
                        icmp_chksum_acc <= icmp_chksum_acc + EXT(icmp_chksum_int, 32);              --ovr_icmp_chksum_acc <= ovr_icmp_chksum_acc + EXT(icmp_chksum_int, 33);              
                    end if;
                when others =>  icmp_chksum_acc <= icmp_chksum_acc;                                 --ovr_icmp_chksum_acc <= ovr_icmp_chksum_acc;                                 
            end case; 
        end if;
    end process;



    icmp_chksum_vector_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            icmp_chksum_vector <= EXT(icmp_chksum_acc( 31 downto 16 ), 17) + EXT(icmp_chksum_acc ( 15 downto 0 ), 17);
        end if;
    end process;



    icmp_chksum_out_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            icmp_chksum_out <= icmp_chksum_vector(15 downto 0 ) + EXT(icmp_chksum_vector(16 downto 16), 16);
        end if;
    end process;    



    ICMP_CHKSUM <= not(icmp_chksum_out);


end axis_icmp_chksum_calc_arch;
