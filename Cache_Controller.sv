`timescale 1ns/1ps
// -----------------------------
// Cache top module
// -----------------------------
module cache_top #(parameter DATA_WIDTH  = 8, parameter ADDR_WIDTH = 5, parameter B_UNIT_NUMBER = 4)(
  input clk,
  input rst,
  input  [B_UNIT_NUMBER - 1:0] req, 
  input  [B_UNIT_NUMBER - 1:0] wr,
  input  [ADDR_WIDTH - 1:0] addr0, addr1, addr2, addr3,
  input  [DATA_WIDTH - 1:0] data0, data1, data2, data3,
  output [DATA_WIDTH - 1:0] dout0, dout1, dout2, dout3
);

  // Arbiter -> SRAM
  wire we_to_mem_wire;
  wire [4:0] addr_to_mem_wire;
  wire [7:0] sram_din_wire; 
  wire [7:0] sram_dout_wire;
  
  // Arbiter -> B_units
  wire [1:0] sel_out; 
  wire [3:0] req_wire, ack_wire, wr_wire;
  wire [7:0] data_b0_to_arb, data_b1_to_arb, data_b2_to_arb, data_b3_to_arb; 
  wire [4:0] addr_b0_to_arb, addr_b1_to_arb, addr_b2_to_arb, addr_b3_to_arb; 
  wire [7:0] data_arb_to_b0, data_arb_to_b1, data_arb_to_b2, data_arb_to_b3; 
  
  // MUXs out
  wire [7:0] mux_data_out; 
  wire [4:0] mux_addr_out;

  // SRAM
  sram_mem sram(
    .clk(clk),
    .we(we_to_mem_wire),
    .addr(addr_to_mem_wire), 
    .din(sram_din_wire),
    .dout(sram_dout_wire)
  );

  // MUX Data 
  multiplexor #(8) mux_data_inst(
    .in0(data_b0_to_arb), .in1(data_b1_to_arb),
    .in2(data_b2_to_arb), .in3(data_b3_to_arb),
    .sel(sel_out), 
    .out(mux_data_out)
  );
  
  // MUX Address
  multiplexor #(5) mux_addr_inst(
    .in0(addr_b0_to_arb), .in1(addr_b1_to_arb),
    .in2(addr_b2_to_arb), .in3(addr_b3_to_arb),
    .sel(sel_out), 
    .out(mux_addr_out)
  );

  // B units
  B_unit #(8, 5) B0(.clk(clk), .rst(rst), .ack(ack_wire[0]), .req_in(req[0]), .wr_in(wr[0]),
            .addr_in(addr0), .data_in(data0), .data_from_mem(data_arb_to_b0),
            .req_out(req_wire[0]), .wr_out(wr_wire[0]), .addr_out(addr_b0_to_arb), .data_out(data_b0_to_arb), .dout(dout0));

  B_unit #(8, 5) B1(.clk(clk), .rst(rst), .ack(ack_wire[1]), .req_in(req[1]), .wr_in(wr[1]),
            .addr_in(addr1), .data_in(data1), .data_from_mem(data_arb_to_b1),
            .req_out(req_wire[1]), .wr_out(wr_wire[1]), .addr_out(addr_b1_to_arb), .data_out(data_b1_to_arb), .dout(dout1));

  B_unit #(8, 5) B2(.clk(clk), .rst(rst), .ack(ack_wire[2]), .req_in(req[2]), .wr_in(wr[2]),
            .addr_in(addr2), .data_in(data2), .data_from_mem(data_arb_to_b2),
            .req_out(req_wire[2]), .wr_out(wr_wire[2]), .addr_out(addr_b2_to_arb), .data_out(data_b2_to_arb), .dout(dout2));

  B_unit #(8, 5) B3(.clk(clk), .rst(rst), .ack(ack_wire[3]), .req_in(req[3]), .wr_in(wr[3]),
            .addr_in(addr3), .data_in(data3), .data_from_mem(data_arb_to_b3),
            .req_out(req_wire[3]), .wr_out(wr_wire[3]), .addr_out(addr_b3_to_arb), .data_out(data_b3_to_arb), .dout(dout3));


  // Arbiter 
  arb #(8, 5) arb_inst(
    .clk(clk), .rst(rst),
    // In's from B-units
    .req0(req_wire[0]), .req1(req_wire[1]), .req2(req_wire[2]), .req3(req_wire[3]),
    .wr0(wr_wire[0]), .wr1(wr_wire[1]), .wr2(wr_wire[2]), .wr3(wr_wire[3]),
    .addr_from_mux(mux_addr_out),
    .data_from_mux(mux_data_out), 
    
    // Out's to B-units (ACK & Read Data)
    .ack0(ack_wire[0]), .ack1(ack_wire[1]), .ack2(ack_wire[2]), .ack3(ack_wire[3]),
    .data_to_B0(data_arb_to_b0), .data_to_B1(data_arb_to_b1), 
    .data_to_B2(data_arb_to_b2), .data_to_B3(data_arb_to_b3),
    
    // Out's to SRAM (Control & Write Data)
    .addr_to_mem(addr_to_mem_wire), 
    .data_to_mem(sram_din_wire), 
    .we_to_mem(we_to_mem_wire),
    .sel_out(sel_out),
    
    // In's from SRAM
    .data_from_mem(sram_dout_wire)
  );

endmodule
