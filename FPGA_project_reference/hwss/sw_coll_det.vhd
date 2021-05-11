-- Sprite-world collision detection
--
-- This module is pipelined with 3 pipeline stages.
-- A collision detection requires 4 pipeline cycles (7 clock cycles).
-- valid_in should go high when sprite_X, sprite_Y, and sprite_num are meaningful.
-- valid_out is high when a complete collision result is available.
-- sprite_num_out indicates the value of sprite_num_in for which collision is valid.
--
-- Typical usage:
--     Caller connects map_addr and map_data to registered lpm_rom.
--     Caller sets valid_in, sprite_X, sprite_Y, and sprite_num.
--     When valid_out is high, caller uses result in collision for sprite sprite_num_out.
--
-- Pipeline stages:
-- Stage 0: Generate map_addr
-- Stage 1: Map memory fetch
-- Stage 2: Generate collision result
--
-- valid_in acts like a synchronous reset.  Only assert it to begin a detection.
-- Asserting valid_in while a collision detection is in progress will abort the current
-- collision detection.
--
-- sprite_X and sprite_Y must be stable until valid_out is asserted.
--
-- Caller is expected to provide registered (1-cycle) ROM for map data.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY sw_coll_det IS PORT (
        clock, valid_in:        IN STD_LOGIC;
        sprite_X, sprite_Y:     IN STD_LOGIC_VECTOR(8 downto 0);
        map_data:               IN STD_LOGIC_VECTOR(2 downto 0);
        map_read_X, map_read_Y: OUT STD_LOGIC_VECTOR(4 downto 0);
        collision:              OUT STD_LOGIC;
        valid_out:              OUT STD_LOGIC
    );
END;

ARCHITECTURE sw_coll_det OF sw_coll_det IS
    TYPE CHECK_TYPE IS (check_IDLE, check_UL, check_UR, check_LL, check_LR);

    SIGNAL read_X, read_Y: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL check: CHECK_TYPE;
    SIGNAL result: STD_LOGIC;
    SIGNAl valid_0, valid_1, valid_2: STD_LOGIC;
BEGIN
    PROCESS (clock)
    BEGIN
        IF clock'Event AND clock = '1' THEN

        IF valid_in = '1' THEN
            valid_2 <= '0';
            check <= check_UL;
            result <= '0';
            valid_0 <= '0';
            read_X <= CONV_STD_LOGIC_VECTOR(0, 9);
            read_Y <= CONV_STD_LOGIC_VECTOR(0, 9);
        ELSIF valid_2 = '1' THEN
            valid_2 <= '0';
        ELSE
            -- Stage 0: Generate map_addr
            CASE check IS
                WHEN check_IDLE =>
                    read_X <= CONV_STD_LOGIC_VECTOR(0, 9);
                    read_Y <= CONV_STD_LOGIC_VECTOR(0, 9);
                    valid_0 <= '0';
                WHEN check_UL =>
                    read_X <= sprite_X;
                    read_Y <= sprite_Y;
                    valid_0 <= '0';
                    check <= check_UR;
                WHEN check_UR =>
                    read_X <= sprite_X + CONV_STD_LOGIC_VECTOR(15, 9);
                    read_Y <= sprite_Y;
                    valid_0 <= '0';
                    check <= check_LL;
                WHEN check_LL =>
                    read_X <= sprite_X;
                    read_Y <= sprite_Y + CONV_STD_LOGIC_VECTOR(15, 9);
                    valid_0 <= '0';
                    check <= check_LR;
                WHEN check_LR =>
                    read_X <= sprite_X + CONV_STD_LOGIC_VECTOR(15, 9);
                    read_Y <= sprite_Y + CONV_STD_LOGIC_VECTOR(15, 9);
                    valid_0 <= '1';
                    check <= check_IDLE;
            END CASE;

            -- Stage 1: Map memory fetch
            -- Handled by registered ROM in caller
            valid_1 <= valid_0;

            -- Stage 2: Generate collision result
            IF map_data /= "000" THEN
                result <= '1';
            END IF;
            valid_2 <= valid_1;
        END IF;
        
        END IF;
    END PROCESS;

    map_read_X <= read_X(8 downto 4);
    map_read_Y <= read_Y(8 downto 4);
    valid_out <= valid_2;
    collision <= result;
END sw_coll_det;