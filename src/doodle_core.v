

`timescale 1ns / 1ps

module doodle_sm(
    input Clk, Reset, Start, Ack,
    input JUMP_HEIGHT,
    /*
        Curr represents the current distance that the doodle has jumped.
        i_score represents the current score. It should be the sum of all pixels doodle has jumped.
    */
    output reg[7:0] Curr, i_score,
    output q_I, q_Up, q_Down, q_Done,
    input [9:0] hCount, vCount,
    input [7:0] pixel_x, pixel_y, // pixel_x and pixel_y represent the current pixel being displayed on the screen.
    input [9:0] object_x, object_y, // object_x and object_y represent the position of the object being checked
    output reg is_in_middle,
    output reg[9:0] v_counter    
);
    // State variables
    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;
    localparam I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX; // bit mapping

    // Doodle's pixel size and jump distance
    localparam DOODLE_RADIUS = 20;

    // Obtain the resolution of the screen using the VGA interface module
    parameter H_RES = 640;
    parameter V_RES = 480;

    // Calculate the midpoint of the screen
    parameter H_MIDDLE = H_RES / 2;
    parameter V_MIDDLE = V_RES / 2;

    // Python image render script
    reg [7:0] image_data [0:255][0:255];
    reg [15:0] mem_address;
    reg [9:0] x_offset = 0;
    reg [9:0] y_offset = 50;
    wire pixel_data;
    
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
                Curr <= 8'bx;
                is_in_middle <= 1'b0;
            end
        else
        begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                        Curr <= 0;
                        i_score <= 0;
                    end
                UP:
                    begin
                        if (Curr == JUMP_HEIGHT)
                            state <= DOWN;
                        else 
                        begin
                            Curr <= Curr + 1;
                            i_score <= i_score + 1;
                        end
                        if (pixel_x >= object_x - DOODLE_RADIUS && pixel_x <= object_x + DOODLE_RADIUS &&
                            pixel_y >= object_y - DOODLE_RADIUS && pixel_y <= object_y + DOODLE_RADIUS) 
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
                        if (((object_x>=374 && object_x<=438) && (object_y==490 || object_y==145)) || 
                            ((object_x>=256 && object_x<=320) && (object_y==200 || object_y==450)) || 
                            ((object_x>=600 && object_x<=664) && (object_y==145 || object_y==72 || object_y==490 || object_y==330)) || 
                            ((object_x>=300 && object_x<=364) && (object_y==300)) ||   
                            ((object_x>=200 && object_x<=264) && (object_y==330 || object_y==100)) ||  
                            ((object_x>=400 && object_x<=464) && (object_y==330))) // Dummy code, will add condition later /* hit block */
                            begin
                            state <= UP;
                            Curr <= 0;
                            end
                        else
                        begin
                            if (object_y==510) 
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
            if (v_counter <= JUMP_HEIGHT)
            begin
                v_counter <= v_counter + 1;
            end
        end
    end

endmodule