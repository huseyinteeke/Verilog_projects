`timescale 1ns / 1ps


module InstructionMemoryUnit(
    input wire [15:0] Address,
    input wire LH,
    input wire CS,
    input wire Clock,
    output wire [15:0] IMUOut,
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

assign IMUOut = {8'h00 , IROut[7:0]}; 

endmodule