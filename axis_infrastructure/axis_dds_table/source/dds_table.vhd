library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

-- Выход частоты синуса вычисляется по формуле:
-- sin_freq = (freq_step * step_param) * fs,
-- где Freq_step = 1/(2^32-1)
-- step_param = параметр STEP
-- Fs - частота CLK в Гц
entity dds_table is
    port(
        CLK     :   in      std_logic                               ;
        RESET   :   in      std_logic                               ; -- Сброс. Можно оставить в 0
        PAUSE   :   in      std_logic_Vector ( 31 downto 0 )        ; -- Пауза в тактах. 0 - нет паузы, ДВО в таком случае всегда в единице
        ENABLE  :   in      std_logic                               ; -- Включить/выключить ддс
        STEP    :   in      std_logic_vector ( 31 downto 0 )        ; -- Шаг приращения фазы
        SIN     :   out     std_logic_vector ( 15 downto 0 )        ;
        COS     :   out     std_logic_vector ( 15 downto 0 )        ; 
        DVO     :   out     std_logic                               ; -- DVO Для SIN/COS
        SDV     :   in      std_logic                                 -- Защелкивает размер Step
    );
end dds_table;


architecture dds_table_arch of dds_table is

    type ROM is array(0 to 1023) of std_logic_vector(15 downto 0);

    signal SinTable: ROM :=(
    
        x"0000",x"00c9",x"0192",x"025b",x"0324",x"03ee",x"04b7",x"0580",x"0649",x"0712",x"07db",x"08a4",x"096c",x"0a35",x"0afe",x"0bc6",
        x"0c8e",x"0d57",x"0e1f",x"0ee7",x"0fae",x"1076",x"113e",x"1205",x"12cc",x"1393",x"145a",x"1520",x"15e7",x"16ad",x"1773",x"1839",
        x"18fe",x"19c3",x"1a88",x"1b4d",x"1c12",x"1cd6",x"1d9a",x"1e5d",x"1f21",x"1fe4",x"20a7",x"2169",x"222b",x"22ed",x"23ae",x"2470",
        x"2530",x"25f1",x"26b1",x"2770",x"2830",x"28ee",x"29ad",x"2a6b",x"2b29",x"2be6",x"2ca3",x"2d5f",x"2e1b",x"2ed7",x"2f92",x"304c",
        x"3107",x"31c0",x"3279",x"3332",x"33ea",x"34a2",x"3559",x"3610",x"36c6",x"377c",x"3831",x"38e5",x"3999",x"3a4d",x"3b00",x"3bb2",
        x"3c64",x"3d15",x"3dc5",x"3e75",x"3f25",x"3fd3",x"4082",x"412f",x"41dc",x"4288",x"4334",x"43df",x"4489",x"4533",x"45dc",x"4684",
        x"472c",x"47d2",x"4879",x"491e",x"49c3",x"4a67",x"4b0b",x"4bad",x"4c4f",x"4cf0",x"4d91",x"4e31",x"4ed0",x"4f6e",x"500b",x"50a8",
        x"5144",x"51df",x"5279",x"5313",x"53ab",x"5443",x"54da",x"5571",x"5606",x"569b",x"572e",x"57c1",x"5853",x"58e5",x"5975",x"5a04",
        x"5a93",x"5b21",x"5bae",x"5c3a",x"5cc5",x"5d4f",x"5dd8",x"5e61",x"5ee8",x"5f6f",x"5ff4",x"6079",x"60fd",x"6180",x"6202",x"6283",
        x"6303",x"6382",x"6400",x"647d",x"64f9",x"6574",x"65ef",x"6668",x"66e0",x"6757",x"67cd",x"6843",x"68b7",x"692a",x"699c",x"6a0e",
        x"6a7e",x"6aed",x"6b5b",x"6bc8",x"6c34",x"6c9f",x"6d09",x"6d72",x"6dda",x"6e40",x"6ea6",x"6f0b",x"6f6e",x"6fd1",x"7032",x"7092",
        x"70f2",x"7150",x"71ad",x"7209",x"7264",x"72bd",x"7316",x"736e",x"73c4",x"7419",x"746d",x"74c0",x"7512",x"7563",x"75b3",x"7601",
        x"764f",x"769b",x"76e6",x"7730",x"7779",x"77c0",x"7807",x"784c",x"7890",x"78d3",x"7915",x"7956",x"7995",x"79d4",x"7a11",x"7a4d",
        x"7a87",x"7ac1",x"7af9",x"7b31",x"7b67",x"7b9b",x"7bcf",x"7c02",x"7c33",x"7c63",x"7c92",x"7cbf",x"7cec",x"7d17",x"7d41",x"7d6a",
        x"7d91",x"7db8",x"7ddd",x"7e01",x"7e24",x"7e45",x"7e66",x"7e85",x"7ea3",x"7ebf",x"7edb",x"7ef5",x"7f0e",x"7f25",x"7f3c",x"7f51",
        x"7f65",x"7f78",x"7f8a",x"7f9a",x"7fa9",x"7fb7",x"7fc4",x"7fcf",x"7fd9",x"7fe2",x"7fea",x"7ff1",x"7ff6",x"7ffa",x"7ffd",x"7ffe",
        x"7ffe",x"7ffe",x"7ffb",x"7ff8",x"7ff3",x"7fed",x"7fe6",x"7fde",x"7fd4",x"7fca",x"7fbe",x"7fb0",x"7fa2",x"7f92",x"7f81",x"7f6f",
        x"7f5b",x"7f47",x"7f31",x"7f1a",x"7f01",x"7ee8",x"7ecd",x"7eb1",x"7e94",x"7e75",x"7e56",x"7e35",x"7e13",x"7def",x"7dcb",x"7da5",
        x"7d7e",x"7d56",x"7d2c",x"7d02",x"7cd6",x"7ca9",x"7c7a",x"7c4b",x"7c1a",x"7be8",x"7bb5",x"7b81",x"7b4c",x"7b15",x"7add",x"7aa4",
        x"7a6a",x"7a2f",x"79f2",x"79b5",x"7976",x"7936",x"78f4",x"78b2",x"786e",x"782a",x"77e4",x"779d",x"7754",x"770b",x"76c1",x"7675",
        x"7628",x"75da",x"758b",x"753b",x"74ea",x"7497",x"7443",x"73ef",x"7399",x"7342",x"72ea",x"7291",x"7236",x"71db",x"717e",x"7121",
        x"70c2",x"7062",x"7002",x"6fa0",x"6f3d",x"6ed9",x"6e73",x"6e0d",x"6da6",x"6d3e",x"6cd4",x"6c6a",x"6bfe",x"6b92",x"6b24",x"6ab5",
        x"6a46",x"69d5",x"6963",x"68f1",x"687d",x"6808",x"6792",x"671c",x"66a4",x"662b",x"65b2",x"6537",x"64bb",x"643f",x"63c1",x"6342",
        x"62c3",x"6242",x"61c1",x"613e",x"60bb",x"6037",x"5fb2",x"5f2c",x"5ea5",x"5e1d",x"5d94",x"5d0a",x"5c7f",x"5bf4",x"5b67",x"5ada",
        x"5a4c",x"59bd",x"592d",x"589c",x"580a",x"5778",x"56e5",x"5650",x"55bb",x"5525",x"548f",x"53f7",x"535f",x"52c6",x"522c",x"5191",
        x"50f6",x"505a",x"4fbd",x"4f1f",x"4e80",x"4de1",x"4d41",x"4ca0",x"4bfe",x"4b5c",x"4ab9",x"4a15",x"4971",x"48cc",x"4826",x"477f",
        x"46d8",x"4630",x"4587",x"44de",x"4434",x"4389",x"42de",x"4232",x"4186",x"40d8",x"402b",x"3f7c",x"3ecd",x"3e1d",x"3d6d",x"3cbc",
        x"3c0b",x"3b59",x"3aa6",x"39f3",x"393f",x"388b",x"37d6",x"3721",x"366b",x"35b5",x"34fe",x"3446",x"338e",x"32d6",x"321d",x"3163",
        x"30a9",x"2fef",x"2f34",x"2e79",x"2dbd",x"2d01",x"2c44",x"2b87",x"2aca",x"2a0c",x"294e",x"288f",x"27d0",x"2711",x"2651",x"2591",
        x"24d0",x"240f",x"234e",x"228c",x"21ca",x"2108",x"2045",x"1f82",x"1ebf",x"1dfc",x"1d38",x"1c74",x"1baf",x"1aeb",x"1a26",x"1961",
        x"189b",x"17d6",x"1710",x"164a",x"1584",x"14bd",x"13f6",x"1330",x"1269",x"11a1",x"10da",x"1012",x"0f4b",x"0e83",x"0dbb",x"0cf2",
        x"0c2a",x"0b62",x"0a99",x"09d1",x"0908",x"083f",x"0776",x"06ad",x"05e4",x"051b",x"0452",x"0389",x"02c0",x"01f7",x"012d",x"0064",
        x"ff9b",x"fed2",x"fe08",x"fd3f",x"fc76",x"fbad",x"fae4",x"fa1b",x"f952",x"f889",x"f7c0",x"f6f7",x"f62e",x"f566",x"f49d",x"f3d5",
        x"f30d",x"f244",x"f17c",x"f0b4",x"efed",x"ef25",x"ee5e",x"ed96",x"eccf",x"ec09",x"eb42",x"ea7b",x"e9b5",x"e8ef",x"e829",x"e764",
        x"e69e",x"e5d9",x"e514",x"e450",x"e38b",x"e2c7",x"e203",x"e140",x"e07d",x"dfba",x"def7",x"de35",x"dd73",x"dcb1",x"dbf0",x"db2f",
        x"da6e",x"d9ae",x"d8ee",x"d82f",x"d770",x"d6b1",x"d5f3",x"d535",x"d478",x"d3bb",x"d2fe",x"d242",x"d186",x"d0cb",x"d010",x"cf56",
        x"ce9c",x"cde2",x"cd29",x"cc71",x"cbb9",x"cb01",x"ca4a",x"c994",x"c8de",x"c829",x"c774",x"c6c0",x"c60c",x"c559",x"c4a6",x"c3f4",
        x"c343",x"c292",x"c1e2",x"c132",x"c083",x"bfd4",x"bf27",x"be79",x"bdcd",x"bd21",x"bc76",x"bbcb",x"bb21",x"ba78",x"b9cf",x"b927",
        x"b880",x"b7d9",x"b733",x"b68e",x"b5ea",x"b546",x"b4a3",x"b401",x"b35f",x"b2be",x"b21e",x"b17f",x"b0e0",x"b042",x"afa5",x"af09",
        x"ae6e",x"add3",x"ad39",x"aca0",x"ac08",x"ab70",x"aada",x"aa44",x"a9af",x"a91a",x"a887",x"a7f5",x"a763",x"a6d2",x"a642",x"a5b3",
        x"a525",x"a498",x"a40b",x"a380",x"a2f5",x"a26b",x"a1e2",x"a15a",x"a0d3",x"a04d",x"9fc8",x"9f44",x"9ec1",x"9e3e",x"9dbd",x"9d3c",
        x"9cbd",x"9c3e",x"9bc0",x"9b44",x"9ac8",x"9a4d",x"99d4",x"995b",x"98e3",x"986d",x"97f7",x"9782",x"970e",x"969c",x"962a",x"95b9",
        x"954a",x"94db",x"946d",x"9401",x"9395",x"932b",x"92c1",x"9259",x"91f2",x"918c",x"9126",x"90c2",x"905f",x"8ffd",x"8f9d",x"8f3d",
        x"8ede",x"8e81",x"8e24",x"8dc9",x"8d6e",x"8d15",x"8cbd",x"8c66",x"8c10",x"8bbc",x"8b68",x"8b15",x"8ac4",x"8a74",x"8a25",x"89d7",
        x"898a",x"893e",x"88f4",x"88ab",x"8862",x"881b",x"87d5",x"8791",x"874d",x"870b",x"86c9",x"8689",x"864a",x"860d",x"85d0",x"8595",
        x"855b",x"8522",x"84ea",x"84b3",x"847e",x"844a",x"8417",x"83e5",x"83b4",x"8385",x"8356",x"8329",x"82fd",x"82d3",x"82a9",x"8281",
        x"825a",x"8234",x"8210",x"81ec",x"81ca",x"81a9",x"818a",x"816b",x"814e",x"8132",x"8117",x"80fe",x"80e5",x"80ce",x"80b8",x"80a4",
        x"8090",x"807e",x"806d",x"805d",x"804f",x"8041",x"8035",x"802b",x"8021",x"8019",x"8012",x"800c",x"8007",x"8004",x"8001",x"8001",
        x"8001",x"8002",x"8005",x"8009",x"800e",x"8015",x"801d",x"8026",x"8030",x"803b",x"8048",x"8056",x"8065",x"8075",x"8087",x"809a",
        x"80ae",x"80c3",x"80da",x"80f1",x"810a",x"8124",x"8140",x"815c",x"817a",x"8199",x"81ba",x"81db",x"81fe",x"8222",x"8247",x"826e",
        x"8295",x"82be",x"82e8",x"8313",x"8340",x"836d",x"839c",x"83cc",x"83fd",x"8430",x"8464",x"8498",x"84ce",x"8506",x"853e",x"8578",
        x"85b2",x"85ee",x"862b",x"866a",x"86a9",x"86ea",x"872c",x"876f",x"87b3",x"87f8",x"883f",x"8886",x"88cf",x"8919",x"8964",x"89b0",
        x"89fe",x"8a4c",x"8a9c",x"8aed",x"8b3f",x"8b92",x"8be6",x"8c3b",x"8c91",x"8ce9",x"8d42",x"8d9b",x"8df6",x"8e52",x"8eaf",x"8f0d",
        x"8f6d",x"8fcd",x"902e",x"9091",x"90f4",x"9159",x"91bf",x"9225",x"928d",x"92f6",x"9360",x"93cb",x"9437",x"94a4",x"9512",x"9581",
        x"95f1",x"9663",x"96d5",x"9748",x"97bc",x"9832",x"98a8",x"991f",x"9997",x"9a10",x"9a8b",x"9b06",x"9b82",x"9bff",x"9c7d",x"9cfc",
        x"9d7c",x"9dfd",x"9e7f",x"9f02",x"9f86",x"a00b",x"a090",x"a117",x"a19e",x"a227",x"a2b0",x"a33a",x"a3c5",x"a451",x"a4de",x"a56c",
        x"a5fb",x"a68a",x"a71a",x"a7ac",x"a83e",x"a8d1",x"a964",x"a9f9",x"aa8e",x"ab25",x"abbc",x"ac54",x"acec",x"ad86",x"ae20",x"aebb",
        x"af57",x"aff4",x"b091",x"b12f",x"b1ce",x"b26e",x"b30f",x"b3b0",x"b452",x"b4f4",x"b598",x"b63c",x"b6e1",x"b786",x"b82d",x"b8d3",
        x"b97b",x"ba23",x"bacc",x"bb76",x"bc20",x"bccb",x"bd77",x"be23",x"bed0",x"bf7d",x"c02c",x"c0da",x"c18a",x"c23a",x"c2ea",x"c39b",
        x"c44d",x"c4ff",x"c5b2",x"c666",x"c71a",x"c7ce",x"c883",x"c939",x"c9ef",x"caa6",x"cb5d",x"cc15",x"cccd",x"cd86",x"ce3f",x"cef8",
        x"cfb3",x"d06d",x"d128",x"d1e4",x"d2a0",x"d35c",x"d419",x"d4d6",x"d594",x"d652",x"d711",x"d7cf",x"d88f",x"d94e",x"da0e",x"dacf",
        x"db8f",x"dc51",x"dd12",x"ddd4",x"de96",x"df58",x"e01b",x"e0de",x"e1a2",x"e265",x"e329",x"e3ed",x"e4b2",x"e577",x"e63c",x"e701",
        x"e7c6",x"e88c",x"e952",x"ea18",x"eadf",x"eba5",x"ec6c",x"ed33",x"edfa",x"eec1",x"ef89",x"f051",x"f118",x"f1e0",x"f2a8",x"f371",
        x"f439",x"f501",x"f5ca",x"f693",x"f75b",x"f824",x"f8ed",x"f9b6",x"fa7f",x"fb48",x"fc11",x"fcdb",x"fda4",x"fe6d",x"ff36",x"ffff"
    
    );

    signal  EIC         :   integer range 0 to 1023 := 0;
    signal  EIC_COS     :   integer range 0 to 1023 := 255;
    signal  acc2        :   std_logic_vector(31 downto 0) := x"3FC00000";
    signal  acc         :   std_logic_vector(31 downto 0) := (others => '0');
    signal  rstep       :   std_logic_vector(31 downto 0) := (others => '0');

    signal  pause_cnt   :       std_logic_vector ( 31 downto 0 ) := (others => '0');

    signal  dvo_reg     :       std_logic                           := '0';

