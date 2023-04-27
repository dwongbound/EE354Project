`timescale 1ns / 1ps

module doodle_sm(
    input Clk, Reset, Start, Ack,
    input[9:0] JUMP_HEIGHT,
    // up_count represents the current distance that the doodle has jumped. Generated in vga_controller
    input [9:0] up_count, 
    output q_I, q_Up, q_Down, q_Done,
    input [9:0] hCount, vCount,
    input [7:0] pixel_x, pixel_y, // pixel_x and pixel_y represent the current pixel being displayed on the screen.
    input [9:0] object_x, object_y, // object_x and object_y represent the position of the object being checked
    output reg is_in_middle,
    output [9:0] v_counter // How many pixels we've scrolled. Defaults to 0
);
    // State variables
    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;
    localparam I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX; // bit mapping

    // Doodle's pixel size
    localparam DOODLE_RADIUS = 13; // from middle to bottom edge
    localparam PLAT_RADIUS_W = 32; // Width radius of platform
	localparam PLAT_RADIUS_H = 7; // Height radius of platform

    // Obtain the resolution of the screen using the VGA interface module
    parameter H_RES = 630; // Goes from 144 to 774 (right)
    parameter V_RES = 480; // Goes from 35 (top) to 515 (bottom)

    // Calculate the midpoint of the screen
    parameter H_MIDDLE = (H_RES / 2) + 144; // Includes offset
    parameter V_MIDDLE = (V_RES / 2) + 35;  // Includes offset

    // Temp variables
    reg [9:0] temp_v_counter;

    always @ (posedge Clk, posedge Reset)
    begin
        if (Reset)
            begin
                state <= I;
                is_in_middle <= 1'b0;
                temp_v_counter <= 0;
            end
        else begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                    end
                UP:
                    begin
                        if (up_count >= JUMP_HEIGHT)
                            state <= DOWN;

                        // if (object_y >= V_MIDDLE)  
                        //     is_in_middle <= 1;
                        // else 
                        //     is_in_middle <= 0;

                    end
                
                DOWN:
                    begin
                        if ((object_y + DOODLE_RADIUS) > 515) // Doodle reached the bottom of the stage
                                state <= DONE;
                        // B1
                        else if ((object_x+DOODLE_RADIUS)>=(288-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(288+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(208-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(208+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B2
                        else if ((object_x+DOODLE_RADIUS)>=(406-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(406+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(498-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(498+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B3
                        else if ((object_x+DOODLE_RADIUS)>=(632-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(632+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(338-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(338+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B4
                        else if ((object_x+DOODLE_RADIUS)>=(232-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(232+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(108-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(108+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B5
                        else if ((object_x+DOODLE_RADIUS)>=(288-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(288+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(478-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(478+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B6
                        else if ((object_x+DOODLE_RADIUS)>=(406-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(406+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(153-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(153+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B8
                        else if ((object_x+DOODLE_RADIUS)>=(232-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(232+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(338-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(338+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B9
                        else if ((object_x+DOODLE_RADIUS)>=(338-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(338+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(308-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(308+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B10
                        else if ((object_x+DOODLE_RADIUS)>=(432-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(432+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(368-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(368+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                        // B11
                        else if ((object_x+DOODLE_RADIUS)>=(632-PLAT_RADIUS_W) && (object_x-DOODLE_RADIUS)<=(632+PLAT_RADIUS_W) && (object_y+DOODLE_RADIUS)>=(80-PLAT_RADIUS_H+v_counter) && (object_y+DOODLE_RADIUS)<=(80+PLAT_RADIUS_H+v_counter))
                            state <= UP;
                    end
                
                DONE:
                    begin
                        if (Reset)
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
            if (v_counter <= JUMP_HEIGHT)
            begin
                temp_v_counter <= v_counter + 1;
            end
        end
        else 
            temp_v_counter <= 10'b0000000000;
    end

    // assign temp values
    assign v_counter = temp_v_counter;

endmodule