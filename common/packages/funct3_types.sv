package funct3_types;

typedef enum logic [2:0] {
    F3_BEQ  = 3'b000,
    F3_BNE  = 3'b001,
    F3_BGE  = 3'b101,
    F3_BGEU = 3'b111,
    F3_BLT  = 3'b100,
    F3_BLTU = 3'b110
} f3_branch_t;

typedef enum logic [2:0] {
    F3_ADD_SUB = 3'b000,
    F3_SLL     = 3'b001,
    F3_SLT     = 3'b010,
    F3_SLTU    = 3'b011,
    F3_XOR     = 3'b100,
    F3_SRL_SRA = 3'b101,
    F3_OR      = 3'b110,
    F3_AND     = 3'b111
} f3_alu_t;

typedef enum logic [2:0] {
    F3_WORD = 3'b010,
    F3_HALF = 3'b001,
    F3_BYTE = 3'b000,
    F3_HALF_U = 3'b101,
    F3_BYTE_U = 3'b100
} f3_width_t;

endpackage