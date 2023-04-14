

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
                        if (/* Above the middle */) 
                            /* Scroll the screen up */
                    end
                
                DOWN:
                    begin 
                        // Add state transitions here
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

endmodule;