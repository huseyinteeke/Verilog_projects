`timescale 1ns / 1ps

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);

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
reg T_Reset;


wire [15:0] IROut;
wire Z, C, N, O;

// Instruction Decode
wire [5:0] Opcode   = IROut[15:10];
wire [1:0] RegSel   = IROut[9:8];
wire [7:0] Address  = IROut[7:0];
wire [2:0] DestReg  = IROut[9:7];
wire [2:0] SrcReg1  = IROut[6:4];
wire [2:0] SrcReg2  = IROut[3:1];


// RF Muxes
wire [2:0] OutA_Mapped = {1'b0, SrcReg1[1:0]};
wire [2:0] OutB_Mapped = {1'b0, SrcReg2[1:0]};

reg [3:0] Decoded_DSTREG;
reg [2:0] Decoded_ARF_DST;
reg [3:0] Decoded_IMM_DST;
reg [4:0] Decoded_SREG1;
reg [4:0] Decoded_ARF_SREG1;

// DECODER BLOK 
always @(*) begin
    case(DestReg)
        3'b100: Decoded_DSTREG = 4'b0111; // R1
        3'b101: Decoded_DSTREG = 4'b1011; // R2
        3'b110: Decoded_DSTREG = 4'b1101; // R3
        3'b111: Decoded_DSTREG = 4'b1110; // R4
        default: Decoded_DSTREG = 4'b1111; 
    endcase
    
    case(DestReg)
        3'b000, 3'b001: Decoded_ARF_DST = 3'b011; // PC
        3'b010:         Decoded_ARF_DST = 3'b110; // AR
        3'b011:         Decoded_ARF_DST = 3'b101; // SP
        default:        Decoded_ARF_DST = 3'b111; 
    endcase
    
    case(RegSel)
        2'b00: Decoded_IMM_DST = 4'b0111; // R1
        2'b01: Decoded_IMM_DST = 4'b1011; // R2
        2'b10: Decoded_IMM_DST = 4'b1101; // R3
        2'b11: Decoded_IMM_DST = 4'b1110; // R4
    endcase

    case(SrcReg1)
        3'b100: Decoded_SREG1  = 4'b0111; // R1
        3'b101: Decoded_SREG1 = 4'b1011; // R2
        3'b110: Decoded_SREG1 = 4'b1101; // R3
        3'b111: Decoded_SREG1 = 4'b1110; // R4
        default: Decoded_SREG1 = 4'b1111; 
    endcase
    
    case(SrcReg1)
        3'b000, 3'b001: Decoded_ARF_SREG1 = 3'b011; // PC
        3'b010:         Decoded_ARF_SREG1 = 3'b110; // AR
        3'b011:         Decoded_ARF_SREG1 = 3'b101; // SP
        default:        Decoded_ARF_SREG1 = 3'b111; 
    endcase



end

ArithmeticLogicUnitSystem ALUSys(
    .ALU_FunSel(ALU_FunSel), .RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel),
    .RF_FunSel(RF_FunSel), .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel),
    .Clock(Clock), .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel),
    .ALU_WF(ALU_WF), .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel),
    .ARF_RegSel(ARF_RegSel), .ARF_FunSel(ARF_FunSel), .IMU_LH(IMU_LH),
    .IMU_CS(IMU_CS), .DMU_CS(DMU_CS), .DMU_WR(DMU_WR), .DMU_FunSel(DMU_FunSel),
    .IROut(IROut), .Z(Z), .C(C), .N(N), .O(O)
);

always @(*) begin

    RF_OutASel  = 3'b000; RF_OutBSel  = 3'b000;
    MuxASel     = 2'b00;  MuxBSel     = 2'b00;
    MuxCSel     = 1'b0;   ALU_FunSel  = 4'b0000;
    T_Reset     = 1'b0;

    if (Opcode == 6'd23) begin
        MuxASel = 2'b11; // IMM
    end else if (Opcode <= 6'd6) begin
        MuxBSel = 2'b11; // Branch
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
            RF_OutASel = (SrcReg1[2] == 1'b0) ? 3'b100 : OutA_Mapped; 
            RF_OutBSel = (SrcReg2[2] == 1'b0) ? 3'b101 : OutB_Mapped; 
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

       ALU_WF      = 1'b0;
    ARF_OutCSel = 2'b00;  ARF_OutDSel = 1'b0;
    ARF_FunSel  = 2'b11;  ARF_RegSel  = 3'b111; 
    RF_FunSel   = 2'b11;  RF_RegSel   = 4'b1111; RF_ScrSel   = 4'b1111; 
    IMU_CS      = 1'b0;   IMU_LH      = 1'b0;
    DMU_CS      = 1'b1;   DMU_WR      = 1'b0; DMU_FunSel  = 1'b0;

    if (!Reset) begin
        ARF_FunSel = 2'b00; ARF_RegSel = 3'b000; 
        RF_FunSel  = 2'b00; RF_RegSel  = 4'b0000; RF_ScrSel = 4'b0000; 
    end else begin
        case(T)
            12'h0001: begin 
                IMU_CS = 1'b1; IMU_LH = 1'b0;
                ARF_RegSel = 3'b011; ARF_FunSel = 2'b10;
            end
            12'h0002: begin 
                ARF_FunSel = 2'b10; ARF_RegSel = 3'b011; 
                IMU_CS = 1'b1; IMU_LH = 1'b1;
            end
            
            12'h0004: begin 
                IMU_CS = 1'b0;
                if (Opcode <= 6'd6) begin 
                    IMU_CS = 1'b1; 
                    if (Opcode == 6'd0 || (Opcode == 6'd1 && Z == 0) || (Opcode == 6'd2 && Z == 1) ||
                       (Opcode == 6'd3 && N != 0) || (Opcode == 6'd4 && N == 0 && Z == 0) ||
                       (Opcode == 6'd5 && (N != 0 || Z == 1)) || (Opcode == 6'd6 && N == 0)) begin
                        ARF_FunSel = 2'b01; ARF_RegSel = 3'b011;
                    end
                    T_Reset = 1'b1;
                end
                else if (Opcode == 6'd23) begin 
                    IMU_CS = 1'b1; 
                    RF_FunSel = 2'b01; RF_RegSel = Decoded_IMM_DST;
                    T_Reset = 1'b1;
                end
                else if (Opcode == 6'd7 || Opcode == 6'd8) begin 
                    if (SrcReg1[2] == 1'b0) begin 
                        ARF_OutCSel = SrcReg1[1:0];
                        if (DestReg[2]) begin MuxASel=2'b01; RF_FunSel=2'b01; RF_RegSel=Decoded_DSTREG; end
                        else begin MuxBSel=2'b01; ARF_FunSel=2'b01; ARF_RegSel=Decoded_ARF_DST; end
                    end else begin 
                        RF_OutASel = OutA_Mapped; ALU_FunSel = 4'b0000;
                        if (DestReg[2]) begin MuxASel=2'b00; RF_FunSel=2'b01; RF_RegSel=Decoded_DSTREG; end
                        else begin MuxBSel=2'b00; ARF_FunSel=2'b01; ARF_RegSel=Decoded_ARF_DST; end
                    end
                end 
                else if(Opcode == 6'd24)  // POP (SP <- SP + 1)
                begin                     
                    ARF_OutDSel = 1'b1;         
                    ARF_RegSel  = 3'b101;
                    ARF_FunSel  = 2'b10;          
                    DMU_CS = 1'b0; 
                    DMU_WR = 1'b0;
                    RF_FunSel   = 2'b00;       
                    T_Reset     = 1'b0;
                end


                else if(Opcode == 6'd25) //PSH M[SP] <- PC 
                begin
                    
                    ARF_OutDSel = 1'b1;         // Adres = SP (0xFF)
                    ARF_RegSel  = 3'b111;       // SP Kilitli (Yazma yok)
                    ARF_FunSel  = 2'b00;        // İşlemsiz
                    
                    RF_OutASel  = 3'b000;       // R1 seçili (veya Decoded_RSEL)
                    ALU_FunSel  = 4'b0000;      // İşlemsiz geç
                    MuxCSel     = 1'b1;         // MSB (23) seçili
                    
                    DMU_CS      = 1'b1; 
                    DMU_WR      = 1'b1;         // 0xFF'e 23 YAZ!
                    T_Reset     = 1'b0;
                
                end


                else if(Opcode == 6'd26) begin // CALL - T=4 (PC'yi Hazırla)
                    // PC'yi 006F'den 0070'e artır. Henüz başka bir yere yazmıyoruz.
                    ARF_OutCSel = 2'b00;       // OutC = PC
                    MuxASel     = 2'b01;       // MUXA = OutC
                    
                    RF_ScrSel   = 4'b0111;     // Sadece S1 Seçili [cite: 54]
                    RF_FunSel   = 2'b01;       // LOAD
                    RF_RegSel   = 4'b1111;     // Diğer yazmaçları kilitliyoruz [cite: 52]
                    T_Reset     = 1'b0;
                end

                else if(Opcode == 6'd27) //RET
                begin
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 2'b10;
                    DMU_CS     = 1'b0;
                end


                else if(Opcode == 6'd28) //LDR
                begin

                    ARF_OutDSel = 1'b0;
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b0; //READ
                    DMU_FunSel  = 1'b0; //LSB
                end


                else if(Opcode == 6'd29) //STR
                begin
                    ARF_OutDSel = 1'b0; //AR
                    DMU_CS      = 1'b0;
                    if(Decoded_SREG1 != 4'b1111) //RF To mem
                    begin
                        RF_OutASel = Decoded_SREG1;
                        ALU_FunSel = 4'b0000;
                        MuxCSel    = 1'b0; //LSB
                    end
                    else //ARF to mem
                    begin

                        ARF_OutCSel = Decoded_ARF_SREG1;
                        MuxASel     = 2'b01;
                        RF_RegSel   = 4'b1111;
                        RF_ScrSel   = 4'b0111;
                        RF_FunSel = 2'b01;
                    end
                end



                else begin 
                    if (SrcReg1[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg1[1:0];
                        MuxASel = 2'b01; RF_FunSel = 2'b01; RF_ScrSel = 4'b0111; 
                    end
                end
            end
            
            12'h0008: begin 
                if (Opcode == 6'd7 || Opcode == 6'd8) begin
                    if (DestReg[2]) begin
                        RF_OutASel = {1'b0, DestReg[1:0]}; MuxASel = 2'b00; ALU_FunSel = 4'b0000;
                        RF_FunSel = (Opcode==6'd7) ? 2'b10 : 2'b11; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        ARF_OutCSel = DestReg[1:0]; MuxBSel = 2'b01; 
                        ARF_FunSel = (Opcode==6'd7) ? 2'b10 : 2'b11; ARF_RegSel = Decoded_ARF_DST;
                    end
                end
                else if (Opcode >= 6'd15 && Opcode <= 6'd21) begin
                    if (SrcReg2[2] == 1'b0) begin 
                        ARF_OutCSel = SrcReg2[1:0];
                        MuxASel = 2'b01; RF_FunSel = 2'b01; RF_ScrSel = 4'b1011; 
                    end
                end

                else if (Opcode == 6'd24) //POP Read LSB
                begin
                ARF_OutDSel = 1'b1;
                DMU_CS = 1'b1; 
                DMU_FunSel = 1'b0; 
                DMU_WR = 1'b0; 

                ARF_RegSel = 3'b101; 
                ARF_FunSel = 2'b10;         // SP <- SP + 1 
                RF_FunSel   = 2'b00;
                T_Reset = 1'b0;
                end


                else if(Opcode == 6'd25) //PSH M[SP] <- PC 
                begin
                    ARF_OutDSel = 1'b1;         // Adres hala SP
                    ARF_RegSel  = 3'b101;       // SP Seçili
                    ARF_FunSel  = 2'b11;        // SP'yi 1 azalt (0xFF -> 0xFE)
                    
                    RF_OutASel  = 3'b000;       // Veri yolunu DÜŞÜRME, tut!
                    ALU_FunSel  = 4'b0000;
                    MuxCSel     = 1'b1;
                    
                    DMU_CS      = 1'b0;         // RAM KAPALI!
                    DMU_WR      = 1'b0;         // RAM KAPALI!
                    T_Reset     = 1'b0;
                end


                else if(Opcode == 6'd26) begin // CALL - T=8
    // S1'den MSB'yi (00) oku, FD adresine yaz ve SP'yi düşür
                    RF_OutASel  = 3'b100;      // OutA = S1 [cite: 46]
                    ALU_FunSel  = 4'b0000;     // Pass A
                    MuxCSel     = 1'b1;        // MSB (00)
                    
                    ARF_OutDSel = 1'b1;        // Adres = SP (FD)
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b1;        // YAZ
                    
                    ARF_RegSel  = 3'b101;      // Sadece SP Seçili [cite: 84]
                    ARF_FunSel  = 2'b11;       // SP <- SP - 1 (FD -> FC)
                    RF_FunSel   = 2'b00;       // RF'yi kilitle
                    T_Reset     = 1'b0;
                end

                else if(Opcode == 6'd27)  //
                begin
                
                    ARF_OutDSel = 1'b1;
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b0; //READ
                    DMU_FunSel  = 1'b0; //LSB
                end


                else if(Opcode == 6'd28) //LDR increase AR
                begin
                
                ARF_RegSel = 3'b110;
                ARF_FunSel = 2'b10;
                
                end


                else if(Opcode == 6'd29) //STR
                begin
                    ARF_OutDSel = 1'b0; //AR
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b1; //W
                    if(Decoded_SREG1 != 4'b1111) //RF To mem
                    begin
                        RF_OutASel = Decoded_SREG1;
                        ALU_FunSel = 4'b0000;
                        MuxCSel    = 1'b0; //LSB
                    end
                    else //ARF to mem
                    begin

                        RF_OutASel = 3'b100; //Scratch S1
                        ALU_FunSel = 4'b000;
                        MuxCSel    = 1'b0;
                    end
                end




                else begin
                    if (Opcode != 6'd22) ALU_WF = 1'b1; 
                    if (DestReg[2] == 1'b1) begin
                        MuxASel=2'b00; RF_FunSel = 2'b01; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        MuxBSel=2'b00; ARF_FunSel = 2'b01; ARF_RegSel = Decoded_ARF_DST;
                    end
                    T_Reset = 1'b1;
                end
            end
            
            12'h0010: begin 
                if (Opcode == 6'd7 || Opcode == 6'd8) begin
                    if (DestReg[2]) begin RF_OutASel = {1'b0, DestReg[1:0]}; ALU_WF = 1'b1; end
                end

                else if(Opcode == 6'd24) //POP SP + 1 to MSb
                begin
                    ARF_OutDSel = 1'b1;         // Adres = SP (Artık FF)
                    ARF_RegSel  = 3'b111;       // SP KİLİTLİ (Yazmayı kapat)
                    ARF_FunSel  = 2'b00;
                    
                    DMU_CS      = 1'b1;         // RAM AÇIK
                    DMU_WR      = 1'b0;         // SADECE OKU!
                    DMU_FunSel  = 1'b1;         // MSB (Üst 8 bit DR'ye dolsun)
                    
                    RF_FunSel   = 2'b00;
                    T_Reset     = 1'b0;
                end

                else if(Opcode == 6'd25) 
                begin
                    ARF_OutDSel = 1'b1;         // Adres = SP (Artık 0xFE)
                    ARF_RegSel  = 3'b111;       // SP Kilitli (Yazma yok)
                    ARF_FunSel  = 2'b00;
                    
                    RF_OutASel  = 3'b000;       // R1 seçili
                    ALU_FunSel  = 4'b0000;
                    MuxCSel     = 1'b0;         // LSB (12) seçili
                    
                    DMU_CS      = 1'b1; 
                    DMU_WR      = 1'b1;         // 0xFE'ye 12 YAZ!
                    T_Reset     = 1'b0;

                end


                else if(Opcode == 6'd26) begin // CALL - T=16
                    // S1'den LSB'yi (70) oku, FC adresine yaz ve SP'yi düşür
                    RF_OutASel  = 3'b100;      // OutA = S1
                    ALU_FunSel  = 4'b0000;     // Pass A
                    MuxCSel     = 1'b0;        // LSB (70)
                    
                    ARF_OutDSel = 1'b1;        // Adres = SP (FC)
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b1;        // YAZ
                    
                    ARF_RegSel  = 3'b101;      // SP Seçili
                    ARF_FunSel  = 2'b11;       // SP <- SP - 1 (FC -> FB)
                    RF_FunSel   = 2'b00;
                    T_Reset     = 1'b0;
                end


                else if(Opcode == 6'd27)
                begin
                
                    ARF_OutDSel = 1'b1;
                    DMU_CS      = 1'b0;
                    DMU_WR      = 1'b0; //READ

                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 2'b10;

                end




                else if(Opcode == 6'd28) //LDR fill DMUOut
                begin

                    ARF_OutDSel = 1'b0;
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b0; //READ
                    DMU_FunSel  = 1'b1; //MSB
                end


                else if(Opcode == 6'd29) //STR LSB completed increment AR
                begin
                    ARF_OutDSel = 1'b0; //AR
                    DMU_CS      = 1'b0;
                    DMU_WR      = 1'b1; //W
                    ARF_RegSel  = 3'b110;
                    ARF_FunSel  = 2'b10;  
                end


                else begin 
                    ALU_WF = 1'b1;
                    if (DestReg[2] == 1'b1) begin
                        MuxASel=2'b00; RF_FunSel = 2'b01; RF_RegSel = Decoded_DSTREG;
                    end else begin
                        MuxBSel=2'b00; ARF_FunSel = 2'b01; ARF_RegSel = Decoded_ARF_DST;
                    end
                    T_Reset = 1'b1;
                end
            
            end

            12'h0020: begin
                if(Opcode == 6'd24) //POP SP + 1 to MSb
                begin
                
                ARF_OutDSel = 1'b1;         
                ARF_RegSel  = 3'b111;       // SP KİLİTLİ
                ARF_FunSel  = 2'b00;
                
                DMU_CS      = 1'b0;         // RAM İŞİ BİTTİ, KAPAT
                DMU_WR      = 1'b0;
                
                // EĞER SENİN TASARIMDA "Decoded_IMM_DST" KULLANILIYORSA ONU YAZ, 
                // AMA NORMALDE BURASI Decoded_RSEL OLMALIDIR.
                RF_RegSel   = Decoded_IMM_DST; // R2'yi Hedefle
                RF_FunSel   = 2'b01;        // RF LOAD (Yaz)
                MuxASel     = 2'b10;        // DMUOut'u (Data Register çıkışını) seç
                
                T_Reset     = 1'b1;
                end

                else if(Opcode == 6'd25) begin
                    
                    ARF_OutDSel = 1'b1;         // Adres = SP
                    ARF_RegSel  = 3'b101;       // SP Seçili
                    ARF_FunSel  = 2'b11;        // SP'yi 1 azalt (0xFE -> 0xFD)
                    
                    RF_OutASel  = 3'b000;       // Veri yolunu tut
                    ALU_FunSel  = 4'b0000;
                    MuxCSel     = 1'b0;
                    
                    DMU_CS      = 1'b0;         // RAM KAPALI
                    DMU_WR      = 1'b0;         // RAM KAPALI
                    T_Reset     = 1'b1;

                end



                else if(Opcode == 6'd26) begin // CALL - T=32
                    // FİNAL: IMUOut'taki 0036'yı PC'ye yükle ve bitir
                    MuxBSel     = 2'b11;       // MUXB = IMUOut [cite: 289]
                    
                    ARF_RegSel  = 3'b011;      // PC Seçili
                    ARF_FunSel  = 2'b01;       // PC <- MUX B (LOAD)
                    
                    DMU_CS      = 1'b0;
                    DMU_WR      = 1'b0;
                    T_Reset     = 1'b1;        // SIFIRLA VE BAŞA DÖN!
                end


                else if(Opcode == 6'd27) //RET
                begin
                
                    ARF_OutCSel = 1'b1;
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b0; //READ
                    DMU_FunSel  = 1'b1; //MSB

                end




                else if(Opcode == 6'd28) //LDR choose datapath
                begin

                    if(Decoded_DSTREG != 4'b1111) //RF
                    begin
                        MuxASel = 2'b10;
                        RF_FunSel  = 2'b01;
                        RF_RegSel = Decoded_DSTREG;
                    end
                    else //ARF
                    begin
                        MuxBSel = 2'b10;
                        ARF_FunSel = 2'b01;
                        ARF_RegSel = Decoded_ARF_DST;
                    end
                end


                else if(Opcode == 6'd29) //STR
                begin
                    ARF_OutDSel = 1'b0; //AR
                    DMU_CS      = 1'b1;
                    DMU_WR      = 1'b1; //W
                    MuxCSel     = 1'b1; //MSB
                end
            end

            12'h0040: begin
               
                if(Opcode == 6'd26) begin // CALL - T=64 (FİNAL ATLAYIŞ)
                    // IMUOut'taki hedef adresi (0036) MUX B üzerinden PC'ye yükle
                    MuxBSel     = 2'b11;    // MUX B çıkışı = IMUOut (Tablo 9)
                    
                    ARF_RegSel  = 3'b011;   // PC Seçili
                    ARF_FunSel  = 2'b01;    // PC <- MUX B (LOAD)
                    
                    DMU_CS      = 1'b0;     // RAM Kapalı
                    DMU_WR      = 1'b0;
                    T_Reset     = 1'b1;     // İŞLEM BİTTİ, SIFIRLA!
                end

                else if(Opcode == 6'd27) //RET
                begin
                
                    MuxBSel = 2'b10;
                    ARF_RegSel = 3'b011;
                    ARF_FunSel = 2'b01;

                end


                else if(Opcode == 6'd28) //LDR finish
                begin

                    T_Reset = 1'b1;
                end


                else if(Opcode == 6'd29) //STR
                begin
                    T_Reset = 1'b1;
                end

            end

            12'h0080: begin
            if(Opcode == 6'd26) begin // CALL (T=128)
                ARF_OutDSel = 1'b1;
                ARF_RegSel  = 3'b101;  // SP
                ARF_FunSel  = 2'b11;   // SP'yi Azalt (DEC)
                
                DMU_CS      = 1'b0;
                DMU_WR      = 1'b0;
                T_Reset     = 1'b0;
            end


            else if(Opcode == 6'd27) //RET
                begin
                
                    T_Reset = 1'b1;
                end


            end

            12'h0100: begin
                if(Opcode == 6'd26) begin // CALL (T=256)
                    MuxASel     = 2'b11;   // Hedef Adres (IMM / IROut[7:0] vs)
                    ALU_FunSel  = 4'b0000;
                    
                    ARF_RegSel  = 3'b011;  // PC Seçili
                    ARF_FunSel  = 2'b01;   // PC'ye ALU çıkışını Yükle (LOAD)
                    
                    T_Reset     = 1'b1;    // VE FİNAL!
                end
            end
        endcase
    end
end

always @(posedge Clock) begin
    if(!Reset || T_Reset) begin
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
            12'h0010: T <= 12'h0020; 
            12'h0020: T <= 12'h0040;
            12'h0080: T <= 12'h0100; 
            12'h0100: T <= 12'h0001;
            default:  T <= 12'h0001;
        endcase
    end
end
endmodule