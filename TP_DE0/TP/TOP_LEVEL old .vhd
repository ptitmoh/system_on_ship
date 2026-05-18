 LIBRARY ieee;
 USE ieee.std_logic_1164.ALL;
 USE ieee.numeric_std.ALL;
 
 ENTITY TOP_LEVEL IS
	PORT (
		 CLOCK_50  : IN STD_LOGIC;
		 KEY       : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		 LED       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

		 DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
		 DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 DRAM_BA   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 DRAM_CS_N : OUT STD_LOGIC;
		 DRAM_CAS_N: OUT STD_LOGIC;
		 DRAM_RAS_N: OUT STD_LOGIC;
		 DRAM_WE_N : OUT STD_LOGIC;
		 DRAM_DQ   : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DRAM_DQM  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 
		 MTRL_N    : out std_logic;
		 MTRL_P    : out std_logic;
		 MTRR_N    : out std_logic;
		 MTRR_P    : out std_logic;
		 MTR_Fault_n 		: in std_logic;
		 MTR_Sleep_n 		: out std_logic;
		 
		 LTC_ADC_CONVST	    : out std_logic;
		 LTC_ADC_SCK	    : out std_logic;
		 LTC_ADC_SDI	    : out std_logic;
		 LTC_ADC_SDO	    : in  std_logic  ;
		 
		 VCC3P3_PWRON_n 	: out std_logic	 
	);
 END TOP_LEVEL;

 ARCHITECTURE T_arch_rtl OF TOP_LEVEL IS
 
 signal sig_posLigne : std_logic_vector(3 DOWNTO 0);
 signal clk_40MHZ, clk_2KHZ   : std_logic;   
 signal sig_data_capteur_brut : std_logic_vector(55 DOWNTO 0);
 signal data_capteur_seuille, sig_led  : std_logic_vector(6 DOWNTO 0);
 signal sig_pio_input, sig_pio_output  : std_logic_vector(7 DOWNTO 0);
 signal sig_consigne_moteur    : std_logic_vector(27 DOWNTO 0);
 signal sig_consigne_moteur_SL : std_logic_vector(27 DOWNTO 0);
 signal sig_consigne_moteur_GR : std_logic_vector(27 DOWNTO 0);
 signal sig_VIRAGE : std_logic_vector(1 DOWNTO 0);
 
 constant seuil_capteur : natural :=  50; --110;
 
	component nios_system is
        port (
					clk_clk           : in    std_logic                     := 'X';             
					reset_reset_n     : in    std_logic                     := 'X';            
					pio_input_export  : in    std_logic_vector(7 downto 0)  := (others => 'X'); 
					pio_output_export : out   std_logic_vector(7 downto 0);                    
					sdram_wire_addr   : out   std_logic_vector(12 downto 0);                    
					sdram_wire_ba     : out   std_logic_vector(1 downto 0);                    
					sdram_wire_cas_n  : out   std_logic;                                        
					sdram_wire_cke    : out   std_logic;                                        
					sdram_wire_cs_n   : out   std_logic;                                        
					sdram_wire_dq     : inout std_logic_vector(15 downto 0) := (others => 'X'); 
					sdram_wire_dqm    : out   std_logic_vector(1 downto 0);                     
					sdram_wire_ras_n  : out   std_logic;                                        
					sdram_wire_we_n   : out   std_logic;                                       
					sdram_clk_clk     : out   std_logic                                       
				);
    end component nios_system;
	 
	component PWM_generation is
			port(
				clk              : in std_logic;
				reset_n          : in std_logic;
				s_writedataR     : in std_logic_vector(13 downto 0);  
				s_writedataL     : in std_logic_vector(13 downto 0);	
				dc_motor_p_R     : out std_logic;
				dc_motor_n_R     : out std_logic;
				dc_motor_p_L     : out std_logic;
				dc_motor_n_L     : out std_logic
		);
	end component PWM_generation;
	
	component pll_2freqs IS
			PORT
			(
				areset		: IN STD_LOGIC  := '0';
				inclk0		: IN STD_LOGIC  := '0';
				c0		      : OUT STD_LOGIC ;
				c1		      : OUT STD_LOGIC 
			);
	END component pll_2freqs;
		
	component capteurs_sol_seuil is
			port 
			(
				clk	       : in  std_logic;	
				reset_n	    : in  std_logic;
				data_capture : in  std_logic;	
				data_readyr	 : out std_logic;
				data0r	  : out std_logic_vector(7 downto 0);
				data1r	  : out std_logic_vector(7 downto 0);
				data2r	  : out std_logic_vector(7 downto 0);
				data3r	  : out std_logic_vector(7 downto 0);
				data4r	  : out std_logic_vector(7 downto 0);
				data5r	  : out std_logic_vector(7 downto 0);
				data6r	  : out std_logic_vector(7 downto 0);
			--	data7r	: out std_logic_vector(7 downto 0);
			-- entree/sortie signaux seuilles
			    NIVEAU      : in std_logic_vector(7 downto 0);
				vect_capt   : out std_logic_vector(6 downto 0);
			-- spi 
				ADC_CONVSTr	: out std_logic;
				ADC_SCK	    : out std_logic;
				ADC_SDIr	: out std_logic;
				ADC_SDO	    : in  std_logic 

			);
	end component capteurs_sol_seuil;
	
	component position_ligne IS
			PORT 
			(
					data_capteur  : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
					pos_ligne     : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
					data_ready    : IN STD_LOGIC;
					led           : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
					VIRAGE        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
			);
	END component position_ligne;
	
	component Automate_suiveur_de_ligne IS
			 PORT (
				  posLigne : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
				  Start_SL : IN  STD_LOGIC;
				  clk, rst : IN STD_LOGIC;
				  Fin_SL   : OUT STD_LOGIC;
				  CmdLR_SL : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
				  VIRAGE   : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
			 );
	END component Automate_suiveur_de_ligne;
	
	component Automate_gestion_rotation IS
    PORT (
          start_rot : IN  STD_LOGIC;
		  dir_rot   : IN  STD_LOGIC;
		  clk       : IN  STD_LOGIC;
		  rst       : IN  STD_LOGIC;
		  posLigne  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		  fin_rot   : OUT STD_LOGIC;
          CmdLR_rot : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)
    );
	END component Automate_gestion_rotation;
	
	component Mux IS
    PORT(
			  clk, rst  : IN STD_LOGIC;
			  Start_SL  : IN STD_LOGIC;
			  Start_rot : IN STD_LOGIC;
			  CmdLR_rot : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
			  CmdLR_SL  : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
			  PosLigne  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			  START     : OUT STD_LOGIC;
			  CmdLR     : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)		  
		  );
	END component Mux;
	
	BEGIN
	
  
	
	NiosII: nios_system
	PORT MAP (
				clk_clk          => CLOCK_50,
				reset_reset_n    => KEY(0),
				sdram_clk_clk    => DRAM_CLK,
				pio_input_export => sig_pio_input,
                pio_output_export=> sig_pio_output,
				sdram_wire_addr  => DRAM_ADDR,
				sdram_wire_ba    => DRAM_BA,
				sdram_wire_cas_n => DRAM_CAS_N,
				sdram_wire_cke   => DRAM_CKE,
				sdram_wire_cs_n  => DRAM_CS_N,
				sdram_wire_dq    => DRAM_DQ,
				sdram_wire_dqm   => DRAM_DQM,
				sdram_wire_ras_n => DRAM_RAS_N,
				sdram_wire_we_n  => DRAM_WE_N
			); 
			
	PWM: PWM_generation
	PORT MAP (
				clk              => CLOCK_50,
				reset_n          => KEY(0),
				s_writedataR     => sig_consigne_moteur(13 downto 0),
				s_writedataL     => sig_consigne_moteur(27 downto 14),
				dc_motor_p_R     => MTRR_P,
				dc_motor_n_R     => MTRR_N,
				dc_motor_p_L     => MTRL_P,
				dc_motor_n_L     => MTRL_N
			);
			
	pll2freqs: pll_2freqs
	PORT MAP (
				areset		    => not(KEY(0)),
				inclk0		    => CLOCK_50,
				c0		    	=> clk_40MHZ,
				c1		    	=> clk_2KHZ
			);
			
	capteurs: capteurs_sol_seuil
	PORT MAP (
				clk		        => clk_40MHZ,    
				reset_n	        => KEY(0),
				data_capture	=> clk_2KHZ,	 
				data_readyr	    => sig_pio_input(1),
				data0r			=> sig_data_capteur_brut(7 downto 0),
				data1r			=> sig_data_capteur_brut(15 downto 8),	
				data2r			=> sig_data_capteur_brut(23 downto 16),
				data3r			=> sig_data_capteur_brut(31 downto 24),	
				data4r			=> sig_data_capteur_brut(39 downto 32),
				data5r			=> sig_data_capteur_brut(47 downto 40),
				data6r			=> sig_data_capteur_brut(55 downto 48),
			    NIVEAU 			=> std_logic_vector(to_unsigned(seuil_capteur,8)),
				vect_capt  		=> data_capteur_seuille,         
				ADC_CONVSTr		=> LTC_ADC_CONVST,
				ADC_SCK			=> LTC_ADC_SCK,
				ADC_SDIr		=> LTC_ADC_SDI,
				ADC_SDO			=> LTC_ADC_SDO
			);
			
	posL: position_ligne
	PORT MAP (
					data_capteur  => data_capteur_seuille,
					pos_ligne     => sig_posLigne,
					data_ready    => sig_pio_input(1),
					led           => sig_led,
					VIRAGE        => sig_VIRAGE
			);
			
	Automate_ligne: Automate_suiveur_de_ligne
	PORT MAP (
					posLigne  => sig_posLigne,
				    Start_SL  => sig_pio_output(0),
					clk       => CLOCK_50, 
					rst       => KEY(0),
				    Fin_SL    => sig_pio_input(0),
				    CmdLR_SL  => sig_consigne_moteur_SL,
					VIRAGE    => sig_VIRAGE
				);
				
	Automate_rotation: Automate_gestion_rotation
	PORT MAP (
					start_rot => sig_pio_output(1),
					dir_rot   => sig_pio_output(2),
					clk       => CLOCK_50, 
					rst       => KEY(0),
				    posLigne  => sig_posLigne,
				    fin_rot   => sig_pio_input(2),
					CmdLR_rot => sig_consigne_moteur_GR
				);
				
	Mux_Port_Map: Mux
	PORT MAP (
					clk       => CLOCK_50, 
					rst       => KEY(0),
					Start_SL  => sig_pio_output(0),
					Start_rot => sig_pio_output(1),
					CmdLR_rot => sig_consigne_moteur_GR,
					CmdLR_SL  => sig_consigne_moteur_SL,
					PosLigne  => sig_posLigne,
					START     => sig_pio_input(3),
					CmdLR     => sig_consigne_moteur
				);
			
	VCC3P3_PWRON_n <= '0';    
	MTR_Sleep_n    <='1';   
	LED(6 downto 0)  <= sig_led(4 downto 0) & sig_pio_input(0) & sig_pio_input(2);-- when sig_pio_output(0) = '1' else
	
 END T_arch_rtl;