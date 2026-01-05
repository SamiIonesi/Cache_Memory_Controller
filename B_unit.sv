// ==========================================================
// B_unit
// ==========================================================
module B_unit #( 
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 5 
)( 
    input clk, input rst, 
    input ack, input req_in, input wr_in, 
    input [ADDR_WIDTH-1:0] addr_in, 
    input [DATA_WIDTH-1:0] data_in, 
    input [DATA_WIDTH-1:0] data_from_mem, 

    output reg req_out, 
    output reg wr_out, 
    output reg [ADDR_WIDTH-1:0] addr_out, 
    output reg [DATA_WIDTH-1:0] data_out, 
    output reg [DATA_WIDTH-1:0] dout 
); 
    localparam S_IDLE = 2'd0, S_WAIT_ACK1 = 2'd1, S_WAIT_ACK2 = 2'd2, S_DONE = 2'd3; 

    reg [1:0] state, next_state; 

    always @(*) begin 
        next_state = state; 
        case (state) 
            S_IDLE:       if (req_in) next_state = S_WAIT_ACK1; 
            S_WAIT_ACK1:  if (ack)    next_state = S_WAIT_ACK2; 
            S_WAIT_ACK2:  next_state = S_DONE; 
            S_DONE:       next_state = S_IDLE; 
            default:      next_state = S_IDLE; 
        endcase 
    end 

    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            state <= S_IDLE; 
            req_out <= 0; {wr_out, addr_out, data_out} <= 0; dout <= 0; 
        end else begin
            state <= next_state; 
            
            case (next_state) 
                S_IDLE: begin 
                    req_out <= 0;
                    if (!req_in) begin
                        {wr_out, addr_out, data_out} <= 0;
                    end
                end 

                S_WAIT_ACK1: begin 
                    req_out <= 1; 
                    addr_out <= addr_in; data_out <= data_in; wr_out <= wr_in;
                    dout <= 0;
                end 

                S_WAIT_ACK2: begin 
                    req_out <= 0;
                end 

                S_DONE: begin 
                    req_out <= 0;
                    if (!wr_out) dout <= data_from_mem; 
                end 
            endcase 
        end 
    end 
endmodule