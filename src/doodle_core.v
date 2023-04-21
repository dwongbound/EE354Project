

`timescale 1ns / 1ps

module doodle_sm(Clk, Reset, Start, Ack, Jin, J, Min, M, Curr, i_score, q_I, q_Up, q_Down, q_Done);

    input   Clk, Reset, Start, Ack;
    input [7:0] Jin, Min; // Assuming would get jump distance (that's constant) from top design 
    output q_I, q_Up, q_Down, q_Done;
    /*
        Curr represents the current distance that the doodle has jumped.
        i_score represents the current score.
    */
    output reg[7:0] J, Curr, i_score, M; 

    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;

    localparam 	
	I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;

    // Obtain the resolution of the screen using the VGA interface module
    parameter H_RES = 640;
    parameter V_RES = 480;

    // Calculate the midpoint of the screen
    parameter H_MIDDLE = H_RES / 2;
    parameter V_MIDDLE = V_RES / 2;

    parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;

    /*
        pixel_x and pixel_y represent the current pixel being displayed on the screen.

        object_x and object_y represent the position of the object being checked
    */
    input [7:0] pixel_x; 
    input [7:0] pixel_y;
    input object_x;
    input object_y;
    output reg is_in_middle;

    input bright;
    reg [10:0] v_counter;
    reg [10:0] h_counter;

    
    /*
        The two wires represent blocks. Can add more as needed.
    */
    output reg [11:0] rgb
    wire B1; 
    wire B2; 


    always @ (posedge Clk, posedge reset)
    begin
        if (Reset)
            begin
                state <= I;
                i_score <= 8'bx;
                J <= 8'bx;
                Curr <= 8'bx;
                M <= 8'bx;
            end
        else
        begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                        J <= Jin;
                        M <= Min;
                        Curr <= 0;
                        i_score <= 0;
                    end
                UP:
                    begin
                        if (Curr==J)
                            state <= DOWN;
                        else 
                        begin
                            Curr <= Curr + 1;
                            i_score <= i_score + 1;
                        end
                        if (pixel_x >= object_x - 10 && pixel_x <= object_x + 10 &&
                            pixel_y >= object_y - 10 && pixel_y <= object_y + 10) 
                            begin
                            is_in_middle <= 1;
                            end
                        else 
                            begin
                            is_in_middle <= 0;
                            end
                    end
                
                DOWN:
                    begin 
                        if (/* hit block */)
                            begin
                            state <= UP;
                            Curr <= 0;
                            end
                        else
                        begin
                            if (/* reached bottom of screen */)
                                state <= DONE;
                            else 
                            begin
                                Curr <= Curr - 1;
                            end
                        end
                    end
                
                DONE:
                    begin
                        if (Ack)
                            state <= I;
                    end
                
                default: 
                        state <= UNK;
            endcase
        end

    end


    // Might need to put 

    always @ (posedge Clk)
    begin
        if (is_in_middle==1'b1) 
        begin
            if (vCounter<=250)
            begin
                vCounter <= vCounter + 1;
            end
        end
        else
            is_in_middle==1'b0;
    end

    always@ (*) // paint a white box on a red background
    	if (~bright)
		rgb = BLACK; // force black if not bright
	 else if (B1 == 1 || B2==1)
		rgb = GREEN;
	 else
		rgb = RED; // background color

    assign B1 = (hCount>= 600 && hCount <= 620) && (vCount>=(v_counter+300) && vCount<=(v_counter+330));
    assign B2 = (hCount>=300 && hCount <= 340) && (vCount>=(v_counter+200) && vCount<=(v_counter+230))

endmodule;