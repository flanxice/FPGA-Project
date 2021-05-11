LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY video_sync IS PORT (
	clock:								IN STD_LOGIC;
	video_on, Horiz_Sync, Vert_Sync:	OUT STD_LOGIC;
	H_count_out, V_count_out:			OUT STD_LOGIC_VECTOR(9 downto 0)
	);
END video_sync;

ARCHITECTURE sync OF video_sync IS
	SIGNAL H_count, V_count:			STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL video_on_H, video_on_V: 		STD_LOGIC;

	constant H_max : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(799,10); 
	constant V_max : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(524,10); 
BEGIN
	H_count_out <= H_count;
	V_count_out <= V_count;

	-- Video display code
	video_on <= video_on_h and video_on_v;

	VIDEO_DISPLAY: PROCESS
	BEGIN
		Wait UNTIL(Clock'Event) and (Clock='1');

		-- H_count counts pixels (640 + extra time for sync signals)
		--
		--   <-Clock out RGB Pixel Row Data ->   <-H Sync->
		--   ------------------------------------__________--------
		--   0                           640   659       755    799
		--
		IF (H_count >= H_max) THEN
			H_count <= "0000000000";
		ELSE
			H_count <= H_count + "0000000001";
		END IF;

		--Generate Horizontal Sync Signal
		IF (H_count <= CONV_STD_LOGIC_VECTOR(755,10)) and (H_count >= CONV_STD_LOGIC_VECTOR(659,10)) THEN
			Horiz_Sync <= '0';
		ELSE
			Horiz_Sync <= '1';
		END IF;

		--V_count counts rows of pixels (480 + extra time for sync signals)
		--
		--  <---- 480 Horizontal Syncs (pixel rows) -->  ->V Sync<-
		--  -----------------------------------------------_______------------
		--  0                                       480    493-494          524
		--
		IF (V_count >= V_max) and (H_count >= CONV_STD_LOGIC_VECTOR(699,10)) THEN
			V_count <= "0000000000";
		ELSE
			IF (H_count = CONV_STD_LOGIC_VECTOR(699,10)) THEN
				V_count <= V_count + "0000000001";
			END IF;

			-- Generate Vertical Sync Signal
			IF (V_count <= CONV_STD_LOGIC_VECTOR(494,10)) and (V_count >= CONV_STD_LOGIC_VECTOR(493,10)) THEN
				Vert_Sync <= '0';
			ELSE
				Vert_Sync <= '1';
			END IF;

			-- Generate Video on Screen Signals for Pixel Data
			IF (H_count <= CONV_STD_LOGIC_VECTOR(639,10)) THEN
				video_on_H <= '1';
			ELSE
				video_on_H <= '0';
			END IF;

			IF (V_count <= CONV_STD_LOGIC_VECTOR(479,10)) THEN
				video_on_V <= '1';
			ELSE
				video_on_V <= '0';
			END IF;
		END IF;
	END PROCESS VIDEO_DISPLAY;
END sync;
