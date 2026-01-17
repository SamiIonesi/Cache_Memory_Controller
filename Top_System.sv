module Top_System (
    input  logic clk,
    input  logic rst
);
    // Semnale între CPU și Cache [cite: 129]
    logic [15:0] cpu_to_cache_addr;
    logic [7:0]  cpu_to_cache_data;
    logic [7:0]  cache_to_cpu_data;
    logic        cpu_cs;
    logic        cpu_wr_rd;
    logic        cache_rdy;

    // Semnale între Cache și SDRAM [cite: 162]
    logic [15:0] cache_to_sdram_addr;
    logic [7:0]  cache_to_sdram_data;
    logic [7:0]  sdram_to_cache_data;
    logic        sdram_wr_rd;
    logic        sdram_mstrb;
    
    logic        system_hit;

    // 1. Instanțiere CPU (Master-ul care cere date)
    CPU processor (
        .clk(clk),
        .rst(rst),
        .rdy(cache_rdy),
        .din(cache_to_cpu_data),
        .add(cpu_to_cache_addr),
        .wr_rd(cpu_wr_rd),
        .cs(cpu_cs),
        .dout(cpu_to_cache_data)
    );

    // 2. Instanțiere Cache (Intermediarul cu Mux/Demux/Controller)
    Cache memory_cache (
        .clk(clk),
        .rst(rst),
        // CPU Side
        .cpu_addr(cpu_to_cache_addr),
        .cpu_din(cpu_to_cache_data),
        .cpu_cs(cpu_cs),
        .cpu_wr_rd(cpu_wr_rd),
        .cpu_dout(cache_to_cpu_data),
        .cpu_rdy(cache_rdy),
        .cpu_hit(system_hit),
        // SDRAM Side
        .sdram_din(sdram_to_cache_data),
        .sdram_addr(cache_to_sdram_addr),
        .sdram_dout(cache_to_sdram_data),
        .sdram_wr_rd(sdram_wr_rd),
        .sdram_mstrb(sdram_mstrb)
    );

    // 3. Instanțiere SDRAM_Controller (Memoria Principală)
    SDRAM_Controller main_mem (
        .clk(clk),
        .add(cache_to_sdram_addr),
        .din(cache_to_sdram_data),
        .wr_rd(sdram_wr_rd),
        .memstrb(sdram_mstrb),
        .dout(sdram_to_cache_data)
    );

endmodule