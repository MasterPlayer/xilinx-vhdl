library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


library UNISIM;
    use UNISIM.VComponents.all;


entity tb_arp_table_tdp is
end tb_arp_table_tdp;



architecture tb_arp_table_tdp_arch of tb_arp_table_tdp is

    constant  N_ELEMENTS            :           integer     := 32                           ;
    constant  ADDR_WIDTH            :           integer     := 5                            ;
    constant  ASYNC                 :           boolean     := true                         ;

    component arp_table_tdp
        generic (
            N_ELEMENTS              :           integer     := 32                           ;
            ADDR_WIDTH              :           integer     := 5                            ;
            ASYNC                   :           boolean     := false                         
        );
        port(
            CLKA                    :   in      std_logic                                   ;
            RSTA                    :   in      std_logic                                   ;
            -- PORTA memory - configuration memory(write/read operations)
            CFG_ADDRA_IN            :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )  ;
            CFG_DV_IN               :   in      std_logic                                   ; -- valid cmd
            CFG_CMD_IN              :   in      std_logic                                   ; -- read or write
            CFG_DST_MAC_IN          :   in      std_logic_Vector ( 47 downto 0 )            ;
            CFG_DST_IP_IN           :   in      std_logic_Vector ( 31 downto 0 )            ;
            CFG_DST_PORT_IN         :   in      std_logic_Vector ( 15 downto 0 )            ;
            CFG_SRC_IP_IN           :   in      std_logic_Vector ( 31 downto 0 )            ;
            CFG_SRC_PORT_IN         :   in      std_logic_vector ( 15 downto 0 )            ;
            CFG_DST_MAC_OUT         :   out     std_logic_Vector ( 47 downto 0 )            ;
            CFG_DST_IP_OUT          :   out     std_logic_Vector ( 31 downto 0 )            ;
            CFG_DST_PORT_OUT        :   out     std_logic_Vector ( 15 downto 0 )            ;
            CFG_SRC_IP_OUT          :   out     std_logic_Vector ( 31 downto 0 )            ;
            CFG_SRC_PORT_OUT        :   out     std_logic_vector ( 15 downto 0 )            ;
            CFG_DV_OUT              :   out     std_logic                                   ;
            -- PORTB memory - only reading memory
            CLKB                    :   in      std_logic                                   ;
            RSTB                    :   in      std_logic                                   ;
            ADDRB_IN                :   in      std_logic_Vector ( ADDR_WIDTH-1 downto 0 )  ;
            ADDRB_IN_VALID          :   in      std_logic                                   ;
            DST_MAC_OUT             :   out     std_logic_Vector ( 47 downto 0 )            ;
            DST_IP_OUT              :   out     std_logic_Vector ( 31 downto 0 )            ;
            DST_PORT_OUT            :   out     std_logic_Vector ( 15 downto 0 )            ;
            SRC_IP_OUT              :   out     std_logic_Vector ( 31 downto 0 )            ;
            SRC_PORT_OUT            :   out     std_logic_vector ( 15 downto 0 )            ;
            DVO                     :   out     std_logic                                    
        );
    end component;

    signal  clka                    :           std_logic                                  := '0'                       ;
    signal  rsta                    :           std_logic                                  := '0'                       ;
    -- PORTA memory - configuration memory(write/read operations)
    signal  cfg_addra_in            :           std_logic_vector ( ADDR_WIDTH-1 downto 0 ) := (others => '0')           ;
    signal  cfg_dv_in               :           std_logic                                  := '0'                       ; -- valid cmd
    signal  cfg_cmd_in              :           std_logic                                  := '0'                       ; -- read or write
    signal  cfg_dst_mac_in          :           std_logic_Vector ( 47 downto 0 )           := (others => '0')           ;
    signal  cfg_dst_ip_in           :           std_logic_Vector ( 31 downto 0 )           := (others => '0')           ;
    signal  cfg_dst_port_in         :           std_logic_Vector ( 15 downto 0 )           := (others => '0')           ;
    signal  cfg_src_ip_in           :           std_logic_Vector ( 31 downto 0 )           := (others => '0')           ;
    signal  cfg_src_port_in         :           std_logic_vector ( 15 downto 0 )           := (others => '0')           ;
    signal  cfg_dst_mac_out         :           std_logic_Vector ( 47 downto 0 )                                        ;
    signal  cfg_dst_ip_out          :           std_logic_Vector ( 31 downto 0 )                                        ;
    signal  cfg_dst_port_out        :           std_logic_Vector ( 15 downto 0 )                                        ;
    signal  cfg_src_ip_out          :           std_logic_Vector ( 31 downto 0 )                                        ;
    signal  cfg_src_port_out        :           std_logic_vector ( 15 downto 0 )                                        ;
    signal  cfg_dv_out              :           std_logic                                                               ;
    -- PORTB memory - only reading memory
    signal  clkb                    :           std_logic                                  := '0'                       ;
    signal  rstb                    :           std_logic                                  := '0'                       ;
    signal  addrb_in                :           std_logic_Vector ( ADDR_WIDTH-1 downto 0 ) := (others => '0')           ;
    signal  addrb_in_valid          :           std_logic                                  := '0'                       ;
    signal  dst_mac_out             :           std_logic_Vector ( 47 downto 0 )                                        ;
    signal  dst_ip_out              :           std_logic_Vector ( 31 downto 0 )                                        ;
    signal  dst_port_out            :           std_logic_Vector ( 15 downto 0 )                                        ;
    signal  src_ip_out              :           std_logic_Vector ( 31 downto 0 )                                        ;
    signal  src_port_out            :           std_logic_vector ( 15 downto 0 )                                        ;
    signal  dvo                     :           std_logic                                                               ;


    signal  CLKA_PERIOD              :           time                                        := 10 ns                    ;
    signal  CLKB_PERIOD              :           time                                        := 3200 ps                  ;

    signal  i_clka                  :   integer := 0;
    signal  i_clkb                  :   integer := 0;

