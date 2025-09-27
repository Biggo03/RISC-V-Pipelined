module main_mem_model (
    
    input  logic         clk_i,
    input  logic         reset_i,

    input  logic [31:0]  addr_i,
    input  logic         cache_hit_i,

    output logic        rep_ready_o,
    output logic [63:0] rep_word_o
);

    localparam BLOCK_WORDS = 16;
    localparam WORDS_PER_CYCLE = 2;

    typedef enum logic {
        NO_REQ  = 1'b0,
        REQ     = 1'b1
    } main_mem_state_t;

    main_mem_state_t mem_state;

    logic [31:0] fetch_addr;
    integer cycle_cnt;
    logic [31:0] mem_array [4095:0];

    initial begin
        $readmemh(`INSTR_HEX_FILE, mem_array);
    end

    always_ff @(posedge clk_i) begin
        if (reset_i) begin 
            mem_state <= NO_REQ;
            cycle_cnt <= 0;
            fetch_addr <= 0;
            rep_ready_o <= 0;
        end else       
            case (mem_state)
                NO_REQ: begin
                    if (~cache_hit_i) begin
                        mem_state <= REQ;
                        cycle_cnt <= 0;
                        fetch_addr <= {addr_i[31:6], 6'b0};
                        rep_ready_o <= 1;
                    end
                end

                REQ: begin
                    if (cache_hit_i) begin
                        mem_state <= NO_REQ;
                        cycle_cnt <= 0;
                        rep_ready_o <= 0;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

            endcase
    end

    assign rep_word_o[31:0] = mem_array[(fetch_addr[31:6] * BLOCK_WORDS) + (WORDS_PER_CYCLE*cycle_cnt)];
    assign rep_word_o[63:32] = mem_array[(fetch_addr[31:6] * BLOCK_WORDS) + (WORDS_PER_CYCLE*cycle_cnt) + 1];

endmodule
