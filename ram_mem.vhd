LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ram_mem IS
	PORT(
	------ENTRADAS-----------
		nrst : 		IN STD_LOGIC;
		clk_in : 	IN STD_LOGIC;
		abus_in:	IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dbus_in:	IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		wr_en : 	IN STD_LOGIC;
		rd_en : 	IN STD_LOGIC;
		
	------SAIDAS-------------------
		dbus_out: 	OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	
	);
END ENTITY;

ARCHITECTURE arch1 OF ram_mem IS
	type mem0_type is array (32 to 111) of std_logic_vector(7 downto 0);
	type mem1_type is array (160 to 239) of std_logic_vector(7 downto 0);
	type mem2_type is array (288 to 367) of std_logic_vector(7 downto 0);
	
	type mem_com_type is array (0 to 15) of std_logic_vector(7 downto 0);		
	------	
	signal mem_0 : mem0_type;
	signal mem_1 : mem1_type;
	signal mem_2 : mem2_type;
	
	signal mem_com: mem_com_type;	
	------		
	signal abus_in_int : integer range 0 to 511;
	signal alt_abus_in_int: integer range 112 to 127;	
	------
BEGIN
				
	abus_in_int <= to_integer(unsigned(abus_in));
	alt_abus_in_int <= to_integer(unsigned(abus_in(6 downto 0)));

	process(clk_in, nrst)
	
	
	BEGIN	
		IF nrst = '0' THEN
			mem_0 <= (OTHERS => (OTHERS => '0'));
			mem_1 <= (OTHERS => (OTHERS => '0'));
			mem_2 <= (OTHERS => (OTHERS => '0'));
			----
			mem_com <= (OTHERS=> (OTHERS => '0'));
		ELSIF rising_edge(clk_in) THEN
			IF wr_en = '1' THEN
			
				case abus_in_int is
					when 32 to 111  => mem_0(abus_in_int) <= dbus_in;
					when 160 to 239 => mem_1(abus_in_int) <= dbus_in;
					when 288 to 367 => mem_2(abus_in_int) <= dbus_in;
					when others		=> null;
				end case;
				------
				case alt_abus_in_int IS
					when 112 to 127 => mem_com(alt_abus_in_int - 112) <= dbus_in;
					when others 	=> null;
				end case;				
			END IF;			
		END IF;	
	END PROCESS;
	
	dbus_out <= mem_0(abus_in_int) when rd_en = '1' AND abus_in_int >= 32 AND abus_in_int <= 111 ELSE
				mem_1(abus_in_int) when rd_en = '1' AND abus_in_int >= 160 AND abus_in_int <= 239 ELSE
				mem_2(abus_in_int) when rd_en = '1' AND abus_in_int >= 288 AND abus_in_int <= 367 ELSE
				mem_com(alt_abus_in_int - 112) WHEN rd_en = '1' AND alt_abus_in_int >= 112 AND alt_abus_in_int <= 127 ELSE
				"ZZZZZZZZ";
END arch1;