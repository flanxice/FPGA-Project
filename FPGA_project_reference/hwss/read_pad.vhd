LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY read_pad IS PORT (
    clock:              IN STD_LOGIC;
    pad_data:           IN STD_LOGIC;
    pad_clock:          OUT STD_LOGIC;
    pad_load:           OUT STD_LOGIC;
    pad_state:          OUT STD_LOGIC_VECTOR(7 downto 0)
);
END;

ARCHITECTURE read_pad OF read_pad IS
    SIGNAL ser_clock: STD_LOGIC;
    SIGNAL div_count: STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL data: STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL bit_num: STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL done: STD_LOGIC;
BEGIN
    PROCESS (clock)
    BEGIN
        IF clock'Event AND clock = '1' THEN
			div_count <= div_count + "0001";
			IF div_count = "0000" THEN
				ser_clock <= '1';
	
				IF bit_num = "000" THEN
					pad_load <= '0';
				END IF;
			ELSIF div_count = "1000" THEN
				ser_clock <= '0';
	
				-- Falling edge of ser_clock
				pad_load <= '1';
				data(7 downto 1) <= data(6 downto 0);
				data(0) <= pad_data;
				IF bit_num = "111" THEN
					pad_state <= data(6 downto 0) & pad_data;
				END IF;
				bit_num <= bit_num + "001";
			END IF;
		END IF;
    END PROCESS;

    pad_clock <= ser_clock;
--    pad_state <= "00000000";
END read_pad;