`timescale 1ns / 1ps

module Register8bit(
    input wire [7:0] I,
    input wire  E,
    input wire [1:0] FunSel,
    input wire Clock,
    output reg [7:0] Q
);

    always @ (posedge Clock)
    begin 
    if(E) begin
        case(FunSel) 
            2'b00 : 
            begin
                Q <= Q - 1;
            end 
            2'b01 : 
            begin
                Q <= Q + 1;
            end
            2'b10 :
            begin
                Q <= I;
            end
            2'b11 :
            begin
                Q <= 8'd0;
            end
            
            default :
            begin
            end
        endcase   
        end
   end 
endmodule