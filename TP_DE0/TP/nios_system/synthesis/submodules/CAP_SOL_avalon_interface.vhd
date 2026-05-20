library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CAP_SOL_avalon_interface is
    port (
        -- Horloge 50 MHz venant du top-level / Qsys
        clk      : in  std_logic;
        reset_n     : in  std_logic;

        -- Bus Avalon-MM esclave
        avs_address   : in  std_logic_vector(3 downto 0);
        avs_read      : in  std_logic;
        avs_readdata  : out std_logic_vector(31 downto 0);
        avs_write     : in  std_logic;
        avs_writedata : in  std_logic_vector(31 downto 0);

        -- Signaux SPI vers le LTC2308
        ADC_CONVST    : out std_logic;
        ADC_SCK       : out std_logic;
        ADC_SDI       : out std_logic;
        ADC_SDO       : in  std_logic
    );
end CAP_SOL_avalon_interface;

architecture rtl of CAP_SOL_avalon_interface is

    -- -----------------------------------------------------------
    --  PLL
    -- -----------------------------------------------------------
    component pll_2freqs is
        port (
            areset  : in  std_logic;
            inclk0  : in  std_logic;
            c0      : out std_logic;   -- 40 MHz → logique / Avalon
            c1      : out std_logic    -- 2 kHz  → data_capture
        );
    end component;

    -- -----------------------------------------------------------
    --  Composant capteurs
    -- -----------------------------------------------------------
    component capteurs_sol_seuil is
        port (
            clk           : in  std_logic;
            reset_n       : in  std_logic;
            data_capture  : in  std_logic;
            data_readyr   : out std_logic;
            data0r        : out std_logic_vector(7 downto 0);
            data1r        : out std_logic_vector(7 downto 0);
            data2r        : out std_logic_vector(7 downto 0);
            data3r        : out std_logic_vector(7 downto 0);
            data4r        : out std_logic_vector(7 downto 0);
            data5r        : out std_logic_vector(7 downto 0);
            data6r        : out std_logic_vector(7 downto 0);
            NIVEAU        : in  std_logic_vector(7 downto 0);
            vect_capt     : out std_logic_vector(6 downto 0);
            ADC_CONVSTr   : out std_logic;
            ADC_SCK       : out std_logic;
            ADC_SDIr      : out std_logic;
            ADC_SDO       : in  std_logic
        );
    end component;

    -- -----------------------------------------------------------
    --  Signaux internes
    -- -----------------------------------------------------------
    signal clk_40M       : std_logic;
    signal clk_2k        : std_logic;
    signal areset        : std_logic;

    signal reg_control   : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_niveau    : std_logic_vector(7  downto 0) := (others => '0');

    signal sig_data_ready : std_logic;
    signal sig_data0      : std_logic_vector(7 downto 0);
    signal sig_data1      : std_logic_vector(7 downto 0);
    signal sig_data2      : std_logic_vector(7 downto 0);
    signal sig_data3      : std_logic_vector(7 downto 0);
    signal sig_data4      : std_logic_vector(7 downto 0);
    signal sig_data5      : std_logic_vector(7 downto 0);
    signal sig_data6      : std_logic_vector(7 downto 0);
    signal sig_vect_capt  : std_logic_vector(6 downto 0);

begin

    areset <= not reset_n;

    -- -----------------------------------------------------------
    --  Instanciation PLL
    -- -----------------------------------------------------------
    u_pll : pll_2freqs
        port map (
            areset => areset,
            inclk0 => clk,
            c0     => clk_40M,
            c1     => clk_2k
        );

    -- -----------------------------------------------------------
    --  Instanciation capteurs_sol_seuil
    -- -----------------------------------------------------------
    u_capteurs : capteurs_sol_seuil
        port map (
            clk           => clk_40M,
            reset_n       => reset_n,
            data_capture  => clk_2k,
            data_readyr   => sig_data_ready,
            data0r        => sig_data0,
            data1r        => sig_data1,
            data2r        => sig_data2,
            data3r        => sig_data3,
            data4r        => sig_data4,
            data5r        => sig_data5,
            data6r        => sig_data6,
            NIVEAU        => reg_niveau,
            vect_capt     => sig_vect_capt,
            ADC_CONVSTr   => ADC_CONVST,
            ADC_SCK       => ADC_SCK,
            ADC_SDIr      => ADC_SDI,
            ADC_SDO       => ADC_SDO
        );

    -- -----------------------------------------------------------
    --  Écriture Avalon
    -- -----------------------------------------------------------
    p_write : process (clk_40M, reset_n)
    begin
        if reset_n = '0' then
            reg_control <= (others => '0');
            reg_niveau  <= (others => '0');
        elsif rising_edge(clk_40M) then
            if avs_write = '1' then
                case avs_address is
                    when "0000" =>
                        reg_control <= avs_writedata;
                    when "1001" =>
                        reg_niveau  <= avs_writedata(7 downto 0);
                    when others => null;
                end case;
            end if;
        end if;
    end process p_write;

    -- -----------------------------------------------------------
    --  Lecture Avalon
    -- -----------------------------------------------------------
    p_read : process (clk_40M)
    begin
        if rising_edge(clk_40M) then
            avs_readdata <= (others => '0');
            if avs_read = '1' then
                case avs_address is
                    when "0000" =>
                        avs_readdata <= reg_control;
                    when "0001" =>
                        avs_readdata(0)          <= sig_data_ready;
                        avs_readdata(7 downto 1) <= sig_vect_capt;
                    when "0010" =>
                        avs_readdata(7 downto 0) <= sig_data0;
                    when "0011" =>
                        avs_readdata(7 downto 0) <= sig_data1;
                    when "0100" =>
                        avs_readdata(7 downto 0) <= sig_data2;
                    when "0101" =>
                        avs_readdata(7 downto 0) <= sig_data3;
                    when "0110" =>
                        avs_readdata(7 downto 0) <= sig_data4;
                    when "0111" =>
                        avs_readdata(7 downto 0) <= sig_data5;
                    when "1000" =>
                        avs_readdata(7 downto 0) <= sig_data6;
                    when "1001" =>
                        avs_readdata(7 downto 0) <= reg_niveau;
                    when others => null;
                end case;
            end if;
        end if;
    end process p_read;

end rtl;