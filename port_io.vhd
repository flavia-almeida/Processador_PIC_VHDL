LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Port_io IS
    GENERIC (
        port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
        tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000001";
        alt_port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
        alt_tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000001"
    );

    PORT (
        nrst : IN STD_LOGIC;
        clk_in : IN STD_LOGIC;
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        port_io : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch OF Port_io IS

    SIGNAL port_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tris_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL latch : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    PROCESS (nrst, clk_in, abus_in) --PORT REG
    BEGIN
        IF nrst = '0' THEN
            tris_reg <= (OTHERS => '1');
            port_reg <= (OTHERS => '0');

        ELSIF RISING_EDGE(clk_in) THEN

            IF wr_en = '1' THEN
                IF (abus_in = port_addr OR abus_in = alt_port_addr) THEN
                    port_reg <= dbus_in;

                ELSIF (abus_in = tris_addr OR abus_in = alt_tris_addr) THEN
                    tris_reg <= dbus_in;
                END IF;

            END IF;

        END IF;
    END PROCESS;

    PROCESS (tris_reg, port_reg, latch, abus_in, rd_en) --DBUS_OUT
    BEGIN

        IF ((abus_in = tris_addr OR abus_in = alt_tris_addr) AND rd_en = '1') THEN
            dbus_out <= tris_reg;

        ELSIF ((abus_in = port_addr OR abus_in = alt_port_addr) AND rd_en = '1') THEN
            dbus_out <= latch;
        ELSE
            dbus_out <= "ZZZZZZZZ";
        END IF;

    END PROCESS;

    latch <= port_io WHEN rd_en = '1';

    port_io(0) <= port_reg(0) WHEN tris_reg(0) = '0' ELSE
    'Z';
    port_io(1) <= port_reg(1) WHEN tris_reg(1) = '0' ELSE
    'Z';
    port_io(2) <= port_reg(2) WHEN tris_reg(2) = '0' ELSE
    'Z';
    port_io(3) <= port_reg(3) WHEN tris_reg(3) = '0' ELSE
    'Z';
    port_io(4) <= port_reg(4) WHEN tris_reg(4) = '0' ELSE
    'Z';
    port_io(5) <= port_reg(5) WHEN tris_reg(5) = '0' ELSE
    'Z';
    port_io(6) <= port_reg(6) WHEN tris_reg(6) = '0' ELSE
    'Z';
    port_io(7) <= port_reg(7) WHEN tris_reg(7) = '0' ELSE
    'Z';

END arch;
