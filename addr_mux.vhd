LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY add_mux IS 
	PORT (
		rp_in: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		dir_addr_in: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		irp_in: IN STD_LOGIC;
		ind_addr_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);	
		
		abus_out: OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE Arch1 OF add_mux IS
BEGIN

	abus_out <= irp_in & ind_addr_in when dir_addr_in = "0000000" else rp_in & dir_addr_in;

END Arch1;