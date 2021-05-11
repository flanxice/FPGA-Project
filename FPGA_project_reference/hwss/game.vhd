-- Notes:
--       There is a special case in the collision detection logic.
--       Example:  The player is at (0, 0) with a block in tile (16, 16).  The player wants to move to (1, 1).
--          Both the X and Y collision tests pass (since there are no blocks along either axis of motion), but
--          the player will collide with a block in the new position.
--          The solution to this is to check X, Y, and the entire new position for collisions.
--          If the new position collides but X and Y do not, then the Y component of the move is dropped.
--          Either component can be dropped (since the two axis checks passed), but dropping the Y component
--          allows the player to move into one-tile gaps (since falling is always happening, this can be a common case).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY game IS PORT (
    clock, enable:              IN STD_LOGIC;
    pad_state:                  IN STD_LOGIC_VECTOR(7 downto 0);
    map_data:                   IN STD_LOGIC_VECTOR(2 downto 0);
    map_read_X, map_read_Y:     OUT STD_LOGIC_VECTOR(4 downto 0);
    out_player_X, out_player_Y: OUT STD_LOGIC_VECTOR(8 downto 0)
);
END;

ARCHITECTURE game OF game IS
    TYPE STATE_TYPE IS (IDLE, READ_PAD, GEN_DELTAS, COLL_START_X, COLL_DET_X, COLL_START_Y, COLL_DET_Y, COLL_START_XY, COLL_DET_XY, UPDATE, DONE);

    COMPONENT sw_coll_det PORT (
        clock, valid_in:        IN STD_LOGIC;
        sprite_X, sprite_Y:     IN STD_LOGIC_VECTOR(8 downto 0);
        map_data:               IN STD_LOGIC_VECTOR(2 downto 0);
        map_read_X, map_read_Y: OUT STD_LOGIC_VECTOR(4 downto 0);
        collision:              OUT STD_LOGIC;
        valid_out:              OUT STD_LOGIC
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

    SIGNAL state: STATE_TYPE;
    SIGNAL move_left, move_right, jump: STD_LOGIC;
    SIGNAL move_side: STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL coll_X, coll_Y: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL player_X, player_Y: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL player_dX, player_dY: STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL player_coll_X, player_coll_Y, player_coll_XY: STD_LOGIC;
    SIGNAL coll_start, coll_valid, coll_result: STD_LOGIC;
    SIGNAL hit_ground, allow_jump, falling: STD_LOGIC;
    SIGNAL jump_count: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL reset_game: STD_LOGIC;
BEGIN
    PROCESS (clock)
    BEGIN
        IF clock'Event AND clock = '1' THEN

        IF enable = '0' THEN
            state <= IDLE;
        ELSE
            CASE state IS
                WHEN IDLE =>
                    IF enable = '1' THEN
                        state <= READ_PAD;
                    END IF;
                WHEN READ_PAD =>
                    -- FIXME - Read from pad
                    jump <= pad_state(7) OR pad_state(6);
                    move_left <= pad_state(1);
                    move_right <= pad_state(0);
                    reset_game <= pad_state(4) AND pad_state(5);
                    state <= GEN_DELTAS;
                WHEN GEN_DELTAS =>
                    IF move_left /= move_right THEN
                        IF move_left = '1' THEN
                            IF player_X /= "000000000" THEN
                                player_dX <= "111111111";
                            ELSE
                                player_dX <= "000000000";
                            END IF;
                        ELSIF move_right = '1' THEN
                            IF player_X /= "111101111" THEN
                                player_dX <= "000000001";
                            ELSE
                                player_dX <= "000000000";
                            END IF;
                        END IF;
                    ELSIF move_left = '0' AND move_right = '0' THEN
                        player_dX <= "000000000";
                    END IF;

                    IF jump = '1' AND allow_jump = '1' THEN
                        -- Start jump
                        allow_jump <= '0';
                        hit_ground <= '0';
                        jump_count <= "00001";
                        IF player_Y = "000000000" THEN
                            -- Hit top of world
                            player_dY <= "000000001";
                            falling <= '1';
                        ELSE
                            player_dY <= "111111111";
                            falling <= '0';
                        END IF;
                    ELSIF jump_count /= "00000" THEN
                        IF hit_ground = '1' THEN
                            -- Hit something, so stop the jump
                            jump_count <= "00000";
                            player_dY <= "000000001";
                            falling <= '1';
                            -- FIXME: You can bounce along the ceiling.  Require hit_ground when falling to enable jump.
                        ELSE
                            -- Continue jump
                            IF player_Y = "000000000" THEN
                                -- Hit top of world
                                player_dY <= "000000001";
                                falling <= '1';
                            ELSE
                                player_dY <= "111111111";
                                falling <= '0';
                            END IF;

                            -- When jump_count overflows to "00000", the jump will end.
                            jump_count <= jump_count + "00001";
                        END IF;
                    ELSE
                        -- Not jumping, so try to fall
                        player_dY <= "000000001";
                        falling <= '1';
                    END IF;
                    state <= COLL_START_X;
                WHEN COLL_START_X =>
                    coll_start <= '1';
                    coll_X <= player_X + player_dX;
                    coll_Y <= player_Y;
                    state <= COLL_DET_X;
                WHEN COLL_DET_X =>
                    coll_start <= '0';
                    IF coll_valid = '1' THEN
                        state <= COLL_START_Y;
                        player_coll_X <= coll_result;
                    END IF;
                WHEN COLL_START_Y =>
                    coll_start <= '1';
                    coll_X <= player_X;
                    coll_Y <= player_Y + player_dY;
                    state <= COLL_DET_Y;
                WHEN COLL_DET_Y =>
                    coll_start <= '0';
                    IF coll_valid = '1' THEN
                        state <= COLL_START_XY;
                        player_coll_Y <= coll_result;
                        IF coll_result = '1' THEN
                            hit_ground <= '1';
                            IF falling = '1' THEN
                                allow_jump <= '1';
                            END IF;
                        END IF;
                    END IF;
                WHEN COLL_START_XY =>
                    coll_start <= '1';
                    coll_X <= player_X + player_dX;
                    coll_Y <= player_Y + player_dY;
                    state <= COLL_DET_XY;
                WHEN COLL_DET_XY =>
                    coll_start <= '0';
                    IF coll_valid = '1' THEN
                        state <= UPDATE;
                        player_coll_XY <= coll_result;
                    END IF;
                WHEN UPDATE =>
                    IF reset_game = '1' THEN
                        player_X <= "000000000";
                        player_Y <= "000000000";
                    ELSIF player_coll_XY = '1' AND player_coll_X = '0' AND player_coll_Y = '0' THEN
                        -- Special case: movement along neither axis is blocked, but the total move is blocked.
                        -- Prefer the X axis in this case.
                        player_X <= player_X + player_dX;
                    ELSE
                        -- Normal collision handling: drop whichever component(s) of the move are blocked
                        IF player_coll_X = '0' THEN
                            player_X <= player_X + player_dX;
                        END IF;
                        IF player_coll_Y = '0' THEN
                            player_Y <= player_Y + player_dY;
                        END IF;
                    END IF;
                    state <= DONE;
                WHEN DONE =>
                    IF enable = '0' THEN
                        state <= IDLE;
                    END IF;
            END CASE;
        END IF;
        
        END IF;
    END PROCESS;

    coll_det: sw_coll_det PORT MAP (
        clock => clock,
        sprite_X => coll_X,
        sprite_Y => coll_Y,
        valid_in => coll_start,
        valid_out => coll_valid,
        map_data => map_data,
        map_read_X => map_read_X,
        map_read_Y => map_read_Y,
        collision => coll_result
    );

    move_side <= move_left & move_right;
    out_player_X <= player_X;
    out_player_Y <= player_Y;
END game;