begin

    CLKA <= not CLKA after CLKA_PERIOD/2;
    CLKB <= not CLKB after CLKB_PERIOD/2;

    i_clka_processing : process(CLKA)
    begin
        if CLKA'event AND CLKA = '1' then 
            i_clka <= i_clka + 1;
        end if;
    end process;

    i_clkb_processing : process(CLKB)
    begin
        if CLKB'event AND CLKB = '1' then 
            i_clkb <= i_clkb + 1;
        end if;
    end process;

    RSTA_processing : process(CLKA)
    begin
        if CLKA'event AND CLKA = '1' then 
            if i_clka < 10 then 
                RSTA <= '1';
            else
                RSTA <= '0';
            end if;
        end if;
    end process;

    RSTB_processing : process(CLKB)
    begin
        if CLKB'event AND CLKB = '1' then 
            if i_clkb < 10 then 
                RSTB <= '1';
            else
                RSTB <= '0';
            end if;
        end if;
    end process;


    arp_table_tdp_inst : arp_table_tdp
        generic map (
            N_ELEMENTS              =>  N_ELEMENTS                                          ,
            ADDR_WIDTH              =>  ADDR_WIDTH                                          ,
            ASYNC                   =>  ASYNC                                                
        )
        port map (
            CLKA                    =>  CLKA                                                ,
            RSTA                    =>  RSTA                                                ,
            CFG_ADDRA_IN            =>  CFG_ADDRA_IN                                        ,
            CFG_DV_IN               =>  CFG_DV_IN                                           ,
            CFG_CMD_IN              =>  CFG_CMD_IN                                          ,
            CFG_DST_MAC_IN          =>  CFG_DST_MAC_IN                                      ,
            CFG_DST_IP_IN           =>  CFG_DST_IP_IN                                       ,
            CFG_DST_PORT_IN         =>  CFG_DST_PORT_IN                                     ,
            CFG_SRC_IP_IN           =>  CFG_SRC_IP_IN                                       ,
            CFG_SRC_PORT_IN         =>  CFG_SRC_PORT_IN                                     ,
            CFG_DST_MAC_OUT         =>  CFG_DST_MAC_OUT                                     ,
            CFG_DST_IP_OUT          =>  CFG_DST_IP_OUT                                      ,
            CFG_DST_PORT_OUT        =>  CFG_DST_PORT_OUT                                    ,
            CFG_SRC_IP_OUT          =>  CFG_SRC_IP_OUT                                      ,
            CFG_SRC_PORT_OUT        =>  CFG_SRC_PORT_OUT                                    ,
            CFG_DV_OUT              =>  CFG_DV_OUT                                          ,
            CLKB                    =>  CLKB                                                ,
            RSTB                    =>  RSTB                                                ,
            ADDRB_IN                =>  ADDRB_IN                                            ,
            ADDRB_IN_VALID          =>  ADDRB_IN_VALID                                      ,
            DST_MAC_OUT             =>  DST_MAC_OUT                                         ,
            DST_IP_OUT              =>  DST_IP_OUT                                          ,
            DST_PORT_OUT            =>  DST_PORT_OUT                                        ,
            SRC_IP_OUT              =>  SRC_IP_OUT                                          ,
            SRC_PORT_OUT            =>  SRC_PORT_OUT                                        ,
            DVO                     =>  DVO                                                  
        );

    cfg_processing : process(CLKA)
    begin
        if CLKA'event AND CLKA = '1' then 
            case i_clka is 
                when 100 => 
                    CFG_ADDRA_IN    <= "00010";
                    CFG_DV_IN       <= '1';
                    CFG_CMD_IN      <= '1';
                    CFG_DST_MAC_IN  <= x"000a35010203";
                    CFG_DST_IP_IN   <= x"c0a80064";
                    CFG_DST_PORT_IN <= x"1389";
                    CFG_SRC_IP_IN   <= x"c0a80065";
                    CFG_SRC_PORT_IN <= x"1390";
                when others => 
                    CFG_ADDRA_IN    <= (others => '0');
                    CFG_DV_IN       <= '0';
                    CFG_CMD_IN      <= '0';
                    CFG_DST_MAC_IN  <= (others => '0');
                    CFG_DST_IP_IN   <= (others => '0');
                    CFG_DST_PORT_IN <= (others => '0');
                    CFG_SRC_IP_IN   <= (others => '0');
                    CFG_SRC_PORT_IN <= (others => '0');

            end case;
        end if;    
  end process;

    get_processing : process(CLKB)
    begin
        if CLKB'event AND CLKB = '1' then 
            case i_clkb is
                when 1000 => 
                    ADDRB_IN        <= "00010";
                    ADDRB_IN_VALID  <= '1';
                when others => 
                    ADDRB_IN        <= (others => '0');
                    ADDRB_IN_VALID  <= '0';
            end case;
        end if;
    end process;

end tb_arp_table_tdp_arch;
