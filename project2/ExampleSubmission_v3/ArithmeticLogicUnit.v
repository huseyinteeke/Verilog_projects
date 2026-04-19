`timescale 1ns / 1ps

module ArithmeticLogicUnit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [3:0] FunSel,
    input wire WF,
    input wire Clock,
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut // [3]:Z, [2]:C, [1]:N, [0]:O
);

reg [16:0] temp;

// 1. TAMAMEN KOMBİNASYONEL BLOK (WF'den Bağımsız, Gecikmesiz)
always @(*) begin
    case(FunSel)
        4'b0000: ALUOut = A; 
        4'b0001: ALUOut = B; 
        4'b0010: ALUOut = ~A; 
        4'b0011: ALUOut = ~B; 
        4'b0100: ALUOut = A + B; 
        4'b0101: ALUOut = A + B + FlagsOut[2]; // ADC
        4'b0110: ALUOut = A + (~B) + 1'b1;     // SUB (2's complement)
        4'b0111: ALUOut = A & B; 
        4'b1000: ALUOut = A | B; 
        4'b1001: ALUOut = A ^ B;               // İşlemini (A&~B)|(~A&B) XOR ile sadeleştirdim
        4'b1010: ALUOut = ~(A & B); 
        4'b1011: ALUOut = A << 1; 
        4'b1100: ALUOut = A >> 1; 
        4'b1101: ALUOut = {A[15], A[15:1]};    // ASR
        4'b1110: ALUOut = {A[14:0], A[15]};    // CSL
        4'b1111: ALUOut = {A[0], A[15:1]};     // CSR
        default: ALUOut = 16'd0;               // Güvenli varsayılan değer
    endcase
end

// 2. SENKRON BLOK (Sadece WF 1 ise Bayrakları Günceller)
always @(posedge Clock) begin
    if(WF) begin
        // Carry ve Overflow hesaplamaları (Sadece aritmetik ve kaydırma için)
        case(FunSel)
            4'b0100: begin // ADD
                temp = {1'b0, A} + {1'b0, B};
                FlagsOut[2] <= temp[16]; // C
                FlagsOut[0] <= (A[15] == B[15] && A[15] != temp[15]); // O (İşaretler aynı, sonuç farklıysa)
            end
            4'b0101: begin // ADC
                temp = {1'b0, A} + {1'b0, B} + FlagsOut[2];
                FlagsOut[2] <= temp[16]; // C
                FlagsOut[0] <= (A[15] == B[15] && A[15] != temp[15]); // O
            end
            4'b0110: begin // SUB
                temp = {1'b0, A} + {1'b0, (~B)} + 1'b1;
                FlagsOut[2] <= temp[16]; // C 
                // DÜZELTİLDİ: Çıkarma için Overflow Mantığı (İşaretler ZIT, A'nın işareti ile sonuç ZIT)
                FlagsOut[0] <= (A[15] != B[15] && A[15] != temp[15]); 
            end
            4'b1011: begin FlagsOut[2] <= A[15]; FlagsOut[0] <= 1'b0; end // LSL
            4'b1100: begin FlagsOut[2] <= A[0];  FlagsOut[0] <= 1'b0; end // LSR
            4'b1110: begin FlagsOut[2] <= A[15]; FlagsOut[0] <= 1'b0; end // CSL
            4'b1111: begin FlagsOut[2] <= A[0];  FlagsOut[0] <= 1'b0; end // CSR
            default: begin end // Diğer lojik işlemlerde C ve O bayrakları değişmez
        endcase

        // Zero (Z) ve Negative (N) bayrakları her WF=1 durumunda güncellenir
        FlagsOut[3] <= (ALUOut == 16'd0) ? 1'b1 : 1'b0; // Z
        FlagsOut[1] <= ALUOut[15];                      // N
    end
end

endmodule