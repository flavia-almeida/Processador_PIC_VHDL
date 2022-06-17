LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control IS

	PORT (
		----------------Entradas-------------------------------
		alu_z : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		nrst : IN STD_LOGIC;
		instr : IN STD_LOGIC_VECTOR(13 DOWNTO 0);

		----------------Saídas--------------------------------
		inc_pc : OUT STD_LOGIC;
		lit_sel : OUT STD_LOGIC;
		load_pc : OUT STD_LOGIC;
		rd_en : OUT STD_LOGIC;
		stack_pop : OUT STD_LOGIC;
		stack_push : OUT STD_LOGIC;
		wr_c_en : OUT STD_LOGIC;
		wr_dc_en : OUT STD_LOGIC;
		wr_en : OUT STD_LOGIC;
		wr_w_reg_en : OUT STD_LOGIC;
		wr_z_en : OUT STD_LOGIC;
		bit_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		op_sel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);

END ENTITY;

ARCHITECTURE arch OF control IS
	TYPE state_type IS (rst, fetch_only, fet_dec_ex);
	SIGNAL pres_state : state_type;
	SIGNAL next_state : state_type;

	SIGNAL d_bit : STD_LOGIC;
	SIGNAL b_bits : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL opcode_3bits : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL opcode_4bits : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL opcode_5bits : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL opcode_6bits : STD_LOGIC_VECTOR(5 DOWNTO 0);

	------------------------ OPCODE_6BITS -------------------------------
	CONSTANT op_addwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000111";
	CONSTANT op_andwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
	CONSTANT op_clrf_rw : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
	CONSTANT op_comf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";
	CONSTANT op_decf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
	CONSTANT op_decfsz : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001011";
	CONSTANT op_incf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010";
	CONSTANT op_incfsz : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	CONSTANT op_iorwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	CONSTANT op_movf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";
	CONSTANT op_nop_movwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	CONSTANT op_rlf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001101";
	CONSTANT op_rrf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
	CONSTANT op_subwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	CONSTANT op_swapf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001110";
	CONSTANT op_xorwf : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000110";
	CONSTANT op_andlw : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111001";
	CONSTANT op_iorlw : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111000";
	CONSTANT op_xorlw : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111010";

	------------------------ OPCODE_5BITS -------------------------------
	CONSTANT op_addlw : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111";
	CONSTANT op_sublw : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11110";

	------------------------ OPCODE_4BITS -------------------------------
	CONSTANT op_bcf : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	CONSTANT op_btfsc : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
	CONSTANT op_bsf : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
	CONSTANT op_btfss : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
	CONSTANT op_movlw : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
	CONSTANT op_retlw : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
	------------------------ OPCODE_3BITS -------------------------------
	CONSTANT op_call : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
	CONSTANT op_goto : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
	------------------------ OPCODE_14BITS -------------------------------
	CONSTANT op_return : STD_LOGIC_VECTOR(13 DOWNTO 0) := "00000000001000";

