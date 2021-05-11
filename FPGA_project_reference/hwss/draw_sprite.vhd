LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY draw_sprite IS PORT (
    world_X, world_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
    sprite_X, sprite_Y: IN STD_LOGIC_VECTOR(8 downto 0);
    active:             OUT STD_LOGIC
    );
END;

ARCHITECTURE draw_sprite OF draw_sprite IS
    SIGNAL in_x, in_y: STD_LOGIC;
    SIGNAL sprite_x2, sprite_y2: STD_LOGIC_VECTOR(8 downto 0);
BEGIN
    -- FIXME - Pipeline and register this for speed

    sprite_x2 <= sprite_x + CONV_STD_LOGIC_VECTOR(16, 9);
    sprite_y2 <= sprite_y + CONV_STD_LOGIC_VECTOR(16, 9);

    in_x <= '1' WHEN world_x >= sprite_x AND world_x <= sprite_x2 ELSE '0';
    in_y <= '1' WHEN world_y >= sprite_y AND world_y <= sprite_y2 ELSE '0';

    active <= in_x AND in_y;
END draw_sprite;
