

`timescale 1ns / 1ps

module doodle_sm(Clk, Reset, Start, Ack, Jin, J, Curr, i_score, q_I, q_Up, q_Down, q_Done);

    input   Clk, Reset, Start, Ack;
    input [7:0] Jin; // Assuming would get jump distance (that's constant) from top design 
    output q_I, q_Up, q_Down, q_Done;
    /*
        Curr represents the current distance that the doodle has jumped.
        i_score represents the current score.
    */
    output reg[7:0] J, Curr, i_score; 

    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;

    localparam 	
	I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;

    always @ (posedge Clk, posedge reset)
    begin
        if (Reset)
            begin
                state <= I;
                i_count <= 8'bx;
                J <= 8'bx;
                Curr <= 8'bx;
            end
        else
        begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                        J <= Jin;
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
                    end
                
                DOWN:
                    begin 
                        // Add state transitions here

                        // Datapath Operations
                        Curr <= Curr - 1;
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

endmodule;