begin

    DVO <= dvo_reg;

    pause_cnt_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                pause_cnt <= (others => '0');
            else
                if ENABLE = '1' then 
                    if pause_cnt = PAUSE then 
                        pause_cnt <= (others => '0');
                    else
                        if pause_cnt < PAUSE then 
                            pause_cnt <= pause_cnt + 1;
                        else
                            pause_cnt <= (others => '0');    
                        end if;
                    end if;
                else
                    pause_cnt <= (others => '0');    
                end if;
            end if;
        end if;
    end process;

    dvo_reg_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                dvo_reg <= '0';
            else
                if ENABLE = '1' then 
                    if pause_cnt = PAUSE then 
                        dvo_reg <= '1';
                    else
                        dvo_reg <= '0';
                    end if;
                else
                    dvo_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    acc_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                Acc <= (others => '0');
            else
            
                if ENABLE = '1' then 
                    if pause_cnt = PAUSE then 
                        acc <= acc + rStep;
                    else
                        acc <= acc;
                    end if;
                else
                    acc <= acc;
                end if;
            end if;
        end if;
    end process;

    acc2_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if RESET = '1' then 
                acc2 <= x"3FC00000";
            else
                
                if ENABLE = '1' then 
                    if pause_cnt = PAUSE then 
                        acc2 <= acc2 + rStep;
                    else
                        acc2 <= acc2;
                    end if;
                else
                    acc2 <= acc2;
                end if;

            end if;
        end if;
    end process;

    rstep_processing : process(CLK)
    begin
        if CLK'event AND CLK = '1' then 
            if SDV = '1' then 
                rStep <= STEP;
            else
                rStep <= rStep;
            end if;
        end if;
    end process;


    EIC <= conv_integer(unsigned(Acc(31 downto 22)));
    EIC_COS <= conv_integer(unsigned(Acc2(31 downto 22)));
    
    SIN <= SinTable(EIC);
    COS <= SinTable(EIC_COS);
    
end dds_table_arch;

