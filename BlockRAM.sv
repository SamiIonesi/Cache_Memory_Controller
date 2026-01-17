module BlockRAM (
    input  logic       clk,
    input  logic       rst,   
    input  logic [7:0] addr, 
    input  logic [7:0] din,  
    input  logic       wen,  
    output logic [7:0] dout   
);

    logic [7:0] ram [0:255];

    always_ff @(posedge clk) begin
        if (rst) begin
            // Initiate memory to 0
            for (int i = 0; i < 256; i++) begin
                ram[i] <= 8'h00;
            end
            dout <= 8'h00;
        end else begin
            if (wen) begin
                // write
                ram[addr] <= din;
            end
            // read
            dout <= ram[addr];
        end
    end

endmodule