`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 2 - Array Max Finder Simulation
//////////////////////////////////////////////////////////////////////////////////

module CPUSystemSimulationArrayMax();
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
            CPUSys.ALUSys.RF.R1.Q = 32'h0;
            CPUSys.ALUSys.RF.R2.Q = 32'h0;
            CPUSys.ALUSys.RF.R3.Q = 32'h0;
            CPUSys.ALUSys.RF.R4.Q = 32'h0;
            CPUSys.ALUSys.RF.S1.Q = 32'h0;
            CPUSys.ALUSys.RF.S2.Q = 32'h0;
            CPUSys.ALUSys.RF.S3.Q = 32'h0;
            CPUSys.ALUSys.RF.S4.Q = 32'h0;
            CPUSys.ALUSys.ARF.PC.Q = 16'h0;
            CPUSys.ALUSys.ARF.AR.Q = 16'h0;
            CPUSys.ALUSys.ARF.SP.Q = 16'h00FF;
            CPUSys.ALUSys.DMU.DR.DROut = 16'h0;
            CPUSys.ALUSys.IMU.IR.IROut = 16'h0;
            CPUSys.ALUSys.ALU.FlagsOut = 4'b0000;
        end
    endtask

    task DisableAll;
        begin
            CPUSys.RF_RegSel = 4'b1111;
            CPUSys.RF_ScrSel = 4'b1111;
            CPUSys.ARF_RegSel = 3'b111;
            CPUSys.ALU_WF = 0;
            CPUSys.IMU_CS = 0;
            CPUSys.DMU_CS = 0;
            CPUSys.T_Reset = 1;
        end
    endtask

    assign Opcode = CPUSys.Opcode;
    assign RegSel = CPUSys.RegSel;
    assign Address = CPUSys.Address;
    assign DestReg = CPUSys.DestReg;
    assign SrcReg1 = CPUSys.SrcReg1;
    assign SrcReg2 = CPUSys.SrcReg2;
    
    initial begin
        F.SimulationName ="CPUSystemSimulationArrayMax";
        F.InitializeSimulation(0);
        clk.clock = 0;

        test_no = 1;
        DisableAll();
        ClearRegisters();
        
// Dizi: +127, -128, -2, 0, +126, -1
        // Beklenen En Büyük: +127 (0x007F)
CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB0] = 8'h34; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB1] = 8'h12; // 0x1234 (4660)
                CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB2] = 8'hAA; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB3] = 8'h55; // 0x55AA (21930) <-- MAX İRTİFA
                CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB4] = 8'h00; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB5] = 8'h00; // 0x0000 (0)
                CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB6] = 8'h21; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB7] = 8'h43; // 0x4321 (17185)
                CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB8] = 8'h00; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hB9] = 8'hFF; // 0xFF00 (-256) Sensör kalibrasyon dalgalanması
                CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBA] = 8'hA9; CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBB] = 8'h55;
        // CheckValues'u LSB = 7F, MSB = 00, R2 = 007F olacak şekilde güncellemen gerekir.
        // Sonucun yazılacağı BC ve BD adreslerini temizle
        CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBC] = 8'h00; 
        CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBD] = 8'h00; 

        // İşlemciyi 0x00 adresinden başlat
        CPUSys.ALUSys.ARF.PC.Q = 16'h0000;
        CPUSys.T = 12'b0000_0000_0001;
        
        // =========================================================
        // SİMÜLASYON DÖNGÜSÜ
        // =========================================================
        while (test_no <= 200 && clock_count <= 5000) begin
            clk.Clock();
            clock_count = clock_count + 1;
            
            if (CPUSys.T == 12'b0000_0000_0001)
                test_no = test_no + 1;

            if (CPUSys.ALUSys.ARF.PC.Q == 16'h00A6 && CPUSys.T == 12'b0000_0000_0001) begin
                repeat(6) begin clk.Clock(); end 
                clock_count = 6000; 
            end
        end
        
        test_no = 1;
        F.CheckValues(CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBC], 8'h2A, test_no, "MEM[0xBC] (Max Value LSB)");
        F.CheckValues(CPUSys.ALUSys.DMU.DM.RAM_DATA[8'hBD], 8'h00, test_no, "MEM[0xBD] (Max Value MSB)");
        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'h002A, test_no, "R2 (Max Value in Register)");
        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0000, test_no, "R1 (Loop Counter=0)");

        F.FinishSimulation();
    end

endmodule