-- Notes:
--      The video scanout logic is slow and needs to be synchronized.
--      Sprites in particular are crap.  I think that multiple sprites with the current implementation would
--      be unacceptably slow.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ss IS PORT (
    double_clock:           IN STD_LOGIC;
    red, green, blue:       OUT STD_LOGIC;
    horiz_sync, vert_sync:  OUT STD_LOGIC;

    pad_clock, pad_load:    OUT STD_LOGIC;
    pad_data:               IN STD_LOGIC
    );
END;

ARCHITECTURE ss OF ss IS
    COMPONENT Video_Sync
    PORT (
        clock:                              IN STD_LOGIC;
        video_on, Horiz_Sync, Vert_Sync:    OUT STD_LOGIC;
        H_count_out, V_count_out:           OUT STD_LOGIC_VECTOR(9 downto 0)
    );
    END COMPONENT;

    COMPONENT draw_map
    PORT (
        world_X, world_Y:       IN STD_LOGIC_VECTOR(8 downto 0);
        origin_X, origin_Y:     IN STD_LOGIC_VECTOR(8 downto 0);
        tile_num:               IN STD_LOGIC_VECTOR(2 downto 0);
        red, green, blue:       OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT draw_sprite
    PORT (
        world_X, world_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
        sprite_X, sprite_Y: IN STD_LOGIC_VECTOR(8 downto 0);
        active:             OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT map_rom
    PORT (
        clock:          IN STD_LOGIC;
        tile_X:         IN STD_LOGIC_VECTOR(4 downto 0);
        tile_Y:         IN STD_LOGIC_VECTOR(4 downto 0);
        data:           OUT STD_LOGIC_VECTOR(2 downto 0)
    );
    END COMPONENT;

    COMPONENT game
    PORT (
        clock, enable:              IN STD_LOGIC;
        pad_state:                  IN STD_LOGIC_VECTOR(7 downto 0);
        map_data:                   IN STD_LOGIC_VECTOR(2 downto 0);
        map_read_X, map_read_Y:     OUT STD_LOGIC_VECTOR(4 downto 0);
        out_player_X, out_player_Y: OUT STD_LOGIC_VECTOR(8 downto 0)
    );
    END COMPONENT;

    COMPONENT read_pad
    PORT (
        clock:              IN STD_LOGIC;
        pad_data:           IN STD_LOGIC;
        pad_clock:          OUT STD_LOGIC;
        pad_load:           OUT STD_LOGIC;
        pad_state:          OUT STD_LOGIC_VECTOR(7 downto 0)
    );
    END COMPONENT;

	SIGNAL clock:			STD_LOGIC;
    SIGNAL video_on:            STD_LOGIC;
    SIGNAL H_count, V_count:    STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL map_red, map_green, map_blue: STD_LOGIC;
    -- World position of upper left corner of screen
    SIGNAL origin_X, origin_Y: STD_LOGIC_VECTOR(8 downto 0);
    -- World position for current pixel
    SIGNAL world_X, world_Y: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL hsync, vsync: STD_LOGIC;
    SIGNAL player_X, player_Y: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL player_red, player_green, player_blue, player_out: STD_LOGIC;
    SIGNAL tile_X, tile_Y: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL map_data: STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL map_read_X, map_read_Y: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL coll_read_X, coll_read_Y: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL logic_enable: STD_LOGIC;
    SIGNAL pad_state: STD_LOGIC_VECTOR(7 downto 0);
BEGIN
    sync: Video_Sync PORT MAP (
        clock => clock,
        horiz_sync => hsync,
        vert_sync => vsync,
        video_on => video_on,
        H_count_out => H_count,
        V_count_out => V_count
    );

    horiz_sync <= hsync;
    vert_sync <= vsync;

	PROCESS
	BEGIN
		WAIT UNTIL double_clock'Event AND double_clock = '1';
		
		clock <= NOT clock;
	END PROCESS;

    PROCESS(vsync)
    BEGIN
        IF vsync'Event AND vsync = '0' THEN
			IF player_X < 160 THEN
				origin_X <= CONV_STD_LOGIC_VECTOR(0, 9);
			ELSIF player_X > 352 THEN
				origin_X <= CONV_STD_LOGIC_VECTOR(192, 9);
			ELSE
				origin_X <= player_X - CONV_STD_LOGIC_VECTOR(160, 9);
			END IF;
	
			IF player_Y < 100 THEN
				origin_Y <= CONV_STD_LOGIC_VECTOR(0, 9);
			ELSIF player_Y > 372 THEN
				origin_Y <= CONV_STD_LOGIC_VECTOR(272, 9);
			ELSE
				origin_Y <= player_Y - CONV_STD_LOGIC_VECTOR(100, 9);
			END IF;
		END IF;
    END PROCESS;

--    origin_X <= CONV_STD_LOGIC_VECTOR(0, 9);
--    origin_Y <= CONV_STD_LOGIC_VECTOR(0, 9);

    -- Location of current raster pixel
    world_X <= origin_X + H_count(9 downto 1);
    world_Y <= origin_Y + V_count(9 downto 1);

    tile_X <= world_X(8 downto 4);
    tile_Y <= world_Y(8 downto 4);

    dmap: draw_map PORT MAP (
        origin_X => origin_X,
        origin_Y => origin_Y,
        world_X => world_X,
        world_Y => world_Y,
        tile_num => map_data,
        red => map_red,
        green => map_green,
        blue => map_blue
    );

    player: draw_sprite PORT MAP (
        sprite_X => player_X,
        sprite_Y => player_Y,
        world_X => world_X,
        world_Y => world_Y,
        active => player_out
    );

    maprom: map_rom PORT MAP (
        clock => clock,
        tile_X => map_read_X,
        tile_Y => map_read_Y,
        data => map_data
    );

    game_logic: game PORT MAP (
        clock => clock,
        enable => logic_enable,
        map_data => map_data,
        map_read_X => coll_read_X,
        map_read_Y => coll_read_Y,
        out_player_X => player_X,
        out_player_Y => player_Y,
        pad_state => pad_state
    );

    pad: read_pad PORT MAP (
        clock => clock,
        pad_data => pad_data,
        pad_clock => pad_clock,
        pad_load => pad_load,
        pad_state => pad_state
    );

    logic_enable <= NOT vsync;

    map_read_X <= tile_X WHEN video_on = '1' ELSE coll_read_X;
    map_read_Y <= tile_Y WHEN video_on = '1' ELSE coll_read_Y;

    player_red <= '1';
    player_green <= '0';
    player_blue <= '0';

    PROCESS (clock)
    BEGIN
        IF clock'Event AND clock = '1' THEN
			IF video_on = '0' THEN
				red <= '0';
				green <= '0';
				blue <= '0';
			ELSE
				-- FIXME - This drops the max clock freq through the floor.
				--         Can't it be done faster?
				IF player_out = '1' THEN
					red <= player_red;
					green <= player_green;
					blue <= player_blue;
				ELSE
					red <= map_red;
					green <= map_green;
					blue <= map_blue;
				END IF;
			END IF;
		END IF;
    END PROCESS;
END ss;
