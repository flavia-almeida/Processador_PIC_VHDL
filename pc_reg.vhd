LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY PC_reg IS
	PORT (
		------ENTRADAS-----------
		nrst : IN STD_LOGIC;
		clk_in : IN STD_LOGIC;
		addr_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		inc_pc : IN STD_LOGIC;
		load_pc : IN STD_LOGIC;
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		stack_push : IN STD_LOGIC;
		stack_pop : IN STD_LOGIC;

		------SAIDAS-------------------
		nextpc_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)

	);
END ENTITY;

ARCHITECTURE arch1 OF PC_reg IS
	TYPE stack_reg_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg : stack_reg_type;

	SIGNAL PC : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL PCLATH : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
	PROCESS (nrst, clk_in)
	BEGIN

		IF nrst = '0' THEN
			stack_reg <= (OTHERS => (OTHERS => '0'));
			PC <= (OTHERS => '0');
			PCLATH <= (OTHERS => '0');

		ELSIF rising_edge(clk_in) THEN

			IF stack_pop = '1' THEN
				PC <= stack_reg(0);
				stack_reg(7) <= (OTHERS => '0');
				stack_reg(0 TO 6) <= stack_reg (1 TO 7);

			ELSIF inc_pc = '1' THEN --Incremento
				PC <= PC + 1;

			ELSIF load_pc = '1' THEN
				PC(10 DOWNTO 0) <= addr_in;
				PC(12 DOWNTO 11) <= PCLATH(4 DOWNTO 3);

			ELSIF wr_en = '1' THEN

				IF abus_in(6 DOWNTO 0) = "0000010" THEN
					PC(7 DOWNTO 0) <= dbus_in;
					PC(12 DOWNTO 8) <= PCLATH (4 DOWNTO 0);
				ELSIF abus_in(6 DOWNTO 0) = "0001010" THEN
					PCLATH <= dbus_in;

				END IF;
			END IF;

			IF stack_push = '1' THEN
				stack_reg(0) <= PC;
				stack_reg(1 TO 7) <= stack_reg(0 TO 6);
			END IF;

		END IF;
	END PROCESS;

	nextpc_out <= stack_reg(0) WHEN stack_pop = '1' ELSE
		PC + 1 WHEN inc_pc = '1' ELSE
		PCLATH(4 DOWNTO 3) & addr_in WHEN load_pc = '1' ELSE
		PCLATH(4 DOWNTO 0) & dbus_in WHEN wr_en = '1' ELSE
		PC;

	dbus_out <=
		PC(7 DOWNTO 0) WHEN rd_en = '1' AND abus_in(6 DOWNTO 0) = "0000010" ELSE
		PCLATH WHEN rd_en = '1' AND abus_in(6 DOWNTO 0) = "0001010" ELSE
		(OTHERS => 'Z');

END arch1;
