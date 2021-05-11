LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY game_test IS PORT (
    clock, enable:                  IN STD_LOGIC;
    player_X, player_Y:             OUT STD_LOGIC_VECTOR(8 downto 0)
);
END;

ARCHITECTURE game_test OF game_test IS
    COMPONENT map_rom
    PORT (
        clock:                      IN STD_LOGIC;
        tile_X:                     IN STD_LOGIC_VECTOR(4 downto 0);
        tile_Y:                     IN STD_LOGIC_VECTOR(4 downto 0);
        data:                       OUT STD_LOGIC_VECTOR(2 downto 0)
    );
    END COMPONENT;

    COMPONENT game
    PORT (
        clock, enable:              IN STD_LOGIC;
        map_data:                   IN STD_LOGIC_VECTOR(2 downto 0);
        map_read_X, map_read_Y:     OUT STD_LOGIC_VECTOR(4 downto 0);
        out_player_X, out_player_Y: OUT STD_LOGIC_VECTOR(8 downto 0)
    );
    END COMPONENT;

    SIGNAL map_read_X, map_read_Y: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL map_data: STD_LOGIC_VECTOR(2 downto 0);
BEGIN
    maprom: map_rom PORT MAP (
        clock => clock,
        tile_X => map_read_X,
        tile_Y => map_read_Y,
        data => map_data
    );

    game_logic: game PORT MAP (
        clock => clock,
        enable => enable,
        map_data => map_data,
        map_read_X => map_read_X,
        map_read_Y => map_read_Y,
        out_player_X => player_X,
        out_player_Y => player_Y
    );
END game_test;