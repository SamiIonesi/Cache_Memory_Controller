`timescale 1ns/1ps

module tb_top_system();
    logic clk;
    logic rst;

    Top_System uut (
        .clk(clk),
        .rst(rst)
    );

    // (100MHz -> 10ns)
    always #5 clk = ~clk;

    initial begin
        $display("------------------------------------------------------------");
        $display("Time\t Stare FSM \t CPU_ADDR \t HIT \t RDY \t DATA");
        $display("------------------------------------------------------------");
        
        $monitor("%t \t %b \t %h \t %b \t %b \t %h", 
                 $time, 
                 uut.memory_cache.controller.state, 
                 uut.processor.add, 
                 uut.memory_cache.controller.is_hit, 
                 uut.cache_rdy,
                 uut.cache_to_cpu_data);
    end

    initial begin
        // 
        clk = 0;
        rst = 1;
        #25;
        rst = 0;
        
        //Let enough time for the CPU to run it's states
        #3000;

        $display("------------------------------------------------------------");
        $display("Simulare finalizată.");
        $finish;
    end

endmodule