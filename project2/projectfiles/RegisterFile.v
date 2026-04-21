`timescale 1ns / 1ps


module RegisterFile(
    input wire[15:0] I,
    input wire[2:0] OutASel,
    input wire[2:0] OutBSel,
    input wire[1:0] FunSel,
    input wire[3:0] RegSel,
    input wire[3:0] ScrSel,
    input wire  Clock,
    output reg[15:0] OutA,
    output reg[15:0] OutB
);

wire [15:0] outR1 , outR2 , 
            outR3 , outR4 , 
            outS1 , outS2 , 
            outS3 , outS4;

Register16bit R1(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[3]}),
    .Q(outR1) 
);

Register16bit R2(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[2]}),
    .Q(outR2) 
);


Register16bit R3(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[1]}),
    .Q(outR3) 
);


Register16bit R4(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~RegSel[0]}),
    .Q(outR4) 
);


Register16bit S1(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~ScrSel[3]}),
    .Q(outS1) 
);


Register16bit S2(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~ScrSel[2]}),
    .Q(outS2) 
);

Register16bit S3(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~ScrSel[1]}),
    .Q(outS3) 
);

Register16bit S4(
    .Clock(Clock),
    .I(I),
    .FunSel(FunSel),
    .E({~ScrSel[0]}),
    .Q(outS4) 
);





always @(*)
begin

case(OutASel)
3'b000:begin
    OutA = outR1;
end
3'b001:begin
    OutA = outR2;
end
3'b010:begin
    OutA = outR3;
end

3'b011:begin
    OutA = outR4;
end

3'b100:begin
    OutA = outS1;
end

3'b101:begin
    OutA = outS2;
end

3'b110:begin
    OutA = outS3;
end

3'b111:begin
    OutA = outS4;
end
default:begin
end
endcase


case(OutBSel)
3'b000:begin
    OutB = outR1;
end
3'b001:begin
    OutB = outR2;
end
3'b010:begin
    OutB = outR3;
end

3'b011:begin
    OutB = outR4;
end

3'b100:begin
    OutB = outS1;
end

3'b101:begin
    OutB = outS2;
end

3'b110:begin
    OutB = outS3;
end

3'b111:begin
    OutB = outS4;
end
default:begin
end
endcase








end



   













endmodule