library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

library UNISIM;
    use UNISIM.VComponents.all;

entity tb_axis_ddr_ctrlr is
end tb_axis_ddr_ctrlr;



architecture Behavioral of tb_axis_ddr_ctrlr is

    constant  DATA_WIDTH        :           integer := 128                                      ;
    constant  ADDR_WIDTH        :           integer := 16                                       ;
    constant  BURST_LIMIT       :           integer := 256                                      ;


    component axis_ddr_mgr_fd
        generic(
            DATA_WIDTH          :           integer := 32                                       ; -- 
            ADDR_WIDTH          :           integer := 32                                       ;
            BURST_LIMIT         :           integer := 16                                        
        );
        port(
            CLK                 :   in      std_logic                                           ;
            RESET               :   in      std_logic                                           ;

            CMD_START_ADDRESS   :   in      std_logic_vector ( ADDR_WIDTH-1 downto 0 )          ;
            CMD_SIZE            :   in      std_logic_Vector ( 31 downto 0 )                    ;
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
    end component;

    signal  CLK                 :           std_logic                                      := '0'                   ;
    signal  RESET               :           std_logic                                      := '0'                   ;
    signal  CMD_START_ADDRESS   :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )     := (others => '0')       ;
    signal  CMD_SIZE            :           std_logic_Vector ( 31 downto 0 )               := (others => '0')       ;
    signal  CMD_MODE            :           std_logic_vector (  1 downto 0 )               := (others => '0')       ;
    signal  CMD_VALID           :           std_logic                                      := '0'                   ;
    signal  S_AXIS_TDATA        :           std_logic_vector ( DATA_WIDTH-1 downto 0 )     := (others => '0')       ;
    signal  S_AXIS_TVALID       :           std_logic                                      := '0'                   ;
    signal  S_AXIS_TLAST        :           std_Logic                                      := '0'                   ;
    signal  S_AXIS_TREADY       :           std_logic                                                               ;
    signal  M_AXIS_TDATA        :           std_logic_Vector ( DATA_WIDTH-1 downto 0 )                              ;
    signal  M_AXIS_TVALID       :           std_logic                                                               ;
    signal  M_AXIS_TLAST        :           std_logic                                                               ;
    signal  M_AXIS_TREADY       :           std_logic                                      := '0'                   ;
    signal  M_AXI_AWADDR        :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )                              ;
    signal  M_AXI_AWLEN         :           std_logic_vector (  7 downto 0 )                                        ;
    signal  M_AXI_AWSIZE        :           std_logic_vector (  2 downto 0 )                                        ; -- Константа 
    signal  M_AXI_AWBURST       :           std_logic_vector (  1 downto 0 )                                        ; 
    signal  M_AXI_AWLOCK        :           std_logic                                                               ; -- Константа 
    signal  M_AXI_AWCACHE       :           std_logic_vector (  3 downto 0 )                                        ; -- Константа 
    signal  M_AXI_AWPROT        :           std_logic_vector (  2 downto 0 )                                        ; -- Константа 
    signal  M_AXI_AWVALID       :           std_logic                                                               ;
    signal  M_AXI_AWREADY       :           std_logic                                      := '0'                   ;
    signal  M_AXI_WDATA         :           std_logic_vector ( DATA_WIDTH-1 downto 0 )                              ;
    signal  M_AXI_WSTRB         :           std_logic_vector ( (DATA_WIDTH/8)-1 downto 0 )                          ; -- Константа 
    signal  M_AXI_WLAST         :           std_logic                                                               ;
    signal  M_AXI_WVALID        :           std_logic                                                               ;
    signal  M_AXI_WREADY        :           std_logic                                      := '0'                   ;
    signal  M_AXI_BRESP         :           std_logic_vector (  1 downto 0 )               := (others => '0')       ;
    signal  M_AXI_BVALID        :           std_logic                                      := '0'                   ;
    signal  M_AXI_BREADY        :           std_logic                                                               ;
    signal  M_AXI_ARADDR        :           std_logic_vector ( ADDR_WIDTH-1 downto 0 )                              ;
    signal  M_AXI_ARLEN         :           std_logic_vector (  7 downto 0 )                                        ; 
    signal  M_AXI_ARSIZE        :           std_logic_vector (  2 downto 0 )                                        ; -- Константа 
    signal  M_AXI_ARBURST       :           std_logic_vector (  1 downto 0 )                                        ; 
    signal  M_AXI_ARLOCK        :           std_logic                                                               ; -- Константа 
    signal  M_AXI_ARCACHE       :           std_logic_vector (  3 downto 0 )                                        ; -- Константа 
    signal  M_AXI_ARPROT        :           std_logic_vector (  2 downto 0 )                                        ; -- Константа 
    signal  M_AXI_ARVALID       :           std_logic                                                               ;
    signal  M_AXI_ARREADY       :           std_logic                                      := '0'                   ;
    signal  M_AXI_RDATA         :           std_logic_vector ( DATA_WIDTH-1 downto 0 )     := (others => '0')       ;
    signal  M_AXI_RRESP         :           std_logic_vector (  1 downto 0 )               := (others => '0')       ;
    signal  M_AXI_RLAST         :           std_logic                                      := '0'                   ;
    signal  M_AXI_RVALID        :           std_logic                                      := '0'                   ;
    signal  M_AXI_RREADY        :           std_logic                                                               ;

    constant CLK_PERIOD : time := 10 ns;
    signal i : integer := 0;
    signal i_slow : integer := 0;
 
    component axi_bram_ctrl_0
        port (
            s_axi_aclk          :   in          std_logic                                                           ;
            s_axi_aresetn       :   in          std_logic                                                           ;
            s_axi_awaddr        :   in          std_logic_vector ( 15 downto 0 )                                    ;
            s_axi_awlen         :   in          std_logic_vector (  7 downto 0 )                                    ;
            s_axi_awsize        :   in          std_logic_vector (  2 downto 0 )                                    ;
            s_axi_awburst       :   in          std_logic_vector (  1 downto 0 )                                    ;
            s_axi_awlock        :   in          std_logic                                                           ;
            s_axi_awcache       :   in          std_logic_vector (  3 downto 0 )                                    ;
            s_axi_awprot        :   in          std_logic_vector (  2 downto 0 )                                    ;
            s_axi_awvalid       :   in          std_logic                                                           ;
            s_axi_awready       :   out         std_logic                                                           ;
            s_axi_wdata         :   in          std_logic_vector (127 downto 0 )                                    ;
            s_axi_wstrb         :   in          std_logic_vector ( 15 downto 0 )                                    ;
            s_axi_wlast         :   in          std_logic                                                           ;
            s_axi_wvalid        :   in          std_logic                                                           ;
            s_axi_wready        :   out         std_logic                                                           ;
            s_axi_bresp         :   out         std_logic_vector (  1 downto 0 )                                    ;
            s_axi_bvalid        :   out         std_logic                                                           ;
            s_axi_bready        :   in          std_logic                                                           ;
            s_axi_araddr        :   in          std_logic_vector ( 15 downto 0 )                                    ;
            s_axi_arlen         :   in          std_logic_vector (  7 downto 0 )                                    ;
            s_axi_arsize        :   in          std_logic_vector (  2 downto 0 )                                    ;
            s_axi_arburst       :   in          std_logic_vector (  1 downto 0 )                                    ;
            s_axi_arlock        :   in          std_logic                                                           ;
            s_axi_arcache       :   in          std_logic_vector (  3 downto 0 )                                    ;
            s_axi_arprot        :   in          std_logic_vector (  2 downto 0 )                                    ;
            s_axi_arvalid       :   in          std_logic                                                           ;
            s_axi_arready       :   out         std_logic                                                           ;
            s_axi_rdata         :   out         std_logic_vector (127 downto 0 )                                    ;
            s_axi_rresp         :   out         std_logic_vector (  1 downto 0 )                                    ;
            s_axi_rlast         :   out         std_logic                                                           ;
            s_axi_rvalid        :   out         std_logic                                                           ;
            s_axi_rready        :   in          std_logic                                                           
        );
    end component;

    component axis_dump_gen
        generic (
            N_BYTES                 :           integer                         := 2                ;
            ASYNC                   :           boolean                         := false            ;
            MODE                    :           string                          := "SINGLE"          -- "SINGLE", "ZEROS", "BYTE"
        );
        port(
            CLK                     :   in      std_logic                                           ;
            RESET                   :   in      std_logic                                           ;
            
            ENABLE                  :   in      std_logic                                           ;
            PAUSE                   :   in      std_logic_Vector ( 31 downto 0 )                    ;
            WORD_LIMIT              :   in      std_logic_Vector ( 31 downto 0 )                    ;
            
            M_AXIS_CLK              :   in      std_logic                                           ;
            M_AXIS_TDATA            :   out     std_logic_Vector ( (N_BYTES*8)-1 downto 0 )         ;
            M_AXIS_TKEEP            :   out     std_logic_Vector ( N_BYTES-1 downto 0 )             ;
            M_AXIS_TVALID           :   out     std_logic                                           ;
            M_AXIS_TREADY           :   in      std_logic                                           ;
            M_AXIS_TLAST            :   out     std_logic                                            
        );
    end component;

    signal  ENABLE                  :           std_logic                               := '0'                  ;
    signal  PAUSE                   :           std_logic_Vector ( 31 downto 0 )        := (others => '0')      ;
    signal  WORD_LIMIT              :           std_logic_Vector ( 31 downto 0 )        := (others => '0')      ;

    constant clk_slow_period : time := 200 ns;

    signal  slow_clk : std_logic := '0';

    signal  i_rdy : integer := 0;

    signal  data_cnt : integer := 0;

