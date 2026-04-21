`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineer:
// Project Name: BLG222E Project 2 Simulation Master (50 TESTS)
//////////////////////////////////////////////////////////////////////////////////

module CPUSystemSimulation();
    wire [11:0] T;
    integer test_no;
    integer clock_count;
    wire clock;
    wire reset;
   
    wire[5:0] Opcode;
    wire[1:0] RegSel;
    wire[7:0] Address;
    wire[2:0] DestReg;
    wire[2:0] SrcReg1;
    wire[2:0] SrcReg2;

    CrystalOscillator clk();
    ResetGenerator rg();

    CPUSystem CPUSys(
        .Clock(clk.clock),
        .Reset(rg.reset),
        .T(T) 
    ); 
    FileOperation F();
    
    assign clock = clk.clock;
    assign reset = rg.reset;
    
    task ClearRegisters;
        begin
            clock_count = 0;
            CPUSys.ALUSys.RF.R1.Q = 16'h0; CPUSys.ALUSys.RF.R2.Q = 16'h0;
            CPUSys.ALUSys.RF.R3.Q = 16'h0; CPUSys.ALUSys.RF.R4.Q = 16'h0;
            CPUSys.ALUSys.RF.S1.Q = 16'h0; CPUSys.ALUSys.RF.S2.Q = 16'h0;
            CPUSys.ALUSys.RF.S3.Q = 16'h0; CPUSys.ALUSys.RF.S4.Q = 16'h0;
            CPUSys.ALUSys.ARF.PC.Q = 16'h0; CPUSys.ALUSys.ARF.AR.Q = 16'h0;
            CPUSys.ALUSys.ARF.SP.Q = 16'h00FF;
            CPUSys.ALUSys.ALU.FlagsOut = 4'b0000;
            CPUSys.ALUSys.DMU.DR.DROut = 16'h0;
            CPUSys.ALUSys.IMU.IR.IROut = 16'h0;
        end
    endtask
        
    task SetRegisters;
        input [15:0] value;
        begin
            CPUSys.ALUSys.ARF.PC.Q = value; CPUSys.ALUSys.ARF.AR.Q = value;
            CPUSys.ALUSys.ARF.SP.Q = value; CPUSys.ALUSys.RF.R1.Q = value;
            CPUSys.ALUSys.RF.R2.Q = value; CPUSys.ALUSys.RF.R3.Q = value;
            CPUSys.ALUSys.RF.R4.Q = value; CPUSys.ALUSys.RF.S1.Q = value;
            CPUSys.ALUSys.RF.S2.Q = value; CPUSys.ALUSys.RF.S3.Q = value;
            CPUSys.ALUSys.RF.S4.Q = value; CPUSys.ALUSys.DMU.DR.DROut = 16'h0;
            CPUSys.ALUSys.IMU.IR.IROut = 16'h0;
        end
    endtask

    task SetALUFlags;
        input [3:0] value;
        begin
            CPUSys.ALUSys.ALU.FlagsOut = value; // Z=Bit3, C=Bit2, N=Bit1, O=Bit0
        end
    endtask

    task SetRegistersRx;
        begin
            CPUSys.ALUSys.RF.R1.Q = 16'h2312; CPUSys.ALUSys.RF.R2.Q = 16'h6789;
            CPUSys.ALUSys.RF.R3.Q = 16'h8894; CPUSys.ALUSys.RF.R4.Q = 16'hF210;
        end
    endtask

    task DisableAll;
        begin
            CPUSys.RF_RegSel = 4'b1111; CPUSys.RF_ScrSel = 4'b1111;
            CPUSys.ARF_RegSel = 3'b111; CPUSys.ALU_WF = 0;
            CPUSys.IMU_CS = 0; CPUSys.DMU_CS = 0; CPUSys.T_Reset = 1;
        end
    endtask
    
    initial begin
        F.SimulationName ="CPUSystem";
        F.InitializeSimulation(0);
        clk.clock = 0;
        
        //Test 1: Reset Test
        test_no = 1; clock_count = 0; DisableAll(); ClearRegisters();
        SetRegisters(16'h7777); F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h7777, test_no, "R2");
        rg.ActivateReset(); clk.Clock(); rg.DeactivateReset();
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h0000, test_no, "R2");
        CPUSys.ALUSys.ARF.PC.Q = 16'h0056;

        //Test 2: BGT 0x11
        test_no = 2; ClearRegisters(); CPUSys.ALUSys.IMU.IR.IROut = 16'h1011; 
        SetALUFlags(4'b0000); CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0011, test_no, "PC");

        //Test 3: DEC R1, R2
        //Test 3: DEC R2
        test_no = 3; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h0001; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h22D0; CPUSys.T = 12'b0000_0000_0100; // 2250 YERİNE 22D0 YAPILDI
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h0000, test_no, "R2");
        //Test 4: LSL R2, R2
        test_no = 4; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h0002; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h26D0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h0004, test_no, "R2");
        
        //Test 5: ADD PC, AR, SP
        test_no = 5; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'h3550; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h4CA6; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h364F, test_no, "PC"); // 3550 + 00FF = 364F
        
        //Test 6: MOV AR, R4
        test_no = 6; ClearRegisters(); SetRegistersRx();
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5970; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.AR.Q, 16'hF210, test_no, "AR"); 

        //Test 7: IMM R1, 0x01
        test_no = 7; ClearRegisters(); SetRegistersRx(); SetALUFlags(4'b1111);
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5C01; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0001, test_no, "R1");

        //Test 8: AND R3, R1, R2
        test_no = 8; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h0F0F; CPUSys.ALUSys.RF.R2.Q = 16'h3333;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h3F4A; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h0303, test_no, "R3");

        //Test 9: BEQ 0x55
        test_no = 9; ClearRegisters(); SetALUFlags(4'b1000); 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0855; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0055, test_no, "PC");

        //Test 10: SUB R4, AR, SP
        test_no = 10; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'h0010; CPUSys.ALUSys.ARF.SP.Q = 16'h0005;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h57A6; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R4.Q, 16'h000B, test_no, "R4");

        //Test 11: NOT R1, R2
        test_no = 11; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'hA5A5; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h3A50; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h5A5A, test_no, "R1");

        //Test 12: INC SP
        test_no = 12; ClearRegisters(); CPUSys.ALUSys.ARF.SP.Q = 16'h00FF; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1DB0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.SP.Q, 16'h0100, test_no, "SP");

        //Test 13: CSL R1, R2 
        test_no = 13; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h8001; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h3250; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0003, test_no, "R1(CSL)");

        //Test 14: CSR R2, R3
        test_no = 14; ClearRegisters(); CPUSys.ALUSys.RF.R3.Q = 16'h0003; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h36E0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h8001, test_no, "R2(CSR)");

        //Test 15: ADC R3, R1, R2 
        test_no = 15; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h0010; CPUSys.ALUSys.RF.R2.Q = 16'h0005; SetALUFlags(4'b0100); 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h534A; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h0016, test_no, "R3(ADC)");

        //Test 16: ORR R4, AR, SP
        test_no = 16; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'h0A0A; CPUSys.ALUSys.ARF.SP.Q = 16'hA0A0;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h43A6; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R4.Q, 16'hAAAA, test_no, "R4(ORR)");

        //Test 17: NAND R1, R4, R4
        test_no = 17; ClearRegisters(); CPUSys.ALUSys.RF.R4.Q = 16'h00FF; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h4A7E; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'hFF00, test_no, "R1(NAND)");

        //Test 18: INC R3 
        test_no = 18; ClearRegisters(); CPUSys.ALUSys.RF.R3.Q = 16'h1000; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1F60; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h1001, test_no, "R3(INC)");

        //Test 19: INC R2, R1 
        test_no = 19; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h0050; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1EC0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h0051, test_no, "R2(INC-Diff)");

        //Test 20: INC AR 
        test_no = 20; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'h0555; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1D20; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.AR.Q, 16'h0556, test_no, "AR(INC)");

        //Test 21: LSR R3, AR 
        test_no = 21; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'h0004; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2B20; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h0002, test_no, "R3(LSR)");

        //Test 22: DEC SP 
        test_no = 22; ClearRegisters(); CPUSys.ALUSys.ARF.SP.Q = 16'h00FF; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h21B0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.SP.Q, 16'h00FE, test_no, "SP(DEC)");

        //Test 23: ADD Carry Flag Test (0x8000 + 0x8000 = 0x0000)
        test_no = 23; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h8000; CPUSys.ALUSys.RF.R2.Q = 16'h8000;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h4E4A; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0000, test_no, "R1(ADD-Carry)");

        //Test 24: BLT 0x44 (Negatif Durumda Dallanma)
        test_no = 24; ClearRegisters(); SetALUFlags(4'b0010); // N=1
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0C44; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0044, test_no, "PC(BLT)");

        //Test 25: ASR R1, R2 (İşaret Koruma)
        test_no = 25; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h8004; 
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2E50; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'hC002, test_no, "R1(ASR)");

        //Test 26: MOV PC, R2
        test_no = 26; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'hABCD;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5850; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'hABCD, test_no, "PC(MOV)");

        //Test 27: XOR R4, R1, R1 (Sıfırlama)
        test_no = 27; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'hDEAD;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h47C8; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R4.Q, 16'h0000, test_no, "R4(XOR)");

        //Test 28: IMM R3, 0xCC 
        test_no = 28; ClearRegisters();
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5ECC; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h00CC, test_no, "R3(IMM)");

        //Test 29: BNE Taken 0x77
        test_no = 29; ClearRegisters(); SetALUFlags(4'b0000); // Z=0
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0477; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0077, test_no, "PC(BNE Taken)");

        //Test 30: BNE Not Taken 0x77
        test_no = 30; ClearRegisters(); SetALUFlags(4'b1000); // Z=1
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0477; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0000, test_no, "PC(BNE Not)");

        //Test 31: BEQ Taken 0x88
        test_no = 31; ClearRegisters(); SetALUFlags(4'b1000); // Z=1
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0888; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0088, test_no, "PC(BEQ Taken)");

        //Test 32: BEQ Not Taken 0x88
        test_no = 32; ClearRegisters(); SetALUFlags(4'b0000); // Z=0
        CPUSys.ALUSys.IMU.IR.IROut = 16'h0888; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0000, test_no, "PC(BEQ Not)");

        //Test 33: BGT Not Taken 0x99
        test_no = 33; ClearRegisters(); SetALUFlags(4'b0010); // N=1 (N!=O)
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1099; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0000, test_no, "PC(BGT Not)");

        //Test 34: BLE Taken 0xAA
        test_no = 34; ClearRegisters(); SetALUFlags(4'b0010); // N=1 (N!=O)
        CPUSys.ALUSys.IMU.IR.IROut = 16'h14AA; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h00AA, test_no, "PC(BLE Taken)");

        //Test 35: BGE Not Taken 0xBB
        test_no = 35; ClearRegisters(); SetALUFlags(4'b0010); // N=1, O=0
        CPUSys.ALUSys.IMU.IR.IROut = 16'h18BB; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h0000, test_no, "PC(BGE Not)");

        //Test 36: LSL R1, R1 (Carry Test)
        test_no = 36; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h8000;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2640; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0000, test_no, "R1(LSL to Zero)");

        //Test 37: ASR Positive 
        test_no = 37; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h4000;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2ED0; CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h2000, test_no, "R2(ASR Pos)");

        //Test 38: SUB to Zero
        test_no = 38; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h000A;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5748; // SUB R3, R1, R1
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h0000, test_no, "R3(SUB Zero)");

        //Test 39: SUB Negative Result
        test_no = 39; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h0005; CPUSys.ALUSys.RF.R2.Q = 16'h000A;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h57CA; // SUB R4, R1, R2
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R4.Q, 16'hFFFB, test_no, "R4(SUB Neg)");

        //Test 40: Overflow ADD
        test_no = 40; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h7FFF; CPUSys.ALUSys.RF.R2.Q = 16'h0001;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h4E4A; // ADD R1, R1, R2
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h8000, test_no, "R1(ADD Ovf)");

        //Test 41: INC on 0xFFFF
        test_no = 41; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'hFFFF;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1E40; // INC R1
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0000, test_no, "R1(INC Max)");

        //Test 42: DEC on 0x0000
        test_no = 42; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'h0000;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h22D0; // DEC R2
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'hFFFF, test_no, "R2(DEC Min)");

        //Test 43: IMM R4, 0xDD 
        test_no = 43; ClearRegisters();
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5FDD; // IMM R4
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R4.Q, 16'h00DD, test_no, "R4(IMM)");

        //Test 44: MOV AR, SP 
        test_no = 44; ClearRegisters(); CPUSys.ALUSys.ARF.SP.Q = 16'hAABB;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h5930; // MOV AR, SP
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.AR.Q, 16'hAABB, test_no, "AR(MOV from SP)");

        //Test 45: MOV SP, AR 
        test_no = 45; ClearRegisters(); CPUSys.ALUSys.ARF.AR.Q = 16'hCCDD;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h59A0; // MOV SP, AR
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.SP.Q, 16'hCCDD, test_no, "SP(MOV from AR)");

        //Test 46: AND to Zero
        test_no = 46; ClearRegisters(); CPUSys.ALUSys.RF.R2.Q = 16'hAAAA; CPUSys.ALUSys.RF.R3.Q = 16'h5555;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h3E5C; // AND R1, R2, R3
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0000, test_no, "R1(AND Zero)");

        //Test 47: NAND ARF to RF (The Ultimate Mix)
        //Test 48: ORR Max
        test_no = 48; ClearRegisters(); CPUSys.ALUSys.RF.R1.Q = 16'h0F0F; CPUSys.ALUSys.RF.R2.Q = 16'hF0F0;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h424A; // 404A YERİNE 424A YAPILDI (Hedef R1)
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'hFFFF, test_no, "R1(ORR Max)");


        //Test 49: XOR Same Register (0xFFFF)
        //Test 49: XOR Same Register (0xFFFF)
        test_no = 49; ClearRegisters(); CPUSys.ALUSys.RF.R3.Q = 16'hFFFF;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h476C; // 476E YERİNE 476C YAPILDI (Kaynak2 R3)
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.RF.R3.Q, 16'h0000, test_no, "R3(XOR Self)");

        //Test 50: The Final Boss (INC PC directly)
        test_no = 50; ClearRegisters(); CPUSys.ALUSys.ARF.PC.Q = 16'h1234;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h1C00; // INC PC (Dest:000, Src:000)
        CPUSys.T = 12'b0000_0000_0100;
        while (CPUSys.T != 12'b0000_0000_0001 && clock_count <= 15) begin clk.Clock(); clock_count = clock_count + 1; end
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q, 16'h1235, test_no, "PC(INC Final)");

        F.FinishSimulation();
    end
endmodule