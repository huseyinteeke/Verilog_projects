`timescale 1ns / 1ps

module DataMemoryUnit(
    input wire [7:0] I,
    input wire [15:0] Address,
    input wire CS,       
    input wire WR,       // Read=0, Write=1
    input wire FunSel,   // 0: LSB, 1: MSB
    input wire Clock,
    output wire [15:0] DMUOut
    );

wire [7:0] MemOut;

/*
eskiden böyle bırakmışım , altta enable a read active vermişim. Bunu CS olarak değiştim. 
*/
wire ReadActive = (~CS) && (~WR); //Will be asked to the TA

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
    .E(CS), 
    .FunSel(FunSel),
    .Clock(Clock),
    .DROut(DMUOut)
);

endmodule