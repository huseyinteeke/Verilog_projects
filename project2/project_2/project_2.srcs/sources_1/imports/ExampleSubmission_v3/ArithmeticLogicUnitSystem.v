`timescale 1ns / 1ps
module MUX2to1(
    input wire MuxSel,
    input wire[7:0] I0,
    input wire[7:0] I1,
    output reg[7:0] MuxOut
);

always @(*)
begin
    case(MuxSel)
    1'b0: begin MuxOut = I0; end
    1'b1: begin MuxOut = I1; end
    endcase
end

endmodule

module MUX4to1(
    input wire[1:0] MuxSel,
    input wire[15:0] I0,
    input wire[15:0] I1,
    input wire[15:0] I2,
    input wire[15:0] I3,
    output reg[15:0] MuxOut
);

always @(*)
begin
    case(MuxSel)
    2'b00: begin MuxOut = I0; end
    2'b01: begin MuxOut = I1; end
    2'b10: begin MuxOut = I2; end
    2'b11: begin MuxOut = I3; end
    endcase
end

endmodule
module ArithmeticLogicUnitSystem(
    input wire [3:0] ALU_FunSel,
    input wire[2:0] RF_OutASel,
    input wire[2:0] RF_OutBSel,
    input wire[1:0] RF_FunSel,
    input wire[3:0] RF_RegSel,
    input wire[3:0] RF_ScrSel,
    input wire  Clock,
    input wire[1:0] MuxASel,
    input wire[1:0] MuxBSel,
    input wire MuxCSel,
    input wire ALU_WF,
    input wire [1:0] ARF_OutCSel,
    input wire ARF_OutDSel,
    input wire [2:0] ARF_RegSel,
    input wire [1:0] ARF_FunSel,
    input wire IMU_LH,
    input wire IMU_CS,
    input wire DMU_CS,
    input wire DMU_WR,
    input wire DMU_FunSel,
    output wire [15:0] IROut,
    output wire C,
    output wire N,
    output wire O,
    output wire Z

);


wire [7:0] MuxCOut;
wire [15:0] MuxAOut;
wire [15:0] MuxBOut;
wire [15:0] OutA;
wire [15:0] OutB;
wire [15:0] OutC;
wire [15:0] OutD;
wire [15:0] OutE;
wire [15:0] ALUOut;
wire [15:0] DMUOut;
wire [15:0] IMUOut;
//wire [15:0] IROut;


AddressRegisterFile ARF(
    .I(MuxBOut),
    .OutCSel(ARF_OutCSel),
    .OutDSel(ARF_OutDSel),
    .RegSel(ARF_RegSel),
    .FunSel(ARF_FunSel),
    .Clock(Clock),
    .OutC(OutC),
    .OutD(OutD),
    .OutE(OutE)
);

DataMemoryUnit DMU(
    .I(MuxCOut),
    .Address(OutD),
    .CS(DMU_CS),
    .WR(DMU_WR),
    .FunSel(DMU_FunSel),
    .Clock(Clock),
    .DMUOut(DMUOut)
);

InstructionMemoryUnit IMU(
    .Address(OutE),
    .LH(IMU_LH),
    .CS(IMU_CS),
    .Clock(Clock),
    .IMUOut(IMUOut),
    .IROut(IROut)
);

RegisterFile RF(
    .I(MuxAOut),
    .OutASel(RF_OutASel),
    .OutBSel(RF_OutBSel),
    .FunSel(RF_FunSel),
    .RegSel(RF_RegSel),
    .ScrSel(RF_ScrSel),
    .Clock(Clock),
    .OutA(OutA),
    .OutB(OutB)
);


ArithmeticLogicUnit ALU(
    .A(OutA),
    .B(OutB),
    .FunSel(ALU_FunSel),
    .WF(ALU_WF),
    .Clock(Clock),
    .ALUOut(ALUOut),
    .FlagsOut({Z , C , N , O})
);


MUX4to1 MuxA(
    .MuxSel(MuxASel),
    .I0(ALUOut),
    .I1(OutC),
    .I2(DMUOut),
    .I3(IMUOut),
    .MuxOut(MuxAOut)
);

MUX4to1 MuxB(
    .MuxSel(MuxBSel),
    .I0(ALUOut),
    .I1(OutC),
    .I2(DMUOut),
    .I3(IMUOut),
    .MuxOut(MuxBOut)
);

MUX2to1 MuxC(
    .MuxSel(MuxCSel),
    .I0(ALUOut[7:0]),
    .I1(ALUOut[15:8]),
    .MuxOut(MuxCOut)
);

endmodule