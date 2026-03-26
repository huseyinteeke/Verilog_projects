`timescale 1ns / 1ps


module DataMemoryUnit(
    input wire [7:0] I,
    input wire [15:0] Address,
    input wire CS,
    input wire WR,
    input wire FunSel,
    input wire Clock,
    output wire [15:0] DMUOut
    );
    
wire [7:0] MemOut;

DataMemory DM(
    .Address(Address),
    .Clock(Clock),
    .Data(I),
    .WR(WR),
    .CS(~CS),
    .MemOut(MemOut)
);

DataRegister DR(
    .I(MemOut),
    .E(1'b1),
    .FunSel(FunSel),
    .Clock(Clock),
    .DROut(DMUOut)
);

endmodule
