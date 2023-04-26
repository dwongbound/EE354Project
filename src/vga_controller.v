`timescale 1ns / 1ps

module vga_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, down, left, right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	input v_counter,
	input [4:0] tilt_intensity, // this only goes from 1 to 8
	// these two values dictate the center of the doodle, incrementing and decrementing them leads the block to move in certain directions
	output [9:0] xpos, ypos
);

    // Temp size of doodle's radius
    localparam DOODLE_RADIUS = 10;
    
	// Temp variable used to calculate location of filled block
	wire block_fill;

	// Temp new xpos and ypos
	reg [9:0] temp_x, temp_y;

	// Const color values
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	
	always@(posedge clk, posedge rst) 
	begin
		if (rst)
		begin 
			// rough values for center of screen
			temp_x <= 450;
			temp_y <= 250;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if (right) begin
				temp_x <= temp_x + tilt_intensity; //change the amount you increment to make the speed faster 
				if(temp_x == 800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					temp_x <= 150;
			end
			else if (left) begin
				temp_x <= temp_x - tilt_intensity;
				if (temp_x == 150)
					temp_x <= 800;
			end
			if (up) begin
				temp_y <= temp_y - 2;
				if(temp_y == 34)
					temp_y <= 514;
			end
			else if (down) begin
				temp_y <= temp_y + 2;
				if (temp_y == 514)
					temp_y <= 34;
			end
		end
	end

	//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill = vCount >= (temp_y-DOODLE_RADIUS) && vCount <= (temp_y+DOODLE_RADIUS) && hCount >= (temp_x-DOODLE_RADIUS) && hCount <= (temp_x+DOODLE_RADIUS);
	
	always@ (*) // paint a white box on a red background
    	if (~bright)
			rgb = BLACK; // force black if not bright
		else if (rst)
			rgb = WHITE;
		else if (block_fill)
			rgb = RED;
		else if (B1 == 1 || B2 ==1 || B3==1 || B4==1 || B5==1 || B6==1 ||  B7==1 || B8==1 || B9==1 || B10==1|| B11==1 || B12==1)
			rgb = GREEN;
		else
			rgb = BLACK; // background color
	
	//assign whiteZone = ((hCount >= 10'd144) && (hCount <= 10'd784)) && ((vCount >= 10'd400) && (vCount <= 10'd475)) ? 1 : 0;

    assign B1 = (hCount>= 256 && hCount <= 320) && (vCount>=(v_counter+200) && vCount<=(v_counter+216));
    assign B2 = (hCount>=374 && hCount <= 438) && (vCount>=(v_counter+490) && vCount<=(v_counter+506));
    assign B3 = (hCount>=600 && hCount <= 664) && (vCount>=(v_counter+330) && vCount<=(v_counter+346));
    assign B4 = (hCount>=200 && hCount <= 264) && (vCount>=(v_counter+100) && vCount<=(v_counter+116));
    assign B5 = (hCount>= 256 && hCount <= 320) && (vCount>=(v_counter+450) && vCount<=(v_counter+466));
    assign B6 = (hCount>=374 && hCount <= 438) && (vCount>=(v_counter+145) && vCount<=(v_counter+161));
    assign B7 = (hCount>=600 && hCount <= 664) && (vCount>=(v_counter+145) && vCount<=(v_counter+161));
    assign B8 = (hCount>=200 && hCount <= 264) && (vCount>=(v_counter+330) && vCount<=(v_counter+346));
    assign B9 = (hCount>=300 && hCount <= 364) && (vCount>=(v_counter+300) && vCount<=(v_counter+316));
    assign B10 = (hCount>=400 && hCount<=464) && (vCount>=(v_counter + 330) && vCount <= (v_counter + 346));
    assign B11 = (hCount>=600 && hCount <=664) && (vCount>=(v_counter+72) && vCount<=(v_counter+88));
    assign B12 = (hCount>=600 && hCount <=664) && (vCount>=(v_counter+490) && vCount<=(v_counter+506));
	
	// Assign xpos and ypos
	assign xpos = temp_x;
	assign ypos = temp_y;
	
endmodule
