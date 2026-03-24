`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2026 02:03:32 PM
// Design Name: 
// Module Name: DataMemorySim
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
//////////////////////////////////////////////////////////////////////////////////
// Testbench for DataMemory Module
//////////////////////////////////////////////////////////////////////////////////

module DataMemory_TB();

    // Modüle girecek sinyaller (reg olarak tanýmlanýr çünkü biz deðer atayacaðýz)
    reg [15:0] Address;
    reg [7:0] Data;
    reg WR;
    reg CS;
    reg Clock;

    // Modülden çýkacak sinyaller (wire olarak tanýmlanýr)
    wire [7:0] MemOut;

    // Test edilecek modülün (UUT - Unit Under Test) çaðrýlmasý
    DataMemory uut (
        .Address(Address),
        .Data(Data),
        .WR(WR),
        .CS(CS),
        .Clock(Clock),
        .MemOut(MemOut)
    );

    // 1. Clock (Saat) Sinyali Üretimi: 10ns periyot (100 MHz)
    always #5 Clock = ~Clock;

    // 2. Test Senaryolarý (Stimulus)
    initial begin
        // Baþlangýç deðerleri
        Clock = 0;
        Address = 16'h0000;
        Data = 8'h00;
        WR = 0;
        CS = 1; // DÝKKAT: Modülün CS=0 ile aktif olduðu için baþlangýçta 1 (kapalý) veriyoruz.

        $display("--- DataMemory Simülasyonu Baþlýyor ---");
        #10; // Sistemin oturmasý için biraz bekle

        // TEST 1: RAM.mem dosyasýndan okuma (Örneðin Adres 0x0015)
        // Eðer RAM.mem dosyanýn 22. satýrýnda (0x15) '07' yazýyorsa, MemOut '07' olmalý.
        $display("\nTEST 1: Adres 0x0015 okunuyor (RAM.mem'den)");
        Address = 16'h0015;
        WR = 0;   // Okuma modu
        CS = 0;   // Çipi aktifleþtir
        #10;      // 1 clock cycle bekle
        $display("Zaman: %0t | Adres: %h | MemOut: %h", $time, Address, MemOut);

        // TEST 2: Belleðe yeni bir veri yazma (Adres 0x00A1'e 0xAA yazalým)
        $display("\nTEST 2: Adres 0x00A1'e '0xAA' yazýlýyor");
        Address = 16'h00A1;
        Data = 8'hAA;
        WR = 1;   // Yazma modu
        CS = 0;   // Çip aktif
        #10;      // Posedge Clock vurmasý için bekle

        // TEST 3: Az önce yazdýðýmýz veriyi geri okuma
        $display("\nTEST 3: Adres 0x00A1 geri okunuyor (0xAA bekleniyor)");
        WR = 0;       // Okuma moduna geri dön
        Data = 8'h00; // Giriþ verisini bilerek bozuyoruz ki okumayý etkilemediðini görelim
        #10;
        $display("Zaman: %0t | Adres: %h | MemOut: %h", $time, Address, MemOut);

        // TEST 4: CS (Chip Select) devre dýþýyken okuma denemesi
        $display("\nTEST 4: CS = 1 (Devre Dýþý) iken okuma deneniyor");
        CS = 1;   // Çipi kapat
        #10;
        $display("Zaman: %0t | Adres: %h | MemOut: %h (Beklenen: zz)", $time, Address, MemOut);

        $display("\n--- Simülasyon Tamamlandý ---");
        $finish; // Simülasyonu durdur
    end

endmodule
