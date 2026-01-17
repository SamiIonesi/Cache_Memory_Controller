module Cache (
    input  logic        clk,
    input  logic        rst,

    // CPU
    input  logic [15:0] cpu_addr,
    input  logic [7:0]  cpu_din,     
    input  logic        cpu_cs,
    input  logic        cpu_wr_rd,
    output logic [7:0]  cpu_dout,    
    output logic        cpu_rdy,
    output logic        cpu_hit,    

    // SDRAM Controller
    input  logic [7:0]  sdram_din,   
    output logic [15:0] sdram_addr,
    output logic [7:0]  sdram_dout,  
    output logic        sdram_wr_rd,
    output logic        sdram_mstrb
);

    logic sram_wen;
    logic mux_sel;
    logic demux_sel;
    logic internal_hit; 

    logic [7:0] sram_din_bus;
    logic [7:0] sram_dout_bus;

    // MUX 2-1 (SRAM)
    assign sram_din_bus = (mux_sel == 1'b0) ? cpu_din : sdram_din;
    
    // CPU HIT
    assign cpu_hit = cpu_cs && internal_hit;

    // CacheController
    CacheController controller (
        .clk(clk),
        .rst(rst),
        .cpu_addr(cpu_addr),
        .cpu_cs(cpu_cs),
        .cpu_wr_rd(cpu_wr_rd),
        .cpu_rdy(cpu_rdy),
        .sram_wen(sram_wen),
        .mux_sel(mux_sel),
        .demux_sel(demux_sel),
        .sdram_add(sdram_addr),
        .sdram_wr_rd(sdram_wr_rd),
        .sdram_mstrb(sdram_mstrb),
        .is_hit_out(internal_hit) 
    );

    // BlockRAM (SRAM)
    BlockRAM data_storage (
        .clk(clk),
        .rst(rst),
        .addr(cpu_addr[7:0]), 
        .din(sram_din_bus),
        .wen(sram_wen),
        .dout(sram_dout_bus)
    );

    // DEMUX (SRAM Out)
    assign cpu_dout = (demux_sel == 1'b0) ? sram_dout_bus : 8'h00;
    assign sdram_dout = (demux_sel == 1'b1) ? sram_dout_bus : 8'h00;

endmodule