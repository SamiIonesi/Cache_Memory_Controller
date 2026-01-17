module CPU (
    input  logic        clk,
    input  logic        rst,
    input  logic        rdy,     
    input  logic [7:0]  din,      
    output logic [15:0] add,      
    output logic        wr_rd,    
    output logic        cs,       
    output logic [7:0]  dout       
);

    typedef enum logic [1:0] {IDLE, SETUP, ASSERT_CS, WAIT_DONE} state_t;
    state_t state;
    
    logic [2:0] cs_counter;
    integer test_step;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            test_step <= 0;
            cs <= 1'b0;
            add <= 16'h0;
            dout <= 8'h0;
            wr_rd <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    cs <= 1'b0;
                    if (rdy) state <= SETUP;
                end

                SETUP: begin
                case (test_step)
                        // CAZUL 3: MISS (Dirty=0)
                        // Citim de la 0x1234. Cache e gol (Valid=0, Dirty=0).
                        // Rezultat: Se aduc 32 octeți din SDRAM în SRAM.
                        0: begin add <= 16'h1234; wr_rd <= 1'b0; end 
                
                        // CAZUL 1: WRITE HIT
                        // Scriem 0xAA la 0x1234. Adresa există deja (de la pasul 0).
                        // Rezultat: Data se scrie în SRAM, Dirty devine 1.
                        1: begin add <= 16'h1234; wr_rd <= 1'b1; dout <= 8'hAA; end 
                
                        // CAZUL 2: READ HIT
                        // Citim de la 0x1234. 
                        // Rezultat: Data 0xAA este trimisă imediat la CPU.
                        2: begin add <= 16'h1234; wr_rd <= 1'b0; end 
                
                        // CAZUL 4: MISS (Dirty=1) - Cel mai important!
                        // Citim de la 0xFF34 (Același Index 001, dar Tag diferit FF).
                        // Rezultat: 1. Salvare bloc vechi (0x1234) în SDRAM (Write-back).
                        //           2. Aducere bloc nou (0xFF34) din SDRAM.
                        3: begin add <= 16'hFF34; wr_rd <= 1'b0; end 
                
                        default: begin state <= IDLE; end
                    endcase
                    state <= ASSERT_CS;
                    cs_counter <= 3'd1;
                end 

                ASSERT_CS: begin
                    cs <= 1'b1; // CS ramane activ 4 cicluri
                    if (cs_counter < 4) begin
                        cs_counter <= cs_counter + 3'd1;
                    end else begin
                        cs <= 1'b0; 
                        state <= WAIT_DONE;
                    end
                end

                WAIT_DONE: begin
                    if (rdy) begin // Asteptam finalizarea tranzactiei
                        test_step <= test_step + 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule