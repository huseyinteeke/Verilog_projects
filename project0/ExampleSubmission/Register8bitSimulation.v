`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineer: 
// Project Name: BLG222E Project 0 Simulation
//////////////////////////////////////////////////////////////////////////////////

module Register8bitSimulation();
    reg[7:0] I;
    reg E;
    reg[1:0] FunSel;
    wire[7:0] Q;
    integer test_no;
    
    CrystalOscillator clk();
    Register8bit R(.I(I), .E(E), .FunSel(FunSel), .Clock(clk.clock), .Q(Q));  
    FileOperation F();
    
    initial begin
        F.SimulationName ="Register8bit";
        F.InitializeSimulation(1);
        clk.clock = 0;
        
        //Test 1
        test_no = 1; 
        R.Q=8'h25; FunSel=2'b00; I=8'h72;  E=0; #5;
        clk.Clock();
        F.CheckValues(R.Q,8'h25, test_no, "Q");
        
        //Test 2 
        test_no = 2;
        R.Q=8'h25; FunSel=2'b00; E=1; #5;
        clk.Clock();
        F.CheckValues(R.Q,8'h24, test_no, "Q"); 
        
        //Test 3 
        test_no = 3;
        R.Q=8'h25; FunSel=2'b01; E=0; #5;
        clk.Clock();
        F.CheckValues(R.Q,8'h25, test_no, "Q");
        
        //Test 4 
        test_no = 4;
        R.Q=8'h25; FunSel=2'b01; E=1; #5;
        clk.Clock();
        F.CheckValues(R.Q,8'h26, test_no, "Q"); 

        // you can add more tests here        
        
        F.FinishSimulation();
    end
endmodule