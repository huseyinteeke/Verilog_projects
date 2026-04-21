`timescale 1ns / 1ps


module InstructionRegister(
    input wire [7:0] I ,
    input wire Write , 
    input wire LH,
    input wire Clock,
    output reg [15:0] IROut
);


always @(posedge Clock)
begin
if(Write)
begin
    if(!LH && Write) begin IROut = {IROut[15:8] , I}; end
    else if(LH && Write) begin IROut = {I , IROut[7:0]}; end
end
else begin end
end
endmodule