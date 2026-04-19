`timescale 1ns / 1ps


module InstructionMemory(
    input wire[15:0] Address,
    input wire CS, //Chip is enable when cs = 1
    input wire Clock,
    output reg [7:0] MemOut // Output
);
    //Declaration of the ROM Area
    reg[7:0] ROM_DATA[0:65535];
    //Read Rom data from the file
    initial $readmemh("ROM.mem", ROM_DATA);
    //Read the selected data from ROM
    always @(*) begin
        MemOut = CS ? ROM_DATA[Address] : 8'hZ;
    end
endmodule