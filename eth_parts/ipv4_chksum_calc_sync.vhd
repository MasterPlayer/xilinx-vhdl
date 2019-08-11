library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


library UNISIM;
    use UNISIM.VComponents.all;


entity ipv4_chksum_calc_sync is
    generic(
        SWAP_BYTES          :           boolean                         := true         
    );
    port(
        CLK                 :   in      std_logic                           ;
        RESET               :   in      std_logic                           ;
        IPV4_CALC_START     :   in      std_logic                           ;
        IPV4_IP_VER_LEN     :   in      std_logic_vector ( 15 downto 0 )    ;
        IPV4_IP_ID          :   in      std_logic_Vector ( 15 downto 0 )    ;
        IPV4_TOTAL_SIZE     :   in      std_logic_vector ( 15 downto 0 )    ;
        IPV4_TTL            :   in      std_logic_vector (  7 downto 0 )    ;
        IPV4_PROTO          :   in      std_logic_vector (  7 downto 0 )    ;
        IPV4_SRC_ADDR       :   in      std_logic_vector ( 31 downto 0 )    ;
        IPV4_DST_ADDR       :   in      std_logic_vector ( 31 downto 0 )    ;
        IPV4_CHKSUM         :   out     std_logic_vector(15 downto 0)   ;
        IPV4_DONE           :   out     std_logic                       

    );
end ipv4_chksum_calc_sync;



architecture ipv4_chksum_calc_sync_arch of ipv4_chksum_calc_sync is

    signal  sum_src         :   std_logic_Vector ( 16 downto 0 ) := (others => '0') ;
    signal  sum_dst         :   std_logic_Vector ( 16 downto 0 ) := (others => '0') ;
    signal  sum_vl_id       :   std_logic_vector ( 16 downto 0 ) := (others => '0') ;
    signal  sum_ts_tp       :   std_logic_Vector ( 16 downto 0 ) := (others => '0') ;
    signal  sum_src_dst     :   std_logic_Vector ( 17 downto 0 ) := (others => '0') ;
    signal  sum_vl_ts       :   std_Logic_Vector ( 17 downto 0 ) := (others => '0') ;
    signal  sum_src_vl      :   std_logic_Vector ( 18 downto 0 ) := (others => '0') ;
    signal  chksum_int      :   std_logic_Vector ( 15 downto 0 ) := (others => '0') ;
    signal  ipv4_done_reg   :   std_logic_Vector (  2 downto 0 ) := (others => '0') ;

begin


    IPV4_DONE <= ipv4_done_reg(2);

    ipv4_done_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            ipv4_done_reg( 2 downto 0 ) <= ipv4_done_reg( 1 downto 0 ) & IPV4_CALC_START;
        end if;
    end process;


    sum_src_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_src <= ('0' & IPV4_SRC_ADDR(7 downto 0 ) & IPV4_SRC_ADDR( 15 downto 8 )) + ('0' & IPV4_SRC_ADDR(23 downto 16) & IPV4_SRC_ADDR(31 downto 24)) ;
        end if;
    end process;



    sum_dst_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_dst <= ('0' & IPV4_DST_ADDR(7 downto 0 ) & IPV4_DST_ADDR( 15 downto 8 )) + ('0' & IPV4_DST_ADDR(23 downto 16) & IPV4_DST_ADDR(31 downto 24)) ;
        end if;
    end process;


    sum_vl_id_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_vl_id <= ('0' & IPV4_IP_VER_LEN) + ('0' & IPV4_IP_ID);
        end if;
    end process;


    sum_ts_tp_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_ts_tp <= ('0' & IPV4_TOTAL_SIZE) + ('0' & IPV4_TTL & IPV4_PROTO);
        end if;
    end process;


    sum_src_dst_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_src_dst <= ('0' & sum_src) + ('0' & sum_dst);
        end if;
    end process;



    sum_vl_ts_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_vl_ts <= ('0' & sum_vl_id) + ('0' & sum_ts_tp);
        end if;
    end process;


    sum_src_vl_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            sum_src_vl <= ('0' & sum_src_dst) + ('0' & sum_vl_ts);
        end if;
    end process;


    chksum_int_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            chksum_int <= sum_src_vl( 15 downto 0 ) + sum_src_vl( 18 downto 16 ) ;
        end if;
    end process;

    SWAP_OFF_GEN : if SWAP_BYTES = false generate
        IPV4_CHKSUM <= not(chksum_int);
    end generate;

    SWAP_ON_GEN : if SWAP_BYTES = true generate
        IPV4_CHKSUM <= not(chksum_int( 7 downto 0) & chksum_int(15 downto 8 ));
    end generate;



end ipv4_chksum_calc_sync_arch;
