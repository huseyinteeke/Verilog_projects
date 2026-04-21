`timescale 1ns / 1ps

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);

// KONTROL SINYALLERI
reg  [3:0] ALU_FunSel;
reg [2:0] RF_OutASel;
reg [2:0] RF_OutBSel;
reg [1:0] RF_FunSel;
reg [3:0] RF_RegSel;
reg [3:0] RF_ScrSel;
reg [1:0] MuxASel;
reg [1:0] MuxBSel;
reg MuxCSel;
reg ALU_WF;
reg [1:0] ARF_OutCSel;
reg ARF_OutDSel;
reg [2:0] ARF_RegSel;
reg [1:0] ARF_FunSel;
reg IMU_LH;
reg IMU_CS;
reg DMU_CS;
reg DMU_WR;
reg DMU_FunSel;

wire [15:0] IROut;
wire Z, C, N, O;

// Instruction Decode
wire [5:0] Opcode   = IROut[15:10];
wire [1:0] RegSel   = IROut[9:8];
wire [7:0] Address  = IROut[7:0];
wire [2:0] DestReg  = IROut[9:7];
wire [2:0] SrcReg1  = IROut[6:4];
wire [2:0] SrcReg2  = IROut[3:1];

reg T_Reset;

// RF Okuma MUX'lari (1xx -> 0xx cevirici)
wire [2:0] OutA_Mapped = {1'b0, SrcReg1[1:0]};
wire [2:0] OutB_Mapped = {1'b0, SrcReg2[1:0]};

reg [3:0] Decoded_DSTREG;
reg [2:0] Decoded_ARF_DST;
reg [3:0] Decoded_IMM_DST;

// DECODER BLOK (Active-Low Maskeleri)
always @(*) begin
    // RF icin maskeler (0=Aktif)
    case(DestReg)
        3'b100: Decoded_DSTREG = 4'b0111; // R1
        3'b101: Decoded_DSTREG = 4'b1011; // R2
        3'b110: Decoded_DSTREG = 4'b1101; // R3
        3'b111: Decoded_DSTREG = 4'b1110; // R4
        default: Decoded_DSTREG = 4'b1111; 
    endcase
    
    // ARF icin maskeler (Bit2=PC, Bit1=SP, Bit0=AR)
    case(DestReg)
        3'b000, 3'b001: Decoded_ARF_DST = 3'b011; // PC
        3'b010:         Decoded_ARF_DST = 3'b110; // AR
        3'b011:         Decoded_ARF_DST = 3'b101; // SP
        default:        Decoded_ARF_DST = 3'b111; 
    endcase
    
    // IMM Komutu icin RF hedefi (Format 1: RegSel kullanir)
    case(RegSel)
        2'b00: Decoded_IMM_DST = 4'b0111; // R1
        2'b01: Decoded_IMM_DST = 4'b1011; // R2
        2'b10: Decoded_IMM_DST = 4'b1101; // R3
        2'b11: Decoded_IMM_DST = 4'b1110; // R4
    endcase
end

ArithmeticLogicUnitSystem ALUSys(
    .ALU_FunSel(ALU_FunSel),
    .RF_OutASel(RF_OutASel),
    .RF_OutBSel(RF_OutBSel),
    .RF_FunSel(RF_FunSel),
    .RF_RegSel(RF_RegSel),
    .RF_ScrSel(RF_ScrSel),
    .Clock(Clock),
    .MuxASel(MuxASel),
    .MuxBSel(MuxBSel),
    .MuxCSel(MuxCSel),
    .ALU_WF(ALU_WF),
    .ARF_OutCSel(ARF_OutCSel),
    .ARF_OutDSel(ARF_OutDSel),
    .ARF_RegSel(ARF_RegSel),
    .ARF_FunSel(ARF_FunSel),
    .IMU_LH(IMU_LH),
    .IMU_CS(IMU_CS),
    .DMU_CS(DMU_CS),
    .DMU_WR(DMU_WR),
    .DMU_FunSel(DMU_FunSel),
    .IROut(IROut),
    .Z(Z), .C(C), .N(N), .O(O)
);

// =========================================================================
// 1. KOMBİNASYONEL BLOK: Veriyolu ve Kontrol Sinyalleri
// =========================================================================
always @(*) begin
    // --- BÖLÜM 1: STATELESS DATAPATH ---
    RF_OutASel  = 3'b000;
    RF_OutBSel  = 3'b000;
    MuxASel     = 2'b00;
    MuxBSel     = 2'b00;
    MuxCSel     = 1'b0;
    ALU_FunSel  = 4'b0000;

    if (Opcode == 6'd23) begin
        MuxASel = 2'b11; // IMM icin IMUOut
    end else if (Opcode <= 6'd6) begin
        MuxBSel = 2'b11; // Branch icin IMUOut
    end else begin
        if (DestReg[2] == 1'b1) MuxASel = 2'b00; 
        else MuxBSel = 2'b00;
    end

    case(Opcode)
        6'd7, 6'd8: begin
            RF_OutASel = (SrcReg1[2] == 1'b0) ? 3'b100 : OutA_Mapped; 
        end
        6'd9, 6'd10, 6'd11, 6'd12, 6'd13, 6'd14, 
        6'd15, 6'd16, 6'd17, 6'd18, 6'd19, 6'd20, 6'd21, 6'd22: begin
            RF_OutASel = (SrcReg1[2] == 1'b0) ? 3'b100 : OutA_Mapped; // S1 veya RF
            RF_OutBSel = (SrcReg2[2] == 1'b0) ? 3'b101 : OutB_Mapped; // S2 veya RF
            case(Opcode)
                6'd9:  ALU_FunSel = 4'b1011; // LSL
                6'd10: ALU_FunSel = 4'b1100; // LSR
                6'd11: ALU_FunSel = 4'b1101; // ASR
                6'd12: ALU_FunSel = 4'b1110; // CSL
                6'd13: ALU_FunSel = 4'b1111; // CSR
                6'd14: ALU_FunSel = 4'b0010; // NOT A
                6'd15: ALU_FunSel = 4'b0111; // AND
                6'd16: ALU_FunSel = 4'b1000; // ORR
                6'd17: ALU_FunSel = 4'b1001; // XOR
                6'd18: ALU_FunSel = 4'b1010; // NAND
                6'd19: ALU_FunSel = 4'b0100; // ADD
                6'd20: ALU_FunSel = 4'b0101; // ADC
                6'd21: ALU_FunSel = 4'b0110; // SUB
                6'd22: ALU_FunSel = 4'b0000; // MOV
            endcase
        end
    endcase

    // --- BÖLÜM 2: STATEFUL CONTROLS ---
    T_Reset     = 1'b0;
    ALU_WF      = 1'b0;
    ARF_OutCSel = 2'b00;
    ARF_OutDSel = 1'b0;
    ARF_FunSel  = 2'b11; // Retain
    ARF_RegSel  = 3'b111; 
    RF_FunSel   = 2'b11; // Retain
    RF_RegSel   = 4'b1111; 
    RF_ScrSel   = 4'b1111; 
    
    // Varsayilan Olarak IMU KAPALI! (Opcode'un silinmemesi icin)
    IMU_CS      = 1'b0; 
    IMU_LH      = 1'b0;
    DMU_CS      = 1'b1; // DMU Disable
    DMU_WR      = 1'b0;
    DMU_FunSel  = 1'b0;

    if (!Reset) begin
        ARF_FunSel = 2'b00; ARF_RegSel = 3'b000; 
        RF_FunSel  = 2'b00; RF_RegSel  = 4'b0000; RF_ScrSel = 4'b0000; 
    end else begin
        case(T)
            12'h0001: begin // LSB
                ARF_OutCSel = 2'b00; IMU_CS = 1'b1; IMU_LH = 1'b0; // Fetch icin acik
            end
            12'h0002: begin // MSB + PC INC
                ARF_FunSel = 2'b10; ARF_RegSel = 3'b011; 
                IMU_CS = 1'b1; IMU_LH = 1'b1; // Fetch icin acik
            end
            
            12'h0004: begin 
                if (Opcode <= 6'd6) begin // BRANCH
                    IMU_CS = 1'b1; // Adresi okumak icin IMUOut kablosunu Ac!
                    if (Opcode == 6'd0 || (Opcode == 6'd1 && Z == 0) || (Opcode == 6'd2 && Z == 1) ||
                       (Opcode == 6'd3 && N != O) || (Opcode == 6'd4 && N == O && Z == 0) ||
                       (Opcode == 6'd5 && (N != O || Z == 1)) || (Opcode == 6'd6 && N == O)) begin
                        ARF_FunSel = 2'b01; ARF_RegSel = 3'b011;
                    end
                    T_Reset = 1'b1;
                end
                else if (Opcode == 6'd23) begin // IMM 
                    IMU_CS = 1'b1; // Immediati okumak icin IMUOut kablosunu Ac!
                    RF_FunSel = 2'b01; RF_RegSel = Decoded_IMM_DST;
                    T_Reset = 1'b1;
                end
                else if (Opcode == 6'd7 || Opcode == 6'd8) begin // INC / DEC Asama 1
                    if (SrcReg1[2] == 1'b0) begin 
                        ARF_OutCSel = SrcReg1[1:0];
                        if (DestReg[2]) begin RF_FunSel=2'b01; RF_RegSel=Decoded_DSTREG; end
                        else begin ARF_FunSel=2'b01; ARF_RegSel=Decoded_ARF_DST; end
                    end else begin 
                        if (DestReg[2]) begin RF_FunSel=2'b01; RF_RegSel=Decoded_DSTREG; end
                        else begin ARF_FunSel=2'b01; ARF_RegSel=Decoded_ARF_DST; end
                    end
                end
                else begin // DIGER TUM KOMUTLAR 
                    if (SrcReg1[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg1[1:0];
                        MuxASel = 2'b01; RF_FunSel = 2'b01; RF_ScrSel = 4'b0111; // S1 Kurulum
                    end
                end
            end
            
            12'h0008: begin 
                if (Opcode == 6'd7 || Opcode == 6'd8) begin
                    if (DestReg[2]) begin
                        RF_FunSel = (Opcode==6'd7) ? 2'b10 : 2'b11; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        ARF_FunSel = (Opcode==6'd7) ? 2'b10 : 2'b11; ARF_RegSel = Decoded_ARF_DST;
                    end
                end
                else if (Opcode >= 6'd15 && Opcode <= 6'd21) begin
                    if (SrcReg2[2] == 1'b0) begin 
                        ARF_OutCSel = SrcReg2[1:0];
                        MuxASel = 2'b01; RF_FunSel = 2'b01; RF_ScrSel = 4'b1011; // S2 Kurulum
                    end
                end
                else begin
                    if (Opcode != 6'd22) ALU_WF = 1'b1; 
                    
                    if (DestReg[2] == 1'b1) begin
                        RF_FunSel = 2'b01; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        ARF_FunSel = 2'b01; ARF_RegSel = Decoded_ARF_DST;
                    end
                    T_Reset = 1'b1;
                end
            end
            
            12'h0010: begin 
                if (Opcode == 6'd7 || Opcode == 6'd8) begin
                    if (DestReg[2]) begin 
                        RF_OutASel = {1'b0, DestReg[1:0]}; ALU_WF = 1'b1; // Bayraklari guncelle
                    end
                    T_Reset = 1'b1;
                end
                else begin 
                    ALU_WF = 1'b1;
                    
                    if (DestReg[2] == 1'b1) begin
                        RF_FunSel = 2'b01; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        ARF_FunSel = 2'b01; ARF_RegSel = Decoded_ARF_DST;
                    end
                    T_Reset = 1'b1;
                end
            end
        endcase
    end
end

// =========================================================================
// 2. SEKANSİYEL BLOK: State Machine (T Geçişleri)
// =========================================================================
always @(posedge Clock) begin
    if(!Reset) begin
        T <= 12'h0001;
    end else begin
        case(T)
            12'h0001: T <= 12'h0002;
            12'h0002: T <= 12'h0004;
            12'h0004: begin
                if (Opcode <= 6'd6 || Opcode == 6'd23) T <= 12'h0001; 
                else T <= 12'h0008; 
            end
            12'h0008: begin
                if ((Opcode >= 6'd9 && Opcode <= 6'd14) || Opcode == 6'd22) T <= 12'h0001; 
                else T <= 12'h0010; 
            end
            12'h0010: T <= 12'h0001; 
            default:  T <= 12'h0001;
        endcase
    end
end

endmodule