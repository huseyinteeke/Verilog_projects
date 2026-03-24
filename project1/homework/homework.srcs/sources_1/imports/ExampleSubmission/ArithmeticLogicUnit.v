`timescale 1ns / 1ps


module ArithmeticLogicUnit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [3:0] FunSel,
    input wire WF,
    input wire Clock,
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut
);

reg Z, C, N, O;
reg [16:0] temp;

always @(*)
begin

if(WF)
begin

case(FunSel)

4'b0000:begin ALUOut = A; end
4'b0001:begin ALUOut = B; end
4'b0010:begin ALUOut = ~A; end
4'b0011:begin ALUOut = ~B; end
4'b0100:
begin 
ALUOut = A + B; 
temp = {1'b0, A} + {1'b0, B};
C = temp[16];
O = (A[15] == B[15]) && (ALUOut[15] != A[15]);
end
4'b0101:
begin 
ALUOut = A + B + FlagsOut[1]; 
temp = {1'b0, A} + {1'b0, B} +  FlagsOut[1];

end
4'b0110:begin ALUOut = A + (~B) + 1; 
end
4'b0111:
begin
temp = {1'b0, A} - {1'b0, B};
ALUOut = temp[15:0];
C = temp[16];
O = (A[15] != B[15]) && (ALUOut[15] != A[15]);
end
4'b1000:begin ALUOut = A | B; end
4'b1001:begin ALUOut = (A & (~B)) | ((~A) & B); end
4'b1010:begin ALUOut = ~( A & B); end
4'b1011:
begin 
ALUOut = A << 1;
C = A[15];
end
4'b1100:begin ALUOut = A >> 1; C = A[0]; end
4'b1101:begin ALUOut = {A[15] , A[15:1]};end
4'b1110:begin ALUOut = {A[14:0] , A[15]}; end
4'b1111:begin ALUOut = {A[0] , A[15:1]}; end
default:begin end 
endcase

Z = (ALUOut == 16'd0) ? 1'b1 : 1'b0;
N = ALUOut[15];
FlagsOut = {Z, C, N, O};
end
end


endmodule