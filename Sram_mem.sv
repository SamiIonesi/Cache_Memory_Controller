// -----------------------------
// SRAM synchronous memory
// -----------------------------
module sram_mem(
  input clk,
  input we,
  input [4:0] addr,
  input [7:0] din,
  output reg [7:0] dout
);
  reg [7:0] mem [0:31];
  integer i;
  
  initial begin
    for (i = 0; i < 32; i = i + 1) mem[i] = 8'h00;
    dout = 8'h00;
  end

  always @(posedge clk) begin
    if (we)
      mem[addr] <= din;
    dout <= mem[addr];
  end
  
  //assign dout = mem[addr];
endmodule