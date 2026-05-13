`timescale 1ns / 1ps


module AddressRegisterFile(
    input wire [15:0] I,
    input wire [1:0] OutCSel,
    input wire OutDSel,
    input wire [2:0] RegSel,
    input wire [1:0] FunSel,
    input wire Clock,
    output reg [15:0] OutC,
    output reg [15:0] OutD,
    output reg [15:0] OutE
    );
    
wire [15:0] PCOut , SPOut , AROut;
    

Register16bit PC(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[2]}),
    .Q(PCOut)
);

Register16bit SP(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[1]}),
    .Q(SPOut)
);

Register16bit AR(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[0]}),
    .Q(AROut)
);    

    
always@(*)
begin

case (OutCSel)
    2'b00:begin OutC = PCOut; end
    2'b01:begin OutC = PCOut; end
    2'b10:begin OutC = AROut; end
    2'b11:begin OutC = SPOut; end
    default:begin end
endcase

case (OutDSel)
    1'b0:begin OutD = AROut; end
    1'b1:begin OutD = SPOut; end
    default:begin end
endcase

    OutE = PCOut;
end






endmodule