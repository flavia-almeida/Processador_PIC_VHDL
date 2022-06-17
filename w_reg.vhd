LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY w_reg IS 
	PORT (
	
	nrst: IN STD_LOGIC;
	clk_in: IN STD_LOGIC;
	d_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- entrada de dados para o registrador
	wr_en: IN STD_LOGIC; -- enable escrita no registrador
	
	w_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- saida de dados do registrador
	);
END ENTITY;

ARCHITECTURE Arch1 OF w_reg IS	

BEGIN

	process(clk_in, nrst)
	BEGIN
		IF nrst = '0' THEN
			w_out <= (others => '0');
		ELSIF rising_edge(clk_in) THEN
			IF wr_en = '1' THEN
				w_out <= d_in;
			END IF;
		END IF;
	END PROCESS;

END Arch1;