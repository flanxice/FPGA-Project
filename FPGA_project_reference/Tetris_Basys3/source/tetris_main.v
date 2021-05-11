`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:06:37 11/27/2014 
// Design Name: 
// Module Name:    tetris_main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tetris_main(clk, Btn_Left, Btn_Right, Btn_Down, Btn_Spin, GridS, GridA, Score);
	
	reg [199:0] Grid_Settled;
	reg [229:0] Grid_Active;
	
	input clk, Btn_Left, Btn_Right, Btn_Down, Btn_Spin;
	output wire [199:0] GridS;
	output wire [199:0] GridA;
	output reg [12:0] Score;
	
	assign GridS = Grid_Settled[199:0];
	assign GridA = Grid_Active[229:30];
	/***********************************************
	 * Initial Grids
	 ***********************************************/
	parameter START_SCREEN_SETTLED = 200'b0;
	parameter GAMEOVER_SCREEN_SETTLED = 200'b0;

	parameter ROW_MASK = 10'b11111_11111;
	parameter BEGINNING_SA = 8'd213;
	
	/***********************************************
	 * Piece States and Data
	 ***********************************************/
	parameter PS_None = 0,
			  PS_O_1 =  1,
			  PS_I_1 =  2,
			  PS_I_2 =  3,
			  PS_S_1 =  4,
			  PS_S_2 =  5,
			  PS_Z_1 =  6,
			  PS_Z_2 =  7,
			  PS_L_1 =  8,
			  PS_L_2 =  9,
			  PS_L_3 = 10,
			  PS_L_4 = 11,
			  PS_J_1 = 12,
			  PS_J_2 = 13,
			  PS_J_3 = 14,
			  PS_J_4 = 15,
			  PS_T_1 = 16,
			  PS_T_2 = 17,
			  PS_T_3 = 18,
			  PS_T_4 = 19;
			  
	parameter PSd_O_1 = 16'b0110_0110_0000_0000,
			  PSd_I_1 = 16'b0100_0100_0100_0100,
			  PSd_I_2 = 16'b0000_1111_0000_0000,
			  PSd_S_1 = 16'b0000_0110_1100_0000,
			  PSd_S_2 = 16'b0100_0110_0010_0000,
			  PSd_Z_1 = 16'b0000_1100_0110_0000,
			  PSd_Z_2 = 16'b0100_1100_1000_0000,
			  PSd_L_1 = 16'b0100_0100_0110_0000,
			  PSd_L_2 = 16'b0000_1110_1000_0000,
			  PSd_L_3 = 16'b0110_0010_0010_0000,
			  PSd_L_4 = 16'b0010_1110_0000_0000,
			  PSd_J_1 = 16'b0100_0100_1100_0000,
			  PSd_J_2 = 16'b1000_1110_0000_0000,
			  PSd_J_3 = 16'b0110_0100_0100_0000,
			  PSd_J_4 = 16'b0000_1110_0010_0000,
			  PSd_T_1 = 16'b0100_1110_0000_0000,
			  PSd_T_2 = 16'b0100_1100_0100_0000,
			  PSd_T_3 = 16'b0000_1110_0100_0000,
			  PSd_T_4 = 16'b0100_0110_0100_0000;
	
	
	/***********************************************
	 * Game States
	 ***********************************************/
	parameter S_Start = 0, 				// The very first state - wait for user to start a new game
			  S_Initialize = 1,			// this state initializes a new game
			  S_GenerateNewPiece = 2,	// Generate a new active piece
			  S_Idle = 3,				// main game state. Accepts tick event or user input
			  S_MoveLeft = 4,			// increments active piece shift amount 
			  S_MoveRight = 5,			// decrements active piece shift amount
			  S_Spin = 6,				// spins piece by changing Active Piece PS
			  S_SpinCorrection = 7,		// Corrects active piece position after rotating piece
			  S_Wait = 8,				// just a wait state for debouncing input
			  S_Tick = 9,				// process a game tick (check for piece settling/dropping piece 1 row)
			  S_CleanFullRows = 10,		// clean all the complete rows
			  S_CleanEmptyRows = 11,	// remove empty rows and shift floating rows down
			  S_CheckLoss = 12,			// Check if the user has lost
			  S_GameOver = 13;			// Game over state - stop and wait for user to start new game
	
	reg [199:0] Grid_Mask;
	
	// these wires are used for easily checking the position of the active piece
	wire Column_Left = Grid_Active[229] | Grid_Active[219] | Grid_Active[209] | Grid_Active[199] | Grid_Active[189]
					 | Grid_Active[179] | Grid_Active[169] | Grid_Active[159] | Grid_Active[149] | Grid_Active[139]
					 | Grid_Active[129] | Grid_Active[119] | Grid_Active[109] | Grid_Active[099] | Grid_Active[089]
					 | Grid_Active[079] | Grid_Active[069] | Grid_Active[059] | Grid_Active[049] | Grid_Active[039]
					 | Grid_Active[029] | Grid_Active[019] | Grid_Active[009];

	wire Column_Left2 = Grid_Active[228] | Grid_Active[218] | Grid_Active[208] | Grid_Active[198] | Grid_Active[188]
					  | Grid_Active[178] | Grid_Active[168] | Grid_Active[158] | Grid_Active[148] | Grid_Active[138]
					  | Grid_Active[128] | Grid_Active[118] | Grid_Active[108] | Grid_Active[098] | Grid_Active[088]
					  | Grid_Active[078] | Grid_Active[068] | Grid_Active[058] | Grid_Active[048] | Grid_Active[038]
					  | Grid_Active[028] | Grid_Active[018] | Grid_Active[008];
			
	wire Column_Right = Grid_Active[220] | Grid_Active[210] | Grid_Active[200] | Grid_Active[190] | Grid_Active[180]
					  | Grid_Active[170] | Grid_Active[160] | Grid_Active[150] | Grid_Active[140] | Grid_Active[130]
					  | Grid_Active[120] | Grid_Active[110] | Grid_Active[100] | Grid_Active[090] | Grid_Active[080]
					  | Grid_Active[070] | Grid_Active[060] | Grid_Active[050] | Grid_Active[040] | Grid_Active[030]
					  | Grid_Active[020] | Grid_Active[010] | Grid_Active[000];
	
	wire Column_Right2 = Grid_Active[221] | Grid_Active[211] | Grid_Active[201] | Grid_Active[191] | Grid_Active[181]
					   | Grid_Active[171] | Grid_Active[161] | Grid_Active[151] | Grid_Active[141] | Grid_Active[131]
					   | Grid_Active[121] | Grid_Active[111] | Grid_Active[101] | Grid_Active[091] | Grid_Active[081]
					   | Grid_Active[071] | Grid_Active[061] | Grid_Active[051] | Grid_Active[041] | Grid_Active[031]
					   | Grid_Active[021] | Grid_Active[011] | Grid_Active[001];
			
	reg [4:0] AP_State_PS; // piece state
	reg [15:0] AP_State_PSd; // piece state data
	reg [7:0] AP_State_SA; // shift amount
	
	reg [4:0] Game_State;
	reg [21:0] Game_State_Counter;
	reg [2:0] Row_Elim_Counter;
	
	reg [28:0] Game_Clock_Counter;
	reg [13:0] Game_Clock_Acc;
	wire Game_Tick = Game_Clock_Counter[28];
	reg [1:0] clk2_Counter;
	wire clk2 = clk2_Counter[1];
	
	reg [2:0] Random_Counter;
	
	always @(posedge clk) begin
		clk2_Counter <= clk2_Counter + 1'b1;
	end
	
	always @(posedge clk2) begin
		if (Random_Counter == 3'b110)
			Random_Counter <= 3'b0;
		else
			Random_Counter <= Random_Counter + 1'b1;
	end
	
	/***********************************************
	 * Adjust game speed based on score
	 ***********************************************/
	 always @(posedge clk2) begin
		if (Score < 13'd100)		Game_Clock_Acc <= 5;
		else if (Score < 13'd200)	Game_Clock_Acc <= 10;
		else if (Score < 13'd300)	Game_Clock_Acc <= 20;
		else if (Score < 13'd400)	Game_Clock_Acc <= 40;
		else if (Score < 13'd500)	Game_Clock_Acc <= 80;
		else if (Score < 13'd600)	Game_Clock_Acc <= 160;
		else if (Score < 13'd700)	Game_Clock_Acc <= 320;
		else if (Score < 13'd800)	Game_Clock_Acc <= 640;
		else if (Score < 13'd900)	Game_Clock_Acc <= 1280;
		else					Game_Clock_Acc <= 2560;
	end
	
	/***********************************************
	 * Generate Active Piece Grid based on AP_State
	 ***********************************************/
	always @(posedge clk2) begin
		case (AP_State_PS)
			PS_O_1: AP_State_PSd <= PSd_O_1;
			PS_I_1: AP_State_PSd <= PSd_I_1;
			PS_I_2: AP_State_PSd <= PSd_I_2;
			PS_S_1: AP_State_PSd <= PSd_S_1;
			PS_S_2: AP_State_PSd <= PSd_S_2;
			PS_Z_1: AP_State_PSd <= PSd_Z_1;
			PS_Z_2: AP_State_PSd <= PSd_Z_2;
			PS_L_1: AP_State_PSd <= PSd_L_1;
			PS_L_2: AP_State_PSd <= PSd_L_2;
			PS_L_3: AP_State_PSd <= PSd_L_3;
			PS_L_4: AP_State_PSd <= PSd_L_4;
			PS_J_1: AP_State_PSd <= PSd_J_1;
			PS_J_2: AP_State_PSd <= PSd_J_2;
			PS_J_3: AP_State_PSd <= PSd_J_3;
			PS_J_4: AP_State_PSd <= PSd_J_4;
			PS_T_1: AP_State_PSd <= PSd_T_1;
			PS_T_2: AP_State_PSd <= PSd_T_2;
			PS_T_3: AP_State_PSd <= PSd_T_3;
			PS_T_4: AP_State_PSd <= PSd_T_4;
			default: AP_State_PSd <= 16'b0;
		endcase
	end

	always @(posedge clk2) begin
		Grid_Active <= 230'b0 + (AP_State_PSd[15:12] << (AP_State_SA + 30))
					+ (AP_State_PSd[11:8] << (AP_State_SA + 20))
					+ (AP_State_PSd[7:4] << (AP_State_SA + 10))
					+ (AP_State_PSd[3:0] << (AP_State_SA));
	end
	
	/***********************************************
	 * Game Clock
	 ***********************************************/
	always @(posedge clk2) begin
		if (Game_State == S_Idle)
			Game_Clock_Counter <= Game_Clock_Counter[27:0] + Game_Clock_Acc;
		else if (Game_State == S_Spin)
			Game_Clock_Counter <= 0;
	end

	/***********************************************
	 * Main game state machine
	 ***********************************************/
	always @(posedge clk2) begin
		case (Game_State)
			S_Start: begin
				Grid_Settled <= START_SCREEN_SETTLED;
				if (Btn_Spin) begin
					Game_State_Counter <= 1'b0;
					Game_State <= S_Initialize;
				end
			end
			S_Initialize: begin
				Score <= 13'd0;
				Grid_Settled <= 200'b0;
				Game_State_Counter <= 1'b0;
				Game_State <= S_GenerateNewPiece;
			end
			S_GenerateNewPiece: begin
				if (Game_State_Counter == 0) begin
					case (Random_Counter)
						0: AP_State_PS <= PS_O_1;
						1: AP_State_PS <= PS_I_1;
						2: AP_State_PS <= PS_S_1;
						3: AP_State_PS <= PS_Z_1;
						4: AP_State_PS <= PS_L_1;
						5: AP_State_PS <= PS_J_1;
						default: AP_State_PS <= PS_T_1;
					endcase
					AP_State_SA <= BEGINNING_SA;
				end
				if (Game_State_Counter < 2) // wait a few clock cycles for changes to AP_State_* to propogate
					Game_State_Counter <= Game_State_Counter + 1'b1;
				else begin
					Game_State_Counter <= 1'b0;
					Game_State <= S_Idle;
				end
			end
			S_Idle: begin
				if (Btn_Spin) begin
					Game_State_Counter <= 1'b0;
					Game_State <= S_Spin;
				end
				else if (Btn_Left) begin
					if ((Column_Left == 0) && (({1'b0,Grid_Settled[199:1]} & Grid_Active[229:30]) == 0))
						Game_State <= S_MoveLeft;
				end
				else if (Btn_Right) begin
					if ((Column_Right == 0) && (({Grid_Settled[198:0],1'b0} & Grid_Active[229:30]) == 0))
						Game_State <= S_MoveRight;
				end
				else if (Game_Tick || Btn_Down) begin
					Game_State_Counter <= 1'b0;
					Game_State <= S_Tick;
				end
			end
			S_MoveLeft: begin
				AP_State_SA <= AP_State_SA + 1'b1;
				Game_State_Counter <= 1;
				Game_State <= S_Wait;
			end
			S_MoveRight: begin
				AP_State_SA <= AP_State_SA - 1'b1;
				Game_State_Counter <= 1;
				Game_State <= S_Wait;
			end
			S_Spin: begin
				if (Game_State_Counter == 0) begin
					case (AP_State_PS)
						PS_O_1: AP_State_PS <= PS_O_1;
						PS_I_1: AP_State_PS <= PS_I_2;
						PS_I_2: AP_State_PS <= PS_I_1;
						PS_S_1: AP_State_PS <= PS_S_2;
						PS_S_2: AP_State_PS <= PS_S_1;
						PS_Z_1: AP_State_PS <= PS_Z_2;
						PS_Z_2: AP_State_PS <= PS_Z_1;
						PS_L_1: AP_State_PS <= PS_L_2;
						PS_L_2: AP_State_PS <= PS_L_3;
						PS_L_3: AP_State_PS <= PS_L_4;
						PS_L_4: AP_State_PS <= PS_L_1;
						PS_J_1: AP_State_PS <= PS_J_2;
						PS_J_2: AP_State_PS <= PS_J_3;
						PS_J_3: AP_State_PS <= PS_J_4;
						PS_J_4: AP_State_PS <= PS_J_1;
						PS_T_1: AP_State_PS <= PS_T_2;
						PS_T_2: AP_State_PS <= PS_T_3;
						PS_T_3: AP_State_PS <= PS_T_4;
						PS_T_4: AP_State_PS <= PS_T_1;
						default: AP_State_PS <= PS_None;
					endcase
				end
				
				if (Game_State_Counter < 3)
					Game_State_Counter <= Game_State_Counter + 1'b1;
				else begin
					Game_State_Counter <= 1'b0;
					Game_State <= S_SpinCorrection;
				end
			end
			S_SpinCorrection: begin
				Game_State_Counter <= Game_State_Counter + 1'b1;
				// only execute the shift every other clock cycles. changes to AP_State_SA take a
				// cycle to propagate into Grid_Active (ie Column_Left, Column_Right, etc)
				if (Game_State_Counter[0] == 0) begin
					// check for shift amount dividing active piece into 2 (piece in both left most column and right most column)
					if (Column_Left && Column_Right) begin
						if (Column_Left2 && Column_Right2) // this only happens when rotating a vertical I shape when tight against right wall
							AP_State_SA <= AP_State_SA + 2'd2;
						else if (Column_Left2 == 0)
							AP_State_SA <= AP_State_SA + 1'b1;
						else if (Column_Right2 == 0)
							AP_State_SA <= AP_State_SA - 1'b1;
					end
					// check if the shifting left/right caused any overlap, if it does, move piece up one line
					else if ((Grid_Active[229:30] & Grid_Settled) != 0) begin
						AP_State_SA <= AP_State_SA + 4'd10;
					end
					else begin
						// after looping through a number of clock cycles and fixing all errors, move to next state
						Game_State_Counter <= 1;
						Game_State <= S_Wait;
					end
				end				
			end
			S_Wait: begin
				if (Game_State_Counter != 0)
					Game_State_Counter <= Game_State_Counter + 1'b1;
				else Game_State <= S_Idle;
			end
			S_Tick: begin
				if (Grid_Active[39:30] > 0 || (Grid_Settled[189:0] & Grid_Active[229:40]) > 0) begin
					Grid_Settled <= Grid_Settled | Grid_Active[229:30];
					Game_State <= S_CleanFullRows;
					Game_State_Counter <= 16'b0;
				end
				else begin
					AP_State_SA <= AP_State_SA - 4'd10;
					Game_State_Counter <= 1'b1;
					Game_State <= S_Wait;
				end
			end
			S_CleanFullRows: begin
				if (Game_State_Counter == 0) begin
					Grid_Mask <= {ROW_MASK,190'b0};
					Row_Elim_Counter <= 3'b0;
				end
				else begin
					if ( Grid_Mask != 0 &&(Grid_Mask & Grid_Settled) == Grid_Mask) begin
						Grid_Settled <= Grid_Settled ^ Grid_Mask;
						Row_Elim_Counter <= Row_Elim_Counter + 1'b1;
					end
					Grid_Mask <= Grid_Mask >> 10;
				end
			
				if (Game_State_Counter > 21) begin
					case (Row_Elim_Counter)
						3'b000: Score <= Score;
						3'b001: Score <= Score + 13'd5;
						3'b010: Score <= Score + 13'd15;
						3'b011: Score <= Score + 13'd25;
						3'b100: Score <= Score + 13'd40;
						default: Score <= Score;
					endcase
					Game_State_Counter <= 16'b0;
					Game_State <= S_CleanEmptyRows;
				end
				else
					Game_State_Counter <= Game_State_Counter + 1'b1;
			end
			S_CleanEmptyRows: begin
				Game_State_Counter <= Game_State_Counter + 1'b1;
				case (Game_State_Counter)
					 0: if (Grid_Settled[189:180] == 0) Grid_Settled <= (Grid_Settled[199:190] << 180) + Grid_Settled[179:0];
					 1: if (Grid_Settled[179:170] == 0) Grid_Settled <= (Grid_Settled[199:180] << 170) + Grid_Settled[169:0];
					 2: if (Grid_Settled[169:160] == 0) Grid_Settled <= (Grid_Settled[199:170] << 160) + Grid_Settled[159:0];
					 3: if (Grid_Settled[159:150] == 0) Grid_Settled <= (Grid_Settled[199:160] << 150) + Grid_Settled[149:0];
					 4: if (Grid_Settled[149:140] == 0) Grid_Settled <= (Grid_Settled[199:150] << 140) + Grid_Settled[139:0];
					 5: if (Grid_Settled[139:130] == 0) Grid_Settled <= (Grid_Settled[199:140] << 130) + Grid_Settled[129:0];
					 6: if (Grid_Settled[129:120] == 0) Grid_Settled <= (Grid_Settled[199:130] << 120) + Grid_Settled[119:0];
					 7: if (Grid_Settled[119:110] == 0) Grid_Settled <= (Grid_Settled[199:120] << 110) + Grid_Settled[109:0];
					 8: if (Grid_Settled[109:100] == 0) Grid_Settled <= (Grid_Settled[199:110] << 100) + Grid_Settled[099:0];
					 9: if (Grid_Settled[099:090] == 0) Grid_Settled <= (Grid_Settled[199:100] <<  90) + Grid_Settled[089:0];
					10: if (Grid_Settled[089:080] == 0) Grid_Settled <= (Grid_Settled[199:090] <<  80) + Grid_Settled[079:0];
					11: if (Grid_Settled[079:070] == 0) Grid_Settled <= (Grid_Settled[199:080] <<  70) + Grid_Settled[069:0];
					12: if (Grid_Settled[069:060] == 0) Grid_Settled <= (Grid_Settled[199:070] <<  60) + Grid_Settled[059:0];
					13: if (Grid_Settled[059:050] == 0) Grid_Settled <= (Grid_Settled[199:060] <<  50) + Grid_Settled[049:0];
					14: if (Grid_Settled[049:040] == 0) Grid_Settled <= (Grid_Settled[199:050] <<  40) + Grid_Settled[039:0];
					15: if (Grid_Settled[039:030] == 0) Grid_Settled <= (Grid_Settled[199:040] <<  30) + Grid_Settled[029:0];
					16: if (Grid_Settled[029:020] == 0) Grid_Settled <= (Grid_Settled[199:030] <<  20) + Grid_Settled[019:0];
					17: if (Grid_Settled[019:010] == 0) Grid_Settled <= (Grid_Settled[199:020] <<  10) + Grid_Settled[009:0];
					18: if (Grid_Settled[009:000] == 0) Grid_Settled <= (Grid_Settled[199:010]);
				endcase
				if (Game_State_Counter < 18)
					Game_State_Counter <= Game_State_Counter + 1'b1;
				else begin
					Game_State_Counter <= 16'b0;
					Game_State <= S_CheckLoss;
				end
			end
			S_CheckLoss: begin
				if (Grid_Settled[199:190] > 0)
					Game_State <= S_GameOver;
				else begin
					// generate a new piece and continue game
					Game_State <= S_GenerateNewPiece;
					Game_State_Counter <= 0;
				end
			end
			S_GameOver: begin
				if (Game_State_Counter != 0)
					Game_State_Counter <= Game_State_Counter + 1'b1;
				else if (Btn_Spin)
					Game_State <= S_Initialize;
			end
			default: Game_State <= S_Start;
		endcase
	end

endmodule
