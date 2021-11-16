-- 1. Os dois conjuntos das saídas Segundos1X e Segundos2X mostram o valor dos segundos . Por
-- exemplo para o valor de Segundos= 27 Segundos1(0 a 3) mostra o número 7 (0111) e
-- Segundos2(0 a 3) mostra o número 2 (0010).
-- 2. Os dois conjuntos das saídas Minutos1X e Minutos2X mostram o valor dos segundos . Por
-- exemplo para o valor de Minutos= 27 Minutos1(0 a 3) mostra o número 7 (0111) e Minutos2(0 a
-- 3) mostra o número 2 (0010).
-- 3. Os dois conjuntos das saídas Horas1X e Horas2X mostram o valor dos segundos . Por exemplo
-- para o valor de Horas= 12 Horas1(0 a 3) mostra o número 2 (0010) e Horas2(0 a 3) mostra o
-- número 1 (0001).
-- 4. Os dois conjuntos das saídas Horas1X e Horas2X podem mostrar valores de 0 a 12.
-- 5. A saída AM/PM mostra 0 para AM e 1 para PM.
-- 6. A saída AM/PM deve ser conectada a LED0 na placa Basys3
-- Página 2 de 3
-- 7. Dependendo do valor de um chave Chv0, a 7 segmento deve mostrar (Segundos e Minutos
-- quando Chv0=’0’) ou (Horas e minutos quando Chv0=’1’).
-- 8. A entrada Mode define o modo atual (Relógio quando 0, cronômetro quando 1)
-- 9. A entrada Config (2 bits) define se o Relógio ou está no modo funcional ou de configuração
-- (funcional quando 00, configuração Segundos quando 01, configuração Minutos quando 10,
-- configuração Horas quando 11)..
-- 10. No modo de configuração (somente para Relógio) cada borda subida selecionada uma das saídas
-- para configurar (a saída selecionada começa piscar) e no modo de operação nenhuma saída
-- pisca e o Relógio opera normalmente.
-- 11. A entrada Start/Inc inicia o cronômetro (no modo cronômetro) e aumenta o valor da saída
-- selecionada quando Config está no modo configuração.
-- 12. A entrada Stop pausa o cronômetro (no modo cronômetro).
-- 13. A entrada Reset reseta o valor do cronômetro para 0 (no modo cronômetro) e o valor do
-- Relógio para 0 (no modo Relógio e configuração)
-- 14. O cronômetro inicializa com “0000” nos Segundos, Minutos e Horas.
-- 15. Start/Inc, Stop, Reset seriam ativados com a borda subida.
-- 16. A entrada Clk_100Mhz é ativada com a borda subida.
-- 17. O Relógio deve continuar funcionando normal enquanto o cronômetro estiver sendo usado.
-- 18. O cronômetro deve continuar funcionando normal enquanto o Relógio estiver sendo usado.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity main is
    PORT(

		mode : in STD_LOGIC;
		config : in STD_LOGIC_VECTOR(1 DOWNTO 0);
		chv0 : in STD_LOGIC;
		
		chrono_start : in STD_LOGIC;
		chrono_stop : in STD_LOGIC;
		chrono_reset : in STD_LOGIC;
		
		seg_unid : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg_dez : OUT STD_LOGIC_VECTOR(6 downto 0);
		min_unid : OUT STD_LOGIC_VECTOR(6 downto 0);
		min_dez : OUT STD_LOGIC_VECTOR(6 downto 0);
		hora_unid : OUT STD_LOGIC_VECTOR(6 downto 0);
		hora_dez : OUT STD_LOGIC_VECTOR(6 downto 0); 
		
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

	signal chrono_started : integer := 0;
	
	signal chrono_hora_dezena : integer range 0 to 2;
    signal chrono_hora_unidade : integer range 0 to 9;
    signal chrono_min_dezena : integer range 0 to 5;
    signal chrono_min_unidade : integer range 0 to 9;
    signal chrono_sec_dezena : integer range 0 to 5;
    signal chrono_sec_unidade : integer range 0 to 9;

	signal ampm : integer range 0 to 1;

	signal clk : std_logic :='0';

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

		-- processa comeco de cronometro. Usa-se flag chrono started para controlar quando ta parado
		process(chrono_start)
			begin
				if(chrono_start = '1' and chrono_stop = '0') then
					chrono_started <= 1;
				end if;
		end process;

		-- processa parada de cronometro. Precisa estar depois de chrono start para 
		process(chrono_stop)
			begin
				if(chrono_stop = '1') then
					chrono_started <= 0;
				end if;
		end process;

		process(chrono_reset)
			begin
				if(chrono_reset = '1') then
					chrono_hora_dezena <= 0;
					chrono_hora_unidade <= 0;
					chrono_min_dezena <= 0;
					chrono_min_unidade <= 0;
					chrono_sec_dezena <= 0;
					chrono_sec_unidade <= 0;
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

					if chrono_started = 1 then
						if chrono_sec_unidade = 9 then
							chrono_sec_unidade <= 0;
							if chrono_sec_dezena = 5 then
								chrono_sec_dezena <= 0;
								if chrono_min_unidade = 9 then
									chrono_min_unidade <= 0;
									if chrono_min_dezena = 5 then
										chrono_min_dezena <= 0;
										if chrono_hora_unidade = 9 or (chrono_hora_dezena = 1 and chrono_hora_unidade = 2) then
											if chrono_hora_unidade = 9 then
												chrono_hora_dezena <= 1;
											else
												chrono_hora_dezena <= 0;
											end if;
											chrono_hora_unidade <= 0;
										else
											chrono_hora_unidade <= chrono_hora_unidade + 1;
										end if;
									else
										chrono_min_dezena <= chrono_min_dezena + 1;
									end if;
								else
									chrono_min_unidade = chrono_min_unidade + 1;
								end if;
							else
								chrono_sec_dezena <= chrono_sec_dezena + 1;
							end if;
						else
							chrono_sec_unidade <= chrono_sec_unidade + 1;
						end if;
					end if;
				
				end if;



				hd <= std_logic_vector(to_unsigned(h_ms_int, hms'length));
				hu <= std_logic_vector(to_unsigned(h_ls_int, hls'length));
				md <= std_logic_vector(to_unsigned(m_ms_int, mms'length));
				mu <= std_logic_vector(to_unsigned(m_ls_int, mls'length));
				sd <= std_logic_vector(to_unsigned(s_ms_int, sms'length));
				su <= std_logic_vector(to_unsigned(s_ls_int, sls'length));
	
		end process clk_proc;
		
				
	--- For the MS  of the Second
	--start: count_mod5 port map(sms1=> sms, seg21=> seg2);
	PROCESS (sd)
		BEGIN
			CASE sd IS 
				WHEN "000" => seg_dez <= "1000000";
				WHEN "001" => seg_dez <= "1111001";
				WHEN "010" => seg_dez <= "0100100";
				WHEN "011" => seg_dez <= "0110000";
				WHEN "100" => seg_dez <= "0011001";
				WHEN "101" => seg_dez <= "0010010";
				WHEN OTHERS => seg_dez <= "1000000";
			END CASE;
	END PROCESS;
	-- For the LS of the second
	PROCESS (su)
		BEGIN
			CASE su IS 
				 WHEN "0000" => seg_unid  <= "1000000";
				 WHEN "0001" => seg_unid <= "1111001";
				 WHEN "0010" => seg_unid <= "0100100";
				 WHEN "0011" => seg_unid <= "0110000";
				 WHEN "0100" => seg_unid <= "0011001";
				 WHEN "0101" => seg_unid <= "0010010";
				 WHEN "0110" => seg_unid <= "0000010";
				 WHEN "0111" => seg_unid <= "1011000";
				 WHEN "1000" => seg_unid <= "0000000";
				 WHEN "1001" => seg_unid <= "0011000";
				 WHEN OTHERS => seg_unid <= "1000000";
			END CASE;
	END PROCESS;	
	
	--- For the MS of the Second
	PROCESS (md)
		BEGIN
			CASE md IS 
				WHEN "000" => min_dez <= "1000000";
				WHEN "001" => min_dez <= "1111001";
				WHEN "010" => min_dez <= "0100100";
				WHEN "011" => min_dez <= "0110000";
				WHEN "100" => min_dez <= "0011001";
				WHEN "101" => min_dez <= "0010010";
				WHEN OTHERS => min_dez <= "1000000";
			END CASE;
	END PROCESS;
	
	-- For the LS of the second
	PROCESS (mu)
		BEGIN
		CASE mu IS 
			 WHEN "0000" => min_unid <= "1000000";
			 WHEN "0001" => min_unid <= "1111001";
			 WHEN "0010" => min_unid <= "0100100";
			 WHEN "0011" => min_unid <= "0110000";
			 WHEN "0100" => min_unid <= "0011001";
			 WHEN "0101" => min_unid <= "0010010";
			 WHEN "0110" => min_unid <= "0000010";
			 WHEN "0111" => min_unid <= "1011000";
			 WHEN "1000" => min_unid <= "0000000";
			 WHEN "1001" => min_unid <= "0011000";
			 WHEN OTHERS => min_unid <= "1000000";		
		 END CASE;
	END PROCESS;	
	
	--For the MS of the hour hand
	PROCESS(hd)
		BEGIN
			CASE hd IS 
				WHEN "00" => hora_dez <= "1000000";
				WHEN "01" => hora_dez <= "1111001";
				WHEN "10" => hora_dez <= "0100100";
				WHEN OTHERS => hora_dez <= "1000000";
			END CASE;
	END PROCESS;
	
	-- For the LS of the hour hand
	PROCESS(hu)
		BEGIN
			CASE hu IS
				WHEN "00" => hora_unid <= "1000000";
				WHEN "01" => hora_unid <= "1111001";
				WHEN "10" => hora_unid <= "0100100";
				WHEN "11" => hora_unid <= "0110000";
				WHEN OTHERS => hora_unid <= "1000000";
			END CASE;
	END PROCESS;

end Behavioral;
