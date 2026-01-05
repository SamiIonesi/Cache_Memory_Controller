// ==========================================================
// Testbench
// ==========================================================
module cache_top_tb;
    reg clk, rst;
    reg [3:0] req, wr;
    reg [4:0] addr0, addr1, addr2, addr3;
    reg [7:0] data0, data1, data2, data3;
    wire [7:0] dout0, dout1, dout2, dout3;

    cache_top dut(clk, rst, req, wr, addr0, addr1, addr2, addr3, data0, data1, data2, data3, dout0, dout1, dout2, dout3);

    always #5 clk = ~clk;

    initial begin
        // Initializare
        clk = 0; rst = 1; req = 0; wr = 0;
        {addr0, addr1, addr2, addr3} = 0;
        {data0, data1, data2, data3} = 0;
        
        #15 rst = 0;
        #12;

        // --- TEST 1: Citire B0 (După scriere inițială) ---
        $display("T=%0t: [TEST 1] Scriere B0 la Adresa 3 cu AA", $time);
        addr0 = 5'd3; data0 = 8'hAA; wr[0] = 1; req[0] = 1;
        #10 req[0] = 0;
        #250;

        $display("T=%0t: [TEST 2] Citire B0 de la Adresa 3", $time);
        addr0 = 5'd3; wr[0] = 0; req[0] = 1;
        #10 req[0] = 0;
        #100;
        $display("T=%0t: [REZULTAT] dout0 = %h (Așteptat AA)", $time, dout0);

        #100;

        // --- TEST 3: Prioritate Conflict (B1, B2, B3 cer simultan) ---
        $display("T=%0t: [TEST 3] Conflict Prioritate B1, B2, B3", $time);
        addr1 = 5'd10; data1 = 8'h11; wr[1] = 1; req[1] = 1;
        addr2 = 5'd11; data2 = 8'h22; wr[2] = 1; req[2] = 1;
        addr3 = 5'd12; data3 = 8'h33; wr[3] = 1; req[3] = 1;
        #10 {req[1], req[2], req[3]} = 0;
        #100;

        #250;

        // --- TEST 4: Citire rezultat B1 (Cel care ar fi trebuit să câștige) ---
        $display("T=%0t: [TEST 4] Citire B1 de la Adresa 10", $time);
        addr1 = 5'd10; wr[1] = 0; req[1] = 1;
        #10 req[1] = 0;
        #100;
        $display("T=%0t: [REZULTAT] dout1 = %h (Așteptat 11)", $time, dout1);

        #50;
        $display("Simulare terminată.");
        $finish;
    end
endmodule