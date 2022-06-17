LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY ALU IS 
	PORT (
		a_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		b_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		c_in: IN STD_LOGIC;
		op_sel: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		bit_sel: IN STD_LOGIC_VECTOR(2 DOWNTO 0);

		
		r_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		c_out: OUT STD_LOGIC;
		dc_out: OUT STD_LOGIC;
		z_out: OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE Arch1 OF ALU IS	
	signal op_sel_or: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_and: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_xor: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_com: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_add: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_sub: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_inc: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_dec: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_clr: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_swap: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_rl: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_rr: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_bc: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_bs: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_a: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal op_sel_b: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	signal c_out_sum: STD_LOGIC;
	signal dc_out_sum: STD_LOGIC;
	signal carry_sum9: STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal carry_sum5: STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	signal c_out_sub: STD_LOGIC;
	signal dc_out_sub: STD_LOGIC;
	signal carry_sub9: STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal carry_sub5: STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	signal z_out_bc: STD_LOGIC;
	signal z_out_bs: STD_LOGIC;
	signal saida: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	
	op_sel_or <= a_in or b_in; -- 0000 or
----------------------------------------------------------------
	op_sel_and <= a_in and b_in; -- 0001 and
----------------------------------------------------------------
	op_sel_xor <= a_in xor b_in; -- 0010 xor
----------------------------------------------------------------
	op_sel_com <= not a_in; -- 0011 NOT a
----------------------------------------------------------------
	op_sel_add <= a_in + b_in; -- 0100 Soma
	carry_sum9 <= ('0' & a_in) + ('0' & b_in);
	carry_sum5 <= ('0' & a_in(3 DOWNTO 0)) + ('0' & b_in(3 DOWNTO 0));
	c_out_sum <= carry_sum9(8);
	dc_out_sum <= carry_sum5(4);
----------------------------------------------------------------
	op_sel_sub <= a_in - b_in; -- 0101 Subtração
	carry_sub9 <=  ('0' & a_in) - ('0' & b_in);
	carry_sub5 <= ('0' & a_in(3 DOWNTO 0)) - ('0' & b_in(3 DOWNTO 0));
	c_out_sub <= carry_sub9(8);
	dc_out_sub <=  carry_sub5(4);
----------------------------------------------------------------
	op_sel_inc <= a_in + 1; -- 0110 Incremento
----------------------------------------------------------------
	op_sel_dec <= a_in - 1; -- 0111 Decremento
----------------------------------------------------------------
	op_sel_clr <= "00000000"; -- 1000 Clear
----------------------------------------------------------------
	op_sel_swap <= a_in(3 DOWNTO 0) & a_in(7 DOWNTO 4); -- 1001 Swap
----------------------------------------------------------------
	op_sel_rl <=  a_in(6 DOWNTO 0) & c_in; -- 1010 Rotação Esquerda
----------------------------------------------------------------
	op_sel_rr <=  c_in & a_in(7 DOWNTO 1); -- 1011 Rotação Direita
----------------------------------------------------------------
-- 1100 Limpa o bit apontado por bit_sel
	op_sel_bc <= a_in(7 DOWNTO 1) & '0' WHEN bit_sel = "000" ELSE 
	a_in(7 DOWNTO 2) & '0' & a_in(0) WHEN bit_sel = "001" ELSE 
	a_in(7 DOWNTO 3) & '0' & a_in(1 DOWNTO 0) WHEN bit_sel = "010" ELSE 
	a_in(7 DOWNTO 4) & '0' & a_in(2 DOWNTO 0) WHEN bit_sel = "011" ELSE 
	a_in(7 DOWNTO 5) & '0' & a_in(3 DOWNTO 0) WHEN bit_sel = "100" ELSE 
	a_in(7 DOWNTO 6) & '0' & a_in(4 DOWNTO 0) WHEN bit_sel = "101" ELSE 
	a_in(7) & '0' & a_in(5 DOWNTO 0) WHEN bit_sel = "110" ELSE 
	'0' & a_in(6 DOWNTO 0);
	
	z_out_bc <= a_in(0) WHEN bit_sel = "000" ELSE
	a_in(1) WHEN bit_sel = "001" ELSE
	a_in(2) WHEN bit_sel = "010" ELSE
	a_in(3) WHEN bit_sel = "011" ELSE
	a_in(4) WHEN bit_sel = "100" ELSE
	a_in(5) WHEN bit_sel = "101" ELSE
	a_in(6) WHEN bit_sel = "110" ELSE
	a_in(7);
----------------------------------------------------------------
-- 1101 Ajusta em ‘1’ o bit apontado por bit_sel
	op_sel_bs <= a_in(7 DOWNTO 1) & '1' WHEN bit_sel = "000" ELSE 
	a_in(7 DOWNTO 2) & '1' & a_in(0) WHEN bit_sel = "001" ELSE 
	a_in(7 DOWNTO 3) & '1' & a_in(1 DOWNTO 0) WHEN bit_sel = "010" ELSE 
	a_in(7 DOWNTO 4) & '1' & a_in(2 DOWNTO 0) WHEN bit_sel = "011" ELSE 
	a_in(7 DOWNTO 5) & '1' & a_in(3 DOWNTO 0) WHEN bit_sel = "100" ELSE 
	a_in(7 DOWNTO 6) & '1' & a_in(4 DOWNTO 0) WHEN bit_sel = "101" ELSE 
	a_in(7) & '1' & a_in(5 DOWNTO 0) WHEN bit_sel = "110" ELSE 
	'1' & a_in(6 DOWNTO 0);
	
	z_out_bs <= a_in(0) WHEN bit_sel = "000" ELSE
	a_in(1) WHEN bit_sel = "001" ELSE
	a_in(2) WHEN bit_sel = "010" ELSE
	a_in(3) WHEN bit_sel = "011" ELSE
	a_in(4) WHEN bit_sel = "100" ELSE
	a_in(5) WHEN bit_sel = "101" ELSE
	a_in(6) WHEN bit_sel = "110" ELSE
	a_in(7);
----------------------------------------------------------------
	op_sel_a <= a_in ; -- 1110 Passa A
----------------------------------------------------------------
	op_sel_b <= b_in;  -- 1111 Passa B
----------------------------------------------------------------

	saida <= op_sel_or WHEN op_sel = "0000" ELSE
	op_sel_and WHEN op_sel = "0001" ELSE
	op_sel_xor WHEN op_sel = "0010" ELSE
	op_sel_com WHEN op_sel = "0011" ELSE
	op_sel_add WHEN op_sel = "0100" ELSE
	op_sel_sub WHEN op_sel = "0101" ELSE
	op_sel_inc WHEN op_sel = "0110" ELSE
	op_sel_dec WHEN op_sel = "0111" ELSE
	op_sel_clr WHEN op_sel = "1000" ELSE
	op_sel_swap WHEN op_sel = "1001" ELSE
	op_sel_rl WHEN op_sel = "1010" ELSE
	op_sel_rr WHEN op_sel = "1011" ELSE
	op_sel_bc WHEN op_sel = "1100" ELSE
	op_sel_bs WHEN op_sel = "1101" ELSE
	op_sel_a WHEN op_sel = "1110" ELSE
	op_sel_b;
	
	z_out <= z_out_bc WHEN op_sel = "1100" ELSE
	z_out_bs WHEN op_sel = "1101" ELSE
	'1' WHEN saida = "00000000" ELSE
	'0';
	
	c_out <= c_out_sum WHEN op_sel = "0100" ELSE
	c_out_sub WHEN op_sel = "0101" ELSE
	a_in(7) WHEN op_sel = "1010" ELSE
	a_in(0) WHEN op_sel = "1011" ELSE
	'0';
	
	dc_out <= dc_out_sum WHEN op_sel = "0100" ELSE
	dc_out_sub WHEN op_sel = "0101" ELSE
	'0';
	
	r_out <= saida;
END Arch1;