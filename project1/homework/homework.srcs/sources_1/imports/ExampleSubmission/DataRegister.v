`timescale 1ns / 1ps

module DataRegister(
    input wire [7:0] I,
    input wire E,
    input wire FunSel,
    input wire Clock,
    output reg [15:0] DROut
);


always @(posedge Clock)
begin

if(E) 
begin
    case(FunSel)
        1'b0: begin DROut[7:0] = I; end
        1'b1: begin DROut[15:8] = I; end
        default: begin end
    endcase
end

else begin end
end



endmodule