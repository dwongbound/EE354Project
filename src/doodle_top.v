`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:18:00 12/14/2017 
// Design Name: 
// Module Name:    vga_top 
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
module vga_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);
	
	wire bright;
	wire[9:0] hc, vc;
	wire[15:0] score;
	wire [6:0] ssdOut;
	wire [3:0] anode;
	wire [11:0] rgb;
	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	vga_bitchange vbc(.clk(ClkPort), .bright(bright), .button(BtnU), .hCount(hc), .vCount(vc), .rgb(rgb), .score(score));
	counter cnt(.clk(ClkPort), .displayNumber(score), .anode(anode), .ssdOut(ssdOut));
	
	assign Dp = 1;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
    assign {An7, An6, An5, An4, An3, An2, An1, An0} = {4'b1111, anode};

	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// Local Signals
	
	wire Start_Ack_Pulse;
	wire board_clk, sys_clk;
	reg [26:0]	    DIV_CLK;
	wire q_I, q_Sub, q_Mult, q_Done;
	wire [7:0] J, Curr, i_score;
	reg [7:0] Jin;

	assign board_clk = ClkPort;
	
	assign Reset = BtnC;

	always @(posedge board_clk, posedge reset) 	
    begin							
        if (reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end

	assign	sys_clk = DIV_CLK[25];


	// the state module
	doodle_core doodle_sm(.Clk(sys_clk), .Reset(Reset), .Start(Start_Ack_Pulse), .Ack(Start_Ack_Pulse), .Jin(Jin), .J(J), 
						  .Curr(Curr), .i_score(i_score), .q_I(q_I), .q_Up(q_Up), .q_Down(q_Down), .q_Done(q_Done));
	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

endmodule