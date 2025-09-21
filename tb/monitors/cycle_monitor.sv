module cycle_monitor (
    input logic       clk_i,
    input logic       reset_i,

    input logic       valid_w,
    input logic       stall_w,

    input logic [6:0] op_w
);

    int cycle_cnt;

    int retire_cnt;
    int alu_op_cnt;
    int load_op_cnt;
    int store_op_cnt;
    int branch_op_cnt;

    always_ff @(posedge clk_i) begin
        if (reset) cycle_cnt <= 0;
        else cycle_cnt <= cycle_cnt + 1;

        if (cycle_cnt % 1000 == 0) begin
            write_cycle_info();
        end
    end

    always_ff @(posedge clk_i) begin
        if (reset) begin
            retire_cnt    <= 0;
            alu_op_cnt    <= 0;
            load_op_cnt   <= 0;
            store_op_cnt  <= 0;
            branch_op_cnt <= 0;
        end else if (retire_w) begin
            retire_cnt    <= retire_cnt + 1;
            
            case (op_w)
                `R_TYPE_OP:         alu_op_cnt <= alu_op_cnt + 1;
                `I_TYPE_ALU_OP:     alu_op_cnt <= alu_op_cnt + 1;
                `AUIPC_OP:          alu_op_cnt <= alu_op_cnt + 1;
                `LUI_OP:            alu_op_cnt <= alu_op_cnt + 1;

                `B_TYPE_OP:         branch_op_cnt <= branch_op_cnt + 1;
                `JAL_OP:            branch_op_cnt <= branch_op_cnt + 1;
                `JALR_OP:           branch_op_cnt <= branch_op_cnt + 1;

                `I_TYPE_LOAD_OP:    load_op_cnt <= load_op_cnt +1;

                `S_TYPE_OP:         store_op_cnt <= store_op_cnt + 1;
            endcase

        end
    end

    assign retire_w = valid_w & ~stall_w;

endmodule

task write_cycle_info;
begin

end
endtask;