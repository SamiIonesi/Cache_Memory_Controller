// ==========================================================
// Arbiter
// ==========================================================
module arb #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 5 
)(
    input wire clk, rst,
    input wire req0, req1, req2, req3,
    input wire wr0,  wr1,  wr2,  wr3,
    input wire [ADDR_WIDTH-1:0] addr_from_mux,
    input wire [DATA_WIDTH-1:0] data_from_mux,

    output reg  ack0, ack1, ack2, ack3,
    output reg  [ADDR_WIDTH-1:0] addr_to_mem,
    output reg  [DATA_WIDTH-1:0] data_to_mem,
    output reg  we_to_mem,
    input wire [DATA_WIDTH-1:0] data_from_mem,
    output reg  [DATA_WIDTH-1:0] data_to_B0, data_to_B1, data_to_B2, data_to_B3,
    output reg  [1:0] sel_out
);

    localparam S_IDLE = 2'd0, S_PROC = 2'd1, S_ACK1 = 2'd2, S_ACK2 = 2'd3;

    reg [1:0] state, next_state;
    reg [1:0] selected_id;
    reg wr_type_latched;
    wire any_req = req0 | req1 | req2 | req3;

    // Priority decoder (0 > 1 > 2 > 3)
    reg [1:0] priority_winner;
    always @(*) begin
        if      (req0) priority_winner = 2'd0;
        else if (req1) priority_winner = 2'd1;
        else if (req2) priority_winner = 2'd2;
        else if (req3) priority_winner = 2'd3;
        else           priority_winner = 2'd0;
    end

    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: if (any_req) next_state = S_PROC;
            S_PROC: next_state = S_ACK1;
            S_ACK1: next_state = S_ACK2;
            S_ACK2: next_state = S_IDLE;
        endcase
    end

    // Logica secvențială
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            {ack0, ack1, ack2, ack3} <= 0;
            {addr_to_mem, data_to_mem, we_to_mem} <= 0;
            {data_to_B0, data_to_B1, data_to_B2, data_to_B3} <= 0;
            sel_out <= 0;
        end else begin
            state <= next_state;
            {ack0, ack1, ack2, ack3} <= 0;
            {addr_to_mem, data_to_mem, we_to_mem} <= 0;
            {data_to_B0, data_to_B1, data_to_B2, data_to_B3} <= 0;
            
            case (state)
                S_IDLE: begin
                    if (any_req) begin
                        selected_id <= priority_winner;
                        sel_out <= priority_winner;
                        case (priority_winner)
                            2'd0: wr_type_latched <= wr0;
                            2'd1: wr_type_latched <= wr1;
                            2'd2: wr_type_latched <= wr2;
                            2'd3: wr_type_latched <= wr3;
                        endcase
                    end
                end

                S_PROC: begin
                    // Driving SRAM inputs
                    addr_to_mem <= addr_from_mux;
                    data_to_mem <= data_from_mux;
                    we_to_mem   <= wr_type_latched;
                end

                S_ACK1: begin
                    case (selected_id) 2'd0: ack0 <= 1; 2'd1: ack1 <= 1; 2'd2: ack2 <= 1; 2'd3: ack3 <= 1; endcase
                end

                S_ACK2: begin
                    case (selected_id) 2'd0: ack0 <= 1; 2'd1: ack1 <= 1; 2'd2: ack2 <= 1; 2'd3: ack3 <= 1; endcase
                    // Drive data back to B-units
                    if (!wr_type_latched) begin
                        case (selected_id)
                            2'd0: data_to_B0 <= data_from_mem;
                            2'd1: data_to_B1 <= data_from_mem;
                            2'd2: data_to_B2 <= data_from_mem;
                            2'd3: data_to_B3 <= data_from_mem;
                        endcase
                    end
                end
            endcase
        end
    end
endmodule
