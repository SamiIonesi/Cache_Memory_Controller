module SDRAM_Controller (
    input  logic        clk,
    input  logic [15:0] add,      
    input  logic [7:0]  din,     
    input  logic        wr_rd,    
    input  logic        memstrb,  
    output logic [7:0]  dout      
);

    // Memory of 64KB (2^16 locations of 8 bites)
    logic [7:0] ram [0:65535];

    initial begin
        for (int i = 0; i < 65536; i++) ram[i] = i[7:0]; 
    end

    always_ff @(posedge clk) begin
        if (memstrb) begin
            if (wr_rd) begin
                // write
                ram[add] <= din;
            end else begin
                // read
                dout <= ram[add];
            end
        end
    end

endmodule