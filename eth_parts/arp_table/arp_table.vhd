library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


library UNISIM;
    use UNISIM.VComponents.all;


entity arp_table is
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
end arp_table;



architecture arp_table_arch of arp_table is


    constant version : string := "v1.0" ;
    
    constant  DATA_WIDTH : integer := DST_MAC_OUT'length + DST_IP_OUT'length + DST_PORT_OUT'length + SRC_IP_OUT'length + SRC_PORT_OUT'length;
    constant  READ_LATENCY_A : integer := 2                 ;
    constant  READ_LATENCY_B : integer := 2  ;

    component tdpram_xpm
        generic(
            ADDR_WIDTH  :           integer :=   5                                                  ;
            DATA_WIDTH  :           integer := 144                                                  ; 
            ASYNC       :           boolean := false                                                ;
            MEMORY_PRIM :           string  := "block"                                              ;
            READ_LATENCY_A : integer := 2               ;
            READ_LATENCY_B : integer := 2

        );
        port(
            CLKA        :   in      std_logic                                                       ;
            RSTA        :   in      std_logic                                                       ;
            ADDRA       :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )                      ;
            DINA        :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )                      ;
            WEA         :   in      std_logic                                                       ;
            DOUTA       :   out     std_logic_vector ( DATA_WIDTH-1 downto 0 )                      ;
            CLKB        :   in      std_logic                                                       ;
            RSTB        :   in      std_logic                                                       ;
            ADDRB       :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )                      ;
            DINB        :   in      std_logic_Vector ( DATA_WIDTH-1 downto 0 )                      ;
            WEB         :   in      std_logic                                                       ;
            DOUTB       :   out     std_logic_vector ( DATA_WIDTH-1 downto 0 )                      
        );
    end component;

    signal  ADDRA       :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )  := (others => '0')  ;
    signal  DINA        :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )  := (others => '0')  ;
    signal  WEA         :           std_logic                                   := '0'              ;
    signal  DOUTA       :           std_logic_vector ( DATA_WIDTH-1 downto 0 )                      ;
    signal  ADDRB       :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )  := (others => '0')  ;
    signal  DINB        :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )  := (others => '0')  ;
    signal  WEB         :           std_logic                                   := '0'              ;
    signal  DOUTB       :           std_logic_vector ( DATA_WIDTH-1 downto 0 )                      ;

    signal  cfg_dv_out_vector :        std_logic_vector ( READ_LATENCY_A downto 0 )          := (others => '0')  ;
    signal  dvo_reg     :           std_logic_Vector ( READ_LATENCY_B downto 0 ) := (others => '0')    ;

begin

    DINA  <= CFG_SRC_PORT_IN & CFG_SRC_IP_IN & CFG_DST_PORT_IN & CFG_DST_IP_IN & CFG_DST_MAC_IN;
    WEA   <= '1' when  CFG_DV_IN = '1' and CFG_CMD_IN = '1' else '0' ;
    ADDRA <= CFG_ADDRA_IN ;

    CFG_DST_MAC_OUT  <= DOUTA( 47 downto   0) ;
    CFG_DST_IP_OUT   <= DOUTA( 79 downto  48) ;
    CFG_DST_PORT_OUT <= DOUTA( 95 downto  80) ;
    CFG_SRC_IP_OUT   <= DOUTA(127 downto  96) ;  
    CFG_SRC_PORT_OUT <= DOUTA(143 downto 128) ;  
    CFG_DV_OUT       <= cfg_dv_out_vector(READ_LATENCY_A)  ;
    DVO              <= dvo_reg(READ_LATENCY_B);

    cfg_dv_out_vector(0) <= '1' when CFG_DV_IN = '1' and CFG_CMD_IN = '0' else '0' ;

    GEN_IF_RLA : if (READ_LATENCY_A > 0) generate
        cfg_dv_out_reg_processing : process(CLKA)
        begin
            if CLKA'event AND CLKA = '1' then 
                cfg_dv_out_vector(READ_LATENCY_A downto 1) <= cfg_dv_out_vector(READ_LATENCY_A-1 downto 0 );
            end if;
        end process;
    end generate;

    dvo_reg(0) <= '1' when ADDRB_IN_VALID = '1' else '0';

    GEN_IF_RLB : if (READ_LATENCY_B > 0) generate
        dvo_reg_processing : process(CLKB)
        begin
            if CLKB'event AND CLKB = '1' then 
                dvo_reg(READ_LATENCY_B downto 1) <= dvo_reg(READ_LATENCY_B-1 downto 0);
            end if;
        end process;
    end generate;

    tdpram_xpm_inst : tdpram_xpm
        generic map (
            ADDR_WIDTH      =>  ADDR_WIDTH              ,
            DATA_WIDTH      =>  DATA_WIDTH              ,
            ASYNC           =>  ASYNC                   ,
            MEMORY_PRIM     =>  "block"                 ,
            READ_LATENCY_A  =>  READ_LATENCY_A          ,
            READ_LATENCY_B  =>  READ_LATENCY_B          
        )
        port map (
            CLKA            =>  CLKA                    ,
            RSTA            =>  RSTA                    ,
            ADDRA           =>  ADDRA                   ,
            DINA            =>  DINA                    ,
            WEA             =>  WEA                     ,
            DOUTA           =>  DOUTA                   ,
            CLKB            =>  CLKB                    ,
            RSTB            =>  RSTB                    ,
            ADDRB           =>  ADDRB                   ,
            DINB            =>  DINB                    ,
            WEB             =>  WEB                     ,
            DOUTB           =>  DOUTB                    
        );

    ADDRB        <= ADDRB_IN;

    DST_MAC_OUT  <= DOUTB( 47 downto   0) ;
    DST_IP_OUT   <= DOUTB( 79 downto  48) ;
    DST_PORT_OUT <= DOUTB( 95 downto  80) ;
    SRC_IP_OUT   <= DOUTB(127 downto  96) ;
    SRC_PORT_OUT <= DOUTB(143 downto 128) ;


end arp_table_arch;
