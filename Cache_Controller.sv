module CacheController (
    input  logic        clk,
    input  logic        rst,

    // CPU
    input  logic [15:0] cpu_addr,
    input  logic        cpu_cs,
    input  logic        cpu_wr_rd,
    output logic        cpu_rdy,

    // (Mux/Demux and SRAM)
    output logic        sram_wen,
    output logic        mux_sel,    // 0 = CPU data, 1 = SDRAM data
    output logic        demux_sel,  // 0 = CPU path, 1 = SDRAM path
    
    // SDRAM Controller
    output logic [15:0] sdram_add,
    output logic        sdram_wr_rd,
    output logic        sdram_mstrb,
    output logic is_hit_out
);

    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        COMPARE_TAG = 3'b001,
        ALLOCATE    = 3'b010,
        WRITE_BACK  = 3'b011, 
        COMPLETE    = 3'b100
    } state_t;

    state_t state, next_state;

    // Internal memory for TAG, Valid bit and Dirty bit
    logic [7:0] tag_memory [0:7];
    logic       valid_bit  [0:7];
    logic       dirty_bit  [0:7];

    logic [4:0] word_counter;

    logic [7:0] current_tag;
    logic [2:0] current_index;
    assign current_tag   = cpu_addr[15:8];
    assign current_index = cpu_addr[7:5];

    // Generate HIT 
    logic is_hit; 
    assign is_hit = valid_bit[current_index] && (tag_memory[current_index] == current_tag);
    assign is_hit_out = is_hit;
    
    // FSM
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            word_counter <= 5'd0;
            for (int i=0; i<8; i++) begin
                valid_bit[i] <= 0;
                dirty_bit[i] <= 0;
            end
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: word_counter <= 5'd0;
                
                COMPARE_TAG: begin
                    if (is_hit && cpu_wr_rd) begin
                        dirty_bit[current_index] <= 1'b1; // Write Hit -> dirty
                    end
                end

                ALLOCATE: begin
                    if (word_counter == 5'd31) begin
                        valid_bit[current_index] <= 1'b1;
                        tag_memory[current_index] <= current_tag;
                        dirty_bit[current_index] <= 1'b0; 
                    end
                    word_counter <= word_counter + 5'd1;
                end

                WRITE_BACK: begin
                    word_counter <= word_counter + 5'd1;
                end
            endcase
        end
    end

    always_comb begin
        next_state = state;
        cpu_rdy = 1'b0;
        sram_wen = 1'b0;
        mux_sel = 1'b0;
        demux_sel = 1'b0;
        sdram_mstrb = 1'b0;
        sdram_wr_rd = 1'b0;
        sdram_add = cpu_addr;

        case (state)
            IDLE: begin
                cpu_rdy = 1'b1; // Ready for new transactions
                if (cpu_cs) next_state = COMPARE_TAG;
            end

            COMPARE_TAG: begin
                if (is_hit) begin
                    cpu_rdy = 1'b1;
                    sram_wen = cpu_wr_rd; // Write in SRAM only if is write 
                    next_state = IDLE;
                end else begin
                    // MISS
                    if (dirty_bit[current_index]) next_state = WRITE_BACK;
                    else                          next_state = ALLOCATE;
                end
            end

            ALLOCATE: begin // Read from SDRAM -> SRAM
                mux_sel = 1'b1;   // Select data from SDRAM
                sram_wen = 1'b1;  // Write in the new SRAM block
                sdram_mstrb = 1'b1;
                sdram_wr_rd = 1'b0;
                sdram_add = {current_tag, current_index, word_counter};
                if (word_counter == 5'd31) next_state = COMPARE_TAG;
            end

            WRITE_BACK: begin // SRAM -> SDRAM
                demux_sel = 1'b1; // Data from SRAM -> SDRAM
                sdram_mstrb = 1'b1;
                sdram_wr_rd = 1'b1;
                sdram_add = {tag_memory[current_index], current_index, word_counter}; // old address 
                if (word_counter == 5'd31) next_state = ALLOCATE;
            end
        endcase
    end
endmodule