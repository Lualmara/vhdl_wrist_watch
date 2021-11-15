----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2021 04:59:27 PM
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    PORT(

		mode : in STD_LOGIC;
		config : in STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		chrono_start : in STD_LOGIC;
		chrono_stop : in STD_LOGIC;
		chrono_reset : in STD_LOGIC;
		
		chv0 : in STD_LOGIC;
	
		ledgrp : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		ledgrpcount: buffer integer;
		
		seg1 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg2 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg3 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg4 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg5 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg6 : OUT STD_LOGIC_VECTOR(6 downto 0); 
		
		clk1 : IN STD_LOGIC
	);
end main;

architecture Behavioral of main is
    signal relogio_hora_dezena : integer range 0 to 2;
    signal relogio_hora_unidade : integer range 0 to 9;
    signal relogio_min_dezena : integer range 0 to 5;
    signal relogio_min_unidade : integer range 0 to 9;
    signal relogio_sec_dezena : integer range 0 to 5;
    signal relogio_sec_unidade : integer range 0 to 9;
	
	signal chrono_hora_dezena : integer range 0 to 2;
    signal chrono_hora_unidade : integer range 0 to 9;
    signal chrono_min_dezena : integer range 0 to 5;
    signal chrono_min_unidade : integer range 0 to 9;
    signal chrono_sec_dezena : integer range 0 to 5;
    signal chrono_sec_unidade : integer range 0 to 9;

	signal ampm : integer range 0 to 1;

	signal clk : std_logic :='0';
    signal count : integer :=1;
	signal secCount : integer :=1;

	signal su :   STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal sd :   STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal mu :   STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal md :   STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal hu :   STD_LOGIC_VECTOR(1 DOWNTO 0);
	signal hd :   STD_LOGIC_VECTOR(1 DOWNTO 0);

	begin

      --clk generation.For 50 MHz clock this generates 1 Hz clock.
        process(clk1)
            begin
                if(clk1'event and clk1='1') then
                    count <= count+1;
                    if(count = 25000000) then
                        clk <= not clk;
                        count <=1;
                    end if;
                end if;
        end process;
		
		clk_proc : process(clk, mode, switch1)
			variable ledcount : integer := 1;
			begin
				if (clk'event and clk ='1') then
					-- relogio funcional somente fora de configuracao
					if config = '0' then 
						if relogio_sec_unidade = 9 then
							relogio_sec_unidade <= 0;
							if relogio_sec_dezena = 5 then
								relogio_sec_dezena <= 0;
								if relogio_min_unidade = 9 then
									relogio_min_unidade <= 0;
									if relogio_min_dezena = 5 then
										relogio_min_dezena <= 0;
										if relogio_hora_unidade = 9 or (relogio_hora_dezena = 1 and relogio_hora_unidade = 2) then
											if relogio_hora_unidade = 9 then
												relogio_hora_dezena <= 1;
											else
												relogio_hora_dezena <= 0;
												if ampm = 0 then
													ampm <= 1;
												else 
													ampm <= 0;
												end if;
											end if;
											relogio_hora_unidade <= 0;
										else
											relogio_hora_unidade <= relogio_hora_unidade + 1;
										end if;
									else
										relogio_min_dezena <= relogio_min_dezena + 1;
									end if;
								else
									relogio_min_unidade = relogio_min_unidade + 1;
								end if;
							else
								relogio_sec_dezena <= relogio_sec_dezena + 1;
							end if;
						else
							relogio_sec_unidade <= relogio_sec_unidade + 1;
						end if;
					end if;
					
					
						
					end if;
                        
				elsif switch1 = '1' then
					h_ms_int <= 0;
                    h_ls_int <= 0;
                    m_ms_int <= 0;
                    m_ls_int <= 0;
                    s_ms_int <= 0;
                    s_ls_int <= 0;
				end if;
			end if;
			      hms <= std_logic_vector(to_unsigned(h_ms_int, hms'length));
			      hls <= std_logic_vector(to_unsigned(h_ls_int, hls'length));
			      mms <= std_logic_vector(to_unsigned(m_ms_int, mms'length));
			      mls <= std_logic_vector(to_unsigned(m_ls_int, mls'length));
				  sms <= std_logic_vector(to_unsigned(s_ms_int, sms'length));
			      sls <= std_logic_vector(to_unsigned(s_ls_int, sls'length));
	
		end process clk_proc;
		
	PROCESS (ledgrpcount)
		BEGIN
			CASE ledgrpcount IS
				WHEN 0 => ledgrp <= "000000000000";
				WHEN 1 => ledgrp <= "000000000001";
				WHEN 2 => ledgrp <= "000000000011";
				WHEN 3 => ledgrp <= "000000000111";
				WHEN 4 => ledgrp <= "000000001111";
				WHEN 5 => ledgrp <= "000000011111";
				WHEN 6 => ledgrp <= "000000111111";
				WHEN 7 => ledgrp <= "000001111111";
				WHEN 8 => ledgrp <= "000011111111";
				WHEN 9 => ledgrp <= "000111111111";
				WHEN 10 => ledgrp <= "001111111111";
				WHEN 11 => ledgrp <= "011111111111";
				WHEN 12 => ledgrp <= "111111111111";
				WHEN OTHERS => ledgrp <= "000000000000";
			END CASE;
	END PROCESS;
				
	--- For the MS  of the Second
	--start: count_mod5 port map(sms1=> sms, seg21=> seg2);
	PROCESS (sms)
		BEGIN
			CASE sms IS 
				WHEN "000" => seg2 <= "1000000";
				WHEN "001" => seg2 <= "1111001";
				WHEN "010" => seg2 <= "0100100";
				WHEN "011" => seg2 <= "0110000";
				WHEN "100" => seg2 <= "0011001";
				WHEN "101" => seg2 <= "0010010";
				WHEN OTHERS => seg2 <= "1000000";
			END CASE;
	END PROCESS;
	-- For the LS of the second
	PROCESS (sls)
		BEGIN
			CASE sls IS 
				 WHEN "0000" => seg1  <= "1000000";
				 WHEN "0001" => seg1 <= "1111001";
				 WHEN "0010" => seg1 <= "0100100";
				 WHEN "0011" => seg1 <= "0110000";
				 WHEN "0100" => seg1 <= "0011001";
				 WHEN "0101" => seg1 <= "0010010";
				 WHEN "0110" => seg1 <= "0000010";
				 WHEN "0111" => seg1 <= "1011000";
				 WHEN "1000" => seg1 <= "0000000";
				 WHEN "1001" => seg1 <= "0011000";
				 WHEN OTHERS => seg1 <= "1000000";
			END CASE;
	END PROCESS;	
	
	--- For the MS of the Second
	PROCESS (mms)
		BEGIN
			CASE mms IS 
				WHEN "000" => seg4 <= "1000000";
				WHEN "001" => seg4 <= "1111001";
				WHEN "010" => seg4 <= "0100100";
				WHEN "011" => seg4 <= "0110000";
				WHEN "100" => seg4 <= "0011001";
				WHEN "101" => seg4 <= "0010010";
				WHEN OTHERS => seg4 <= "1000000";
			END CASE;
	END PROCESS;
	
	-- For the LS of the second
	PROCESS (mls)
		BEGIN
		CASE mls IS 
			 WHEN "0000" => seg3 <= "1000000";
			 WHEN "0001" => seg3 <= "1111001";
			 WHEN "0010" => seg3 <= "0100100";
			 WHEN "0011" => seg3 <= "0110000";
			 WHEN "0100" => seg3 <= "0011001";
			 WHEN "0101" => seg3 <= "0010010";
			 WHEN "0110" => seg3 <= "0000010";
			 WHEN "0111" => seg3 <= "1011000";
			 WHEN "1000" => seg3 <= "0000000";
			 WHEN "1001" => seg3 <= "0011000";
			 WHEN OTHERS => seg3 <= "1000000";		
		 END CASE;
	END PROCESS;	
	
	--For the MS of the hour hand
	PROCESS(hms)
		BEGIN
			CASE hls IS 
				WHEN "00" => seg6 <= "1000000";
				WHEN "01" => seg6 <= "1111001";
				WHEN "10" => seg6 <= "0100100";
				WHEN OTHERS => seg6 <= "1000000";
			END CASE;
	END PROCESS;
	
	-- For the LS of the hour hand
	PROCESS(hls)
		BEGIN
			CASE hls IS
				WHEN "00" => seg5 <= "1000000";
				WHEN "01" => seg5 <= "1111001";
				WHEN "10" => seg5 <= "0100100";
				WHEN "11" => seg5 <= "0110000";
				WHEN OTHERS => seg5 <= "1000000";
			END CASE;
	END PROCESS;

end Behavioral;
