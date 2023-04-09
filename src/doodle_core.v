

`timescale 1ns / 1ps

module doodle_sm(Clk, Reset, Start, Ack, Jin, J, Curr, q_I, q_Up, q_Down, q_Done);

    input   Clk, Reset, Start, Ack;
    input [7:0] Jin; // Assuming would get jump distance (that's constant) from top design 
    output q_I, q_Up, q_Down, q_Done;
    output reg[7:0] J;
    output reg[7:0] Curr; // Curr represents the current distance that the doodle has jumped
    reg [3:0] state;
    assign {q_Done, q_Down, q_Up, q_I} = state;

    localparam 	
	I = 4'b0001, UP = 4'b0010, DOWN = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;

    always @ (posedge Clk, posedge reset)
    begin
        if (Reset)
            state <= I;
        else
        begin
            case(state)
                I:
                    begin
                        if (Start)
                            state <= UP;
                        J <= Jin;
                        Curr <= 0;
                    end
                UP:
                    begin
                        if (Curr==J)
                            state <= DOWN;
                        else 
                        begin
                            Curr <= Curr + 1;
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