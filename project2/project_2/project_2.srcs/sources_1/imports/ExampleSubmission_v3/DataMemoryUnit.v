module DataMemoryUnit(
    input wire [7:0] I,
    input wire [15:0] Address,
    input wire CS,       // CU'dan gelen aktif-düþük sinyal
    input wire WR,       // Read=0, Write=1
    input wire FunSel,   // 0: LSB, 1: MSB
    input wire Clock,
    output wire [15:0] DMUOut
    );

wire [7:0] MemOut;

// DR sadece okuma yapýldýðý (CS=0 ve WR=0) anlarda güncellenmelidir.
// Aksi takdirde veri yolundaki 'Z' deðerini içeri alýr.
wire ReadActive = (~CS) && (~WR);

DataMemory DM(
    .Address(Address),
    .Clock(Clock),
    .Data(I),
    .WR(WR),
    .CS(CS), // Direkt baðladýk, çünkü DataMemory de 0 ile aktif oluyor.
    .MemOut(MemOut)
);

DataRegister DR(
    .I(MemOut),
    .E(ReadActive), // E artýk sürekli 1 deðil, sadece okuma varken aktif.
    .FunSel(FunSel),
    .Clock(Clock),
    .DROut(DMUOut)
);

endmodule