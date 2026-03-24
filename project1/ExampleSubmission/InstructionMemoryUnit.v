`timescale 1ns / 1ps


module InstructionMemoryUnit(
    input wire [15:0] Address,
    input wire LH,
    input wire CS,
    input wire Clock,
    output reg [15:0] IMUOut,
    output wire [15:0] IROut
);


wire [7:0] MemOut;

InstructionRegister IR(
    .I(MemOut),
    .Write(CS),
    .LH(LH),
    .Clock(Clock),
    .IROut(IROut)
);

InstructionMemory IM(
    .Address(Address),
    .CS(CS),
    .Clock(Clock),
    .MemOut(MemOut)
);

always @(*)
begin

if(CS)
begin

IMUOut = {8'h00 , IROut[7:0]}; 

end
else 
begin

IMUOut = 16'hzzzz;

end
end

endmodule
