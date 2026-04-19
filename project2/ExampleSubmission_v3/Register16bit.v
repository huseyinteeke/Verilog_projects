`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2026 07:33:26 PM
// Design Name: 
// Module Name: register16bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register16bit(
    input Clock,
    input wire[15:0] I , 
    input wire[1:0] FunSel,
    input wire E,
    output reg[15:0] Q = 16'd0
    );
    
   
    always@(posedge Clock)
    begin
    if(E)
    begin
        case(FunSel)
        2'b00:begin Q <= 16'd0; end
        2'b01:begin Q <= I; end
        2'b10:begin Q <= Q + 1; end
        2'b11:begin Q <= Q - 1; end
        default:begin Q <= 16'd0; end
        endcase
    end
    else begin end
    end
endmodule
