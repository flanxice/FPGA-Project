LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY draw_map IS PORT (
    world_X, world_Y:       IN STD_LOGIC_VECTOR(8 downto 0);
    origin_X, origin_Y:     IN STD_LOGIC_VECTOR(8 downto 0);
    tile_num:				IN STD_LOGIC_VECTOR(2 downto 0);
    red, green, blue:       OUT STD_LOGIC
    );
END;

ARCHITECTURE draw_map OF draw_map IS
    SIGNAL sub_X, sub_Y: STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL tile_addr: STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL tile_data: STD_LOGIC_VECTOR(2 downto 0);
    
    SUBTYPE tile_pixel IS STD_LOGIC_VECTOR(2 downto 0);
    TYPE rom_type IS ARRAY(natural RANGE <>) OF tile_pixel;
    CONSTANT tile_rom: rom_type(0 TO 2047) :=
    (
		-- 0
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",

		-- 1
		"111", "111", "111", "111", "111", "111", "111", "000", "111", "111", "111", "111", "111", "111", "111", "000",
		"111", "110", "110", "110", "110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"111", "111", "111", "000", "111", "111", "111", "111", "111", "111", "111", "000", "111", "111", "111", "111",
		"110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110",
		"110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"111", "111", "111", "111", "111", "111", "111", "000", "111", "111", "111", "111", "111", "111", "111", "000",
		"111", "110", "110", "110", "110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"111", "111", "111", "000", "111", "111", "111", "111", "111", "111", "111", "000", "111", "111", "111", "111",
		"110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110",
		"110", "110", "111", "000", "111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",

		-- 2
		"111", "111", "111", "111", "111", "111", "111", "111", "000", "111", "111", "111", "111", "111", "111", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "000", "000", "000", "000", "000", "000", "000", "000",
		"111", "110", "110", "110", "110", "110", "110", "000", "111", "111", "111", "111", "111", "111", "111", "000",
		"111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "000",
		"111", "110", "110", "110", "110", "110", "110", "110", "000", "111", "110", "110", "110", "110", "110", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",

		-- 3
		"111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111",
		"111", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "001", "111",
		"111", "001", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "001", "111",
		"111", "001", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "001", "111",
		"111", "001", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "001", "111",
		"111", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "111",
		"111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111", "111",

		-- 4
		"100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100",
		"100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "100", "100",
		"100", "100", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "100", "100",
		"100", "100", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "100", "100",
		"100", "100", "000", "000", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "100", "100",
		"100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100",
		"100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100",

		-- 5
		"001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010",
		"010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100",
		"011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100",
		"011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101",
		"101", "110", "101", "110", "101", "110", "101", "110", "101", "110", "101", "110", "101", "110", "101", "110",
		"001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010", "001", "010",
		"010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100", "010", "100",
		"011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100", "011", "100",
		"011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101", "011", "101",
		"111", "110", "101", "100", "011", "010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111",
		"110", "101", "100", "011", "010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111",
		"101", "100", "011", "010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111", "110",
		"100", "011", "010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111", "110", "101",
		"011", "010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111", "110", "101", "100",
		"010", "001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111", "110", "101", "100", "011",
		"001", "000", "000", "001", "010", "011", "100", "101", "110", "111", "111", "110", "101", "100", "011", "010",

		-- 6
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "100", "100", "100", "100", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "100", "100", "100", "100", "111", "100", "100", "100", "000", "000", "000", "000",
		"000", "100", "100", "100", "100", "111", "111", "100", "100", "100", "100", "100", "100", "100", "100", "000",
		"100", "100", "111", "100", "100", "111", "100", "100", "100", "111", "100", "100", "111", "100", "100", "100",
		"100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100",
		"000", "000", "100", "100", "100", "100", "100", "111", "111", "100", "100", "100", "100", "100", "000", "000",
		"000", "000", "000", "000", "000", "000", "111", "111", "111", "111", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "111", "111", "111", "111", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "111", "111", "111", "111", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "000", "111", "111", "111", "111", "000", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "111", "111", "111", "111", "111", "111", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "111", "111", "111", "111", "111", "111", "000", "000", "000", "000", "000",
		"000", "000", "000", "000", "000", "111", "111", "111", "111", "111", "111", "000", "000", "000", "000", "000",

		-- 7
		"000", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "000",
		"110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000",
		"110", "110", "001", "110", "110", "110", "000", "000", "000", "000", "110", "110", "001", "110", "110", "000",
		"110", "110", "110", "110", "110", "000", "000", "110", "110", "000", "000", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "000", "000", "110", "110", "110", "000",
		"110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "000", "000", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "000", "000", "110", "110", "110", "110", "110", "110", "000",
		"110", "110", "001", "110", "110", "110", "110", "000", "000", "110", "110", "110", "001", "110", "110", "000",
		"110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000",
		"000", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "110", "000", "000",
		"000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000"
    );
BEGIN
    sub_X <= world_X(3 downto 0);
    sub_Y <= world_Y(3 downto 0);

    tile_addr <= tile_num & sub_Y & sub_X;
	tile_data <= tile_rom(to_integer(unsigned(tile_addr)));

    red <= tile_data(2);
    green <= tile_data(1);
    blue <= tile_data(0);
END draw_map;