BEGIN

	d_bit <= instr(7);
	b_bits <= instr(9 DOWNTO 7);
	opcode_3bits <= instr(13 DOWNTO 11);
	opcode_4bits <= instr(13 DOWNTO 10);
	opcode_5bits <= instr(13 DOWNTO 9);
	opcode_6bits <= instr(13 DOWNTO 8);

	PROCESS (nrst, clk)
	BEGIN
		IF nrst = '0' THEN
			pres_state <= rst;
		ELSIF RISING_EDGE(clk) THEN
			pres_state <= next_state;
		END IF;
	END PROCESS;

	PROCESS (nrst, pres_state, instr, opcode_6bits, opcode_5bits, opcode_4bits, opcode_3bits, b_bits, d_bit, alu_z)
	BEGIN

		next_state <= pres_state;

		inc_pc <= '0';
		lit_sel <= '0';
		load_pc <= '0';
		rd_en <= '0';
		stack_pop <= '0';
		stack_push <= '0';
		wr_c_en <= '0';
		wr_dc_en <= '0';
		wr_en <= '0';
		wr_w_reg_en <= '0';
		wr_z_en <= '0';
		bit_sel(2 DOWNTO 0) <= "---";
		op_sel(3 DOWNTO 0) <= "----";

		CASE pres_state IS

			WHEN rst =>
				next_state <= fetch_only;

			WHEN fetch_only =>
				next_state <= fet_dec_ex;
				inc_pc <= '1';

			WHEN fet_dec_ex =>
				CASE opcode_6bits IS
					WHEN op_addwf =>
						next_state <= fet_dec_ex;

						op_sel <= "0100";
						inc_pc <= '1';
						wr_z_en <= '1';
						wr_dc_en <= '1';
						wr_c_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;

					WHEN op_andwf =>
						next_state <= fet_dec_ex;

						op_sel <= "0001";
						wr_z_en <= '1';
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_clrf_rw =>
						next_state <= fet_dec_ex;

						op_sel <= "1000";
						inc_pc <= '1';
						wr_z_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_comf =>
						next_state <= fet_dec_ex;

						op_sel <= "0011";
						inc_pc <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_decf =>
						next_state <= fet_dec_ex;

						op_sel <= "0111";
						inc_pc <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_decfsz =>

						op_sel <= "0111";
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;

						IF alu_z = '1' THEN
							next_state <= fetch_only;
						ELSE
							next_state <= fet_dec_ex;
						END IF;

					WHEN op_incf =>
						next_state <= fet_dec_ex;

						op_sel <= "0110";
						inc_pc <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_incfsz =>

						op_sel <= "0110";
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;

						IF alu_z = '1' THEN
							next_state <= fetch_only;
						ELSE
							next_state <= fet_dec_ex;
						END IF;

					WHEN op_iorwf =>
						next_state <= fet_dec_ex;

						op_sel <= "0000";
						inc_pc <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_movf =>
						next_state <= fet_dec_ex;

						op_sel <= "1110";
						inc_pc <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;

					WHEN op_nop_movwf =>
						next_state <= fet_dec_ex;
						inc_pc <= '1';

						IF d_bit = '1' THEN
							op_sel <= "1111";
							wr_en <= '1';
						END IF;

					WHEN op_rlf =>
						next_state <= fet_dec_ex;

						op_sel <= "1010";
						wr_c_en <= '1';
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_rrf =>
						next_state <= fet_dec_ex;

						op_sel <= "1011";
						inc_pc <= '1';
						wr_c_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_subwf =>
						next_state <= fet_dec_ex;

						op_sel <= "0101";
						inc_pc <= '1';
						wr_c_en <= '1';
						wr_dc_en <= '1';
						wr_z_en <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_swapf =>
						next_state <= fet_dec_ex;

						op_sel <= "1001";
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_xorwf =>
						next_state <= fet_dec_ex;

						op_sel <= "0010";
						wr_z_en <= '1';
						inc_pc <= '1';
						rd_en <= '1';

						IF d_bit = '0' THEN
							wr_w_reg_en <= '1';
						ELSE
							wr_en <= '1';
						END IF;
					WHEN op_andlw =>
						next_state <= fet_dec_ex;

						op_sel <= "0001";
						inc_pc <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';

					WHEN op_iorlw =>
						next_state <= fet_dec_ex;

						op_sel <= "0000";
						inc_pc <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';

					WHEN op_xorlw =>
						next_state <= fet_dec_ex;

						op_sel <= "0010";
						inc_pc <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';

					WHEN OTHERS => NULL;
				END CASE;
				CASE opcode_5bits IS
					WHEN op_addlw =>
						next_state <= fet_dec_ex;

						op_sel <= "0100";
						inc_pc <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_c_en <= '1';
						wr_dc_en <= '1';
						wr_w_reg_en <= '1';

					WHEN op_sublw =>
						next_state <= fet_dec_ex;

						op_sel <= "0101";
						inc_pc <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_dc_en <= '1';
						wr_c_en <= '1';
						wr_w_reg_en <= '1';

					WHEN OTHERS => NULL;
				END CASE;
				CASE opcode_4bits IS
					WHEN op_bcf =>
						next_state <= fet_dec_ex;

						op_sel <= "1100";
						bit_sel <= b_bits;
						inc_pc <= '1';
						rd_en <= '1';
						wr_en <= '1';

					WHEN op_btfsc =>
						op_sel <= "1100";
						bit_sel <= b_bits;
						inc_pc <= '1';
						rd_en <= '1';

						IF alu_z = '0' THEN
							next_state <= fetch_only;
						ELSE
							next_state <= fet_dec_ex;
						END IF;

					WHEN op_bsf =>
						next_state <= fet_dec_ex;

						op_sel <= "1101";
						bit_sel <= b_bits;
						inc_pc <= '1';
						rd_en <= '1';
						wr_en <= '1';

					WHEN op_btfss =>
						op_sel <= "1101";
						bit_sel <= b_bits;
						inc_pc <= '1';
						rd_en <= '1';

						IF alu_z = '1' THEN
							next_state <= fetch_only;
						ELSE
							next_state <= fet_dec_ex;
						END IF;
					WHEN op_movlw =>
						next_state <= fet_dec_ex;
						wr_z_en <= '1';
						wr_w_reg_en <= '1';
						lit_sel <= '1';
						op_sel <= "1110";
						inc_pc <= '1';

					WHEN op_retlw =>
						next_state <= fetch_only;
						wr_en <= '1';
						wr_w_reg_en <= '1';
						lit_sel <= '1';
						op_sel <= "1110";
						inc_pc <= '1';
						stack_pop <= '1';

					WHEN OTHERS => NULL;
				END CASE;
				CASE opcode_3bits IS
					WHEN op_call =>

						op_sel <= "1110";
						next_state <= fetch_only;
						rd_en <= '1';
						stack_push <= '1';
						load_pc <= '1';
						lit_sel <= '1';

					WHEN op_goto =>

						op_sel <= "1110";
						next_state <= fetch_only;
						rd_en <= '1';
						load_pc <= '1';
						lit_sel <= '1';

					WHEN OTHERS => NULL;
				END CASE;
				CASE instr IS
					WHEN op_return =>

						next_state <= fetch_only;
						stack_pop <= '1';
						wr_en <= '1';

					WHEN OTHERS => NULL;
				END CASE;
		END CASE;

	END PROCESS;

END arch;