begin

    CLK <= not CLK after CLK_PERIOD/2;

    slow_clk <= not slow_clk after clk_slow_period/2;

    i_processing : process(CLK)
    begin
        if CLK'event aND CLK = '1' then 
            i <= i + 1;
        end if;
    end process;

    i_slow_processing : process(slow_clk)
    begin
        if slow_clk'event AND slow_clk = '1' then 
            i_slow <= i_slow + 1;
        end if;
    end process;

    RESET_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i < 10 then 
                RESET <= '1';
            else
                RESET <= '0';
            end if;
        end if;
    end process;

    ENABLE_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is
                when 1100   => ENABLE <= '1'; PAUSE <= x"00000000"; WORD_LIMIT <= x"00001000";
                when others => ENABLE <= ENABLE; PAUSE <= PAUSE; WORD_LIMIT <= WORD_LIMIT; 
            end case;
        end if;
    end process;

    CMD_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            case i is 
                --when 1000   => CMD_START_ADDRESS <= x"0000"; CMD_SIZE <= x"0000000000008000"; CMD_MODE <= "10"; CMD_VALID <= '1';
                when 2000 => CMD_START_ADDRESS <= x"0000"; CMD_SIZE <= x"00002000"; CMD_MODE <= "01"; CMD_VALID <= '1';
                when 20001 => CMD_START_ADDRESS <= x"0000"; CMD_SIZE <= x"00002000"; CMD_MODE <= "01"; CMD_VALID <= '1';
                when 40002 => CMD_START_ADDRESS <= x"0000"; CMD_SIZE <= x"00002000"; CMD_MODE <= "01"; CMD_VALID <= '1';
                when 60003 => CMD_START_ADDRESS <= x"0000"; CMD_SIZE <= x"00002000"; CMD_MODE <= "01"; CMD_VALID <= '1';
                when others => CMD_START_ADDRESS <= CMD_START_ADDRESS; CMD_SIZE <= CMD_SIZE; CMD_MODE <= CMD_MODE; CMD_VALID <= '0';
            end case;
        end if;
    end process;

    axis_dump_gen_inst : axis_dump_gen
        generic map (
            N_BYTES                 =>  16                  ,
            ASYNC                   =>  false               ,
            MODE                    =>  "SINGLE"            -- "SINGLE", "ZEROS", "BYTE"
        )
        port map (
            CLK                     =>  CLK                                                         ,
            RESET                   =>  RESET                                                       ,
            
            ENABLE                  =>  ENABLE                                                      ,
            PAUSE                   =>  PAUSE                                                       ,
            WORD_LIMIT              =>  WORD_LIMIT                                                  ,
            
            M_AXIS_CLK              =>  CLK                                                         ,
            M_AXIS_TDATA            =>  S_AXIS_TDATA                                                ,
            M_AXIS_TKEEP            =>  open                                                        ,
            M_AXIS_TVALID           =>  S_AXIS_TVALID                                               ,
            M_AXIS_TLAST            =>  S_AXIS_TLAST                                                ,
            M_AXIS_TREADY           =>  S_AXIS_TREADY                                                
        );


    axis_ddr_mgr_fd_inst : axis_ddr_mgr_fd
        generic map (
            DATA_WIDTH          =>  DATA_WIDTH          ,
            ADDR_WIDTH          =>  ADDR_WIDTH          ,
            BURST_LIMIT         =>  BURST_LIMIT          
        )
        port map (
            CLK                 =>  CLK                 ,
            RESET               =>  RESET               ,

            CMD_START_ADDRESS   =>  CMD_START_ADDRESS   ,
            CMD_SIZE            =>  CMD_SIZE            ,
            CMD_MODE            =>  CMD_MODE            ,
            CMD_VALID           =>  CMD_VALID           ,
            
            S_AXIS_TDATA        =>  S_AXIS_TDATA        ,
            S_AXIS_TVALID       =>  S_AXIS_TVALID       ,
            S_AXIS_TLAST        =>  S_AXIS_TLAST        ,
            S_AXIS_TREADY       =>  S_AXIS_TREADY       ,
            
            M_AXIS_TDATA        =>  M_AXIS_TDATA        ,
            M_AXIS_TVALID       =>  M_AXIS_TVALID       ,
            M_AXIS_TLAST        =>  M_AXIS_TLAST        ,
            M_AXIS_TREADY       =>  M_AXIS_TREADY       ,

            M_AXI_AWADDR        =>  M_AXI_AWADDR        ,
            M_AXI_AWLEN         =>  M_AXI_AWLEN         ,
            M_AXI_AWSIZE        =>  M_AXI_AWSIZE        ,
            M_AXI_AWBURST       =>  M_AXI_AWBURST       ,
            M_AXI_AWLOCK        =>  M_AXI_AWLOCK        ,
            M_AXI_AWCACHE       =>  M_AXI_AWCACHE       ,
            M_AXI_AWPROT        =>  M_AXI_AWPROT        ,
            M_AXI_AWVALID       =>  M_AXI_AWVALID       ,
            M_AXI_AWREADY       =>  M_AXI_AWREADY       ,

            M_AXI_WDATA         =>  M_AXI_WDATA         ,
            M_AXI_WSTRB         =>  M_AXI_WSTRB         ,
            M_AXI_WLAST         =>  M_AXI_WLAST         ,
            M_AXI_WVALID        =>  M_AXI_WVALID        ,
            M_AXI_WREADY        =>  M_AXI_WREADY        ,

            M_AXI_BRESP         =>  M_AXI_BRESP         ,
            M_AXI_BVALID        =>  M_AXI_BVALID        ,
            M_AXI_BREADY        =>  M_AXI_BREADY        ,

            M_AXI_ARADDR        =>  M_AXI_ARADDR        ,
            M_AXI_ARLEN         =>  M_AXI_ARLEN         ,
            M_AXI_ARSIZE        =>  M_AXI_ARSIZE        ,
            M_AXI_ARBURST       =>  M_AXI_ARBURST       ,
            M_AXI_ARLOCK        =>  M_AXI_ARLOCK        ,
            M_AXI_ARCACHE       =>  M_AXI_ARCACHE       ,
            M_AXI_ARPROT        =>  M_AXI_ARPROT        ,
            M_AXI_ARVALID       =>  M_AXI_ARVALID       ,
            M_AXI_ARREADY       =>  M_AXI_ARREADY       ,

            M_AXI_RDATA         =>  M_AXI_RDATA         ,
            M_AXI_RRESP         =>  M_AXI_RRESP         ,
            M_AXI_RLAST         =>  M_AXI_RLAST         ,
            M_AXI_RVALID        =>  M_AXI_RVALID        ,
            M_AXI_RREADY        =>  M_AXI_RREADY         
        );



    --M_AXIS_TREADY <= '1';

    data_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if M_AXIS_TVALID = '1' and M_AXIS_TREADY = '1' then 
                data_cnt <= data_cnt + 1;
            end if;
        end if;
    end process;

    i_rdy_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i_rdy < 5 then 
                i_rdy <= i_rdy + 1;
            else
                i_rdy <= 0;
            end if;
        end if;
    end process;

    M_AXIS_TREADY_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if i_rdy = 4 then 
                M_AXIS_TREADY <= '1';
            else
                M_AXIS_TREADY <= '0';
            end if;
        end if;
    end process;

    axi_bram_ctrl_0_inst : axi_bram_ctrl_0
        port map (
            s_axi_aclk          =>  CLK                     ,
            s_axi_aresetn       =>  not(RESET)              ,
            s_axi_awaddr        =>  M_AXI_AWADDR            ,
            s_axi_awlen         =>  M_AXI_AWLEN             ,
            s_axi_awsize        =>  M_AXI_AWSIZE            ,
            s_axi_awburst       =>  M_AXI_AWBURST           ,
            s_axi_awlock        =>  M_AXI_AWLOCK            ,
            s_axi_awcache       =>  M_AXI_AWCACHE           ,
            s_axi_awprot        =>  M_AXI_AWPROT            ,
            s_axi_awvalid       =>  M_AXI_AWVALID           ,
            s_axi_awready       =>  M_AXI_AWREADY           ,
            s_axi_wdata         =>  M_AXI_WDATA             ,
            s_axi_wstrb         =>  M_AXI_WSTRB             ,
            s_axi_wlast         =>  M_AXI_WLAST             ,
            s_axi_wvalid        =>  M_AXI_WVALID            ,
            s_axi_wready        =>  M_AXI_WREADY            ,
            s_axi_bresp         =>  M_AXI_BRESP             ,
            s_axi_bvalid        =>  M_AXI_BVALID            ,
            s_axi_bready        =>  M_AXI_BREADY            ,
            s_axi_araddr        =>  M_AXI_ARADDR            ,
            s_axi_arlen         =>  M_AXI_ARLEN             ,
            s_axi_arsize        =>  M_AXI_ARSIZE            ,
            s_axi_arburst       =>  M_AXI_ARBURST           ,
            s_axi_arlock        =>  M_AXI_ARLOCK            ,
            s_axi_arcache       =>  M_AXI_ARCACHE           ,
            s_axi_arprot        =>  M_AXI_ARPROT            ,
            s_axi_arvalid       =>  M_AXI_ARVALID           ,
            s_axi_arready       =>  M_AXI_ARREADY           ,
            s_axi_rdata         =>  M_AXI_RDATA             ,
            s_axi_rresp         =>  M_AXI_RRESP             ,
            s_axi_rlast         =>  M_AXI_RLAST             ,
            s_axi_rvalid        =>  M_AXI_RVALID            ,
            s_axi_rready        =>  M_AXI_RREADY             
        );



end Behavioral;
