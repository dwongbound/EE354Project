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
// Author: Dylan Wong and Julie Deng, based off of starter code by Yue (Julien) Niu
// Description: Doodle Jump Top design
//////////////////////////////////////////////////////////////////////////////////
module doodle_top(
	input ClkPort,
	input BtnC,
	input BtnU, BtnD,
	input BtnR, BtnL,
	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	output Ld15, Ld14, Ld13, Ld12, Ld11, Ld10, Ld9, Ld8, Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0,
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS,

	// Accelerator inputs / outputs
	input ACL_MISO,             // master in
    output ACL_MOSI,            // master out
    output ACL_SCLK,            // spi sclk
    output ACL_CSN            // spi ~chip select
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

	display_controller dc(
		.clk(ClkPort),
		.hSync(hSync), .vSync(vSync),
		.bright(bright),
		.hCount(hc), .vCount(vc)
	);

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
	reg [26:0] DIV_CLK;
	wire q_I, q_Sub, q_Mult, q_Done;
	wire [7:0] Curr, i_score;
	wire [1:0] ssdscan_clk;
	reg [3:0] SSD;
	wire [3:0] SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  SSD_CATHODES;
	wire [6:0] row, col;
	wire [11:0] color_data;

	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

	// Accelerometer
	wire w_4MHz; // clock for spi master
	wire [14:0] acl_data;
	wire parse_right, parse_left;
	reg [3:0] tilt_intensity, left_leds, right_leds;
	assign parse_right = acl_data[9]; // If bit is on, it means it's negative which means it's tilted right.
	// Left has to have no MSB but also not be empty
	assign parse_left = (~(acl_data[9]) && ((acl_data[8]) || (acl_data[7]) || (acl_data[6]) || (acl_data[5])));

	assign board_clk = ClkPort;
	assign Reset = BtnC;
	assign Start_Ack_Pulse = BtnU;

	// Hard code jump height
	parameter JUMP_HEIGHT = 250;

	// Clock management
	always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end

	assign sys_clk = DIV_CLK[25];
	assign row = 6'b0001000;
	assign col = 6'b0001000;
	wire move_clk; // Temp variable to capture slower clock
	assign move_clk = DIV_CLK[19]; //slower clock to drive the movement of objects on the vga screen
	wire v_counter; // keep track of screen scrolling as doodle jumps up

	// the state module
	doodle_sm doodle_sm(
		.Clk(sys_clk),
		.Reset(Reset),
		.Start(Start_Ack_Pulse),
		.Ack(Start_Ack_Pulse),
		.JUMP_HEIGHT(JUMP_HEIGHT),
		.Curr(Curr),
		.i_score(i_score),
		.q_I(q_I), .q_Up(q_Up), .q_Down(q_Down), .q_Done(q_Done),
		.hCount(hc), .vCount(vc),
		.pixel_x(pixel_x), .pixel_y(pixel_y),
		.object_x(object_x), .object_y(object_y),
		.is_in_middle(is_in_middle) 
	);

	// Generates 4MHz clock for spi master
	iclk_gen clock_generation(
        .ClkPort(ClkPort),
        .clk_4MHz(w_4MHz)
    );

	// VGA Module
	vga_controller sc(
		.clk(move_clk),
		.bright(bright),
		.rst(BtnC),
		.up(BtnU),
		.down(BtnD),
		.left(parse_left),
		.right(parse_right),
		.hCount(hc),
		.vCount(vc),
		.rgb(rgb),
		.v_counter(v_counter),
		.tilt_intensity(tilt_intensity)

	);

	// Controls accelerometer data
	spi_master master(
        .iclk(w_4MHz),
        .miso(ACL_MISO),
        .sclk(ACL_SCLK),
        .mosi(ACL_MOSI),
        .cs(ACL_CSN),
        .acl_data(acl_data)
    );
	
	// Visual feedback for accelerometer
	// This should only happen for each accelerometer poll
	always @ (w_4MHz)
	begin: GET_SENSITIVITY
		if (acl_data[9] == 1'b1)
			tilt_intensity <= -(acl_data[8:5]); // take 2s compliment
		else
			tilt_intensity <= (acl_data[8:5]); // take 2s compliment
		
		if (parse_right)
			begin
			right_leds <= tilt_intensity;
			left_leds <= 4'b0000;
			end
		else if (parse_left)
			begin
			left_leds <= tilt_intensity;
			right_leds <= 4'b0000;
			end
		else
			begin
			left_leds <= 4'b0000;
			right_leds <= 4'b0000;
			end
	end

	/* Use LEDs to see which state we're in and which side we are tilting */
	// Using right 4 to indicate tilt right, left 4 to indicate tilt left, and middle four to indicate state.
	// Note left leds are flipped on purpose to make it more symmetrical
	assign {Ld12, Ld13, Ld14, Ld15, Ld9, Ld8, Ld7, Ld6, Ld3, Ld2, Ld1, Ld0} = {left_leds, q_I, q_Up, q_Down, q_Done, right_leds};


	// SSD Parameters
	assign SSD3 = tilt_intensity;
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