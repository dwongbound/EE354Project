`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:18:00 12/14/2017 
// Design Name: 
// Module Name:    doodle_top 
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
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////
module doodle_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	output 	 Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0,
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);
	
	wire bright;
	wire[9:0] hc, vc;
	wire [7:0] pixel_x, pixel_y;
	wire object_x, object_y;
	wire is_in_middle;
	wire[15:0] score;
	wire [6:0] ssdOut;
	wire [3:0] anode;
	wire [11:0] rgb;
	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	//vga_bitchange vbc(.clk(ClkPort), .bright(bright), .button(BtnU), .hCount(hc), .vCount(vc), .rgb(rgb), .score(score));
	//counter cnt(.clk(ClkPort), .displayNumber(score), .anode(anode), .ssdOut(ssdOut));
	
	//assign Dp = 1;
	//assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
    //assign {An7, An6, An5, An4, An3, An2, An1, An0} = {4'b1111, anode};

	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// Local Signals
	
	wire Start_Ack_Pulse;
	wire board_clk, sys_clk;
	reg [26:0]	    DIV_CLK;
	wire q_I, q_Sub, q_Mult, q_Done;
	wire [7:0] J, M, Curr, i_score;
	wire [1:0] ssdscan_clk;
	reg [7:0] Jin, Min;
	reg [3:0]	SSD;
	wire [3:0]	SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  SSD_CATHODES;
	wire [6:0] row, col;
	wire [11:0] color_data;

	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

	assign board_clk = ClkPort;

	assign Reset = BtnC;
	assign Start_Ack_Pulse = BtnU;

	/* Hard code Jin and Min */

	always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end

	assign	sys_clk = DIV_CLK[25];
	assign row = 6'b0001000;
	assign col = 6'b0001000;

	// the state module
	doodle_sm doodle_sm(.Clk(sys_clk), .Reset(Reset), .Start(Start_Ack_Pulse), .Ack(Start_Ack_Pulse), .Jin(Jin), .J(J), 
						  .Min(Min), .M(M), .Curr(Curr), .i_score(i_score), .q_I(q_I), .q_Up(q_Up), .q_Down(q_Down), .q_Done(q_Done),
						  .bright(bright), .hCount(hc), .vCount(vc), .rgb(rgb), .pixel_x(pixel_x), .pixel_y(pixel_y), .object_x(object_x),
						  .object_y(object_y), .is_in_middle(is_in_middle) );

	//doodlejump_bar_green_rom doodlejump_bar_green_rom(.clk(sys_clk),.row(row),.col(col),.color_data(color_data));


	/* Use LEDs to see which state we're in */
	assign {Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0} = {q_I, q_Up, q_Down, q_Done, 4'b0000};

	assign SSD3 = 4'b0000;
	assign SSD2 = 4'b0000;
	assign SSD1 = (q_Done) ? i_score[7:4] : 4'b0000;
	assign SSD0 = (q_Done) ? i_score[3:0] : 4'b0000;

	assign ssdscan_clk = DIV_CLK[19:18];

	assign AN0	= ~(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign AN1	= ~(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign AN2	= ~( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign AN3	= ~( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11

	assign {AN7, AN6, AN5, AN4} = 4'b1111;

	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  2'b00: SSD = SSD3     ;	// ****** TODO  in Part 2 ******
				  2'b01: SSD = SSD2    ;  	// Complete the four lines
				  
				  2'b10: SSD = SSD1   ;
				  2'b11: SSD = SSD0    ;
		endcase 
	end

	/* Use SSDs to print score when arriving in DONE state */
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) 
			4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	

endmodule