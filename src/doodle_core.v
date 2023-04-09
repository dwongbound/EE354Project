

`timescale 1ns / 1ps

module doodle_sm(Clk, Reset, Start, Ack, q_I, q_Up, q_Down, q_Done);

    input   Clk, Reset, Start, Ack;

    output q_I, q_Up, q_Down, q_Done;
    reg [3:0] state;'
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
                    end
                UP:
                    begin
                    
                    end
                
                DOWN:
                    begin 

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