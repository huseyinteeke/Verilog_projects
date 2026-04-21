`timescale 1ns / 1ps

module DataMemoryUnit(
    input wire [7:0] I,
    input wire [15:0] Address,
    input wire CS,       // CU'dan gelen aktif-düşük sinyal
    input wire WR,       // Read=0, Write=1
    input wire FunSel,   // 0: LSB, 1: MSB
    input wire Clock,
    output wire [15:0] DMUOut
    );

wire [7:0] MemOut;

// DR sadece okuma yapıldığı (CS=0 ve WR=0) anlarda güncellenmelidir.
// Aksi takdirde veri yolundaki 'Z' değerini içeri alır.
wire ReadActive = (~CS) && (~WR);

DataMemory DM(
    .Address(Address),
    .Clock(Clock),
    .Data(I),
    .WR(WR),
    .CS(CS), // Direkt bağladık, çünkü DataMemory de 0 ile aktif oluyor.
    .MemOut(MemOut)
);

DataRegister DR(
    .I(MemOut),
    .E(ReadActive), // E artık sürekli 1 değil, sadece okuma varken aktif.
    .FunSel(FunSel),
    .Clock(Clock),
    .DROut(DMUOut)
);

endmodule