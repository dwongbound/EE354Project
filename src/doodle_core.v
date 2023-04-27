`timescale 1ns / 1ps

module doodle_sm(
    input Clk, Reset, Start, Ack,
    input[9:0] JUMP_HEIGHT,
    // up_count represents the current distance that the doodle has jumped. Generated in vga_controller
    // i_score represents the current score. It should be the sum of all pixels doodle has jumped.
    input [9:0] up_count, 
    output reg[7:0] i_score,
    output q_I, q_Up, q_Down, q_Done,
    input [9:0] hCount, vCount,
    input [7:0] pixel_x, pixel_y, // pixel_x and pixel_y represent the current pixel being displayed on the screen.
    input [9:0] object_x, object_y, // object_x and object_y represent the position of the object being checked
    output reg is_in_middle,
    output reg[9:0] v_counter // How many pixels we've scrolled. Defaults to 0
);
    // State variables
    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;
    localparam I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX; // bit mapping

    // Doodle's pixel size
    localparam DOODLE_RADIUS = 10; // from middle to bottom edge

    // Obtain the resolution of the screen using the VGA interface module
    parameter H_RES = 630; // Goes from 144 to 774 (right)
    parameter V_RES = 480; // Goes from 35 (top) to 515 (bottom)

    // Calculate the midpoint of the screen
    parameter H_MIDDLE = (H_RES / 2) + 144; // Includes offset
    parameter V_MIDDLE = (V_RES / 2) + 35;  // Includes offset

    // Python image render script
    // reg [7:0] image_data [0:255][0:255];
    
    /*
    initial begin
    $readmemb("green.mif", image_data);
    end
    */

    //wire [11:0] color_data;

   // Resize_green_rom Resize_green_rom(.clk(Clk),.row(vCount),.col(hCount),.color_data(color_data));


    always @ (posedge Clk, posedge Reset)
    begin
        if (Reset)
            begin
                state <= I;
                i_score <= 8'bx;
                is_in_middle <= 1'b0;
            end
        else
        begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                        i_score <= 0;
                    end
                UP:
                    begin
                        if (up_count >= JUMP_HEIGHT)
                            state <= DOWN;
                        else begin
                            i_score <= i_score + 1;
                        end
/*
                        if (object_y >= V_MIDDLE - DOODLE_RADIUS && object_y <= V_MIDDLE + DOODLE_RADIUS)  
                            is_in_middle <= 1;
                        else 
                            is_in_middle <= 0;
 */
                    end
                
                DOWN:
                    begin
                        if ( (object_x + DOODLE_RADIUS)>=374 && (object_x + DOODLE_RADIUS)<=438 && (object_y + DOODLE_RADIUS)>=490 && (object_y + DOODLE_RADIUS)<=500)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=374 && (object_x + DOODLE_RADIUS)<=438 && (object_y + DOODLE_RADIUS)>=145 && (object_y + DOODLE_RADIUS)<=155)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=256 && (object_x + DOODLE_RADIUS)<=320 && (object_y + DOODLE_RADIUS)>=470 && (object_y + DOODLE_RADIUS)<=480)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=256 && (object_x + DOODLE_RADIUS)<=320 && (object_y + DOODLE_RADIUS)>=200 && (object_y + DOODLE_RADIUS)<=210)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=600 && (object_x + DOODLE_RADIUS)<=664 && (object_y + DOODLE_RADIUS)>=490 && (object_y + DOODLE_RADIUS)<=500)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=600 && (object_x + DOODLE_RADIUS)<=664 && (object_y + DOODLE_RADIUS)>=330 && (object_y + DOODLE_RADIUS)<=340)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=600 && (object_x + DOODLE_RADIUS)<=664 && (object_y + DOODLE_RADIUS)>=145 && (object_y + DOODLE_RADIUS)<=155)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=600 && (object_x + DOODLE_RADIUS)<=664 && (object_y + DOODLE_RADIUS)>=72 && (object_y + DOODLE_RADIUS)<=82)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=300 && (object_x + DOODLE_RADIUS)<=364 && (object_y + DOODLE_RADIUS)>=300 && (object_y + DOODLE_RADIUS)<=310)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=200 && (object_x + DOODLE_RADIUS)<=264 && (object_y + DOODLE_RADIUS)>=330 && (object_y + DOODLE_RADIUS)<=340)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=200 && (object_x + DOODLE_RADIUS)<=264 && (object_y + DOODLE_RADIUS)>=100 && (object_y + DOODLE_RADIUS)<=110)
                            state <= UP;
                        else if ((object_x + DOODLE_RADIUS)>=400 && (object_x + DOODLE_RADIUS)<=464 && (object_y + DOODLE_RADIUS)>=360 && (object_y + DOODLE_RADIUS)<=370)
                            state <= UP;
                        else
                        begin
                            if ((object_y + DOODLE_RADIUS) > 515) // Doodle reached the bottom of the stage
                                state <= DONE;
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
            if (v_counter <= JUMP_HEIGHT)
            begin
                v_counter <= v_counter + 1;
            end
        end
        else 
            v_counter <= 10'b0000000000;
    end

endmodule