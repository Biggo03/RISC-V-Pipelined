    .section .text
    .globl _start
_start:
    # Fail flag and path selector
    addi x31, x0, 0      # fail_flag = 0  (set to 1 only if wrong path commits)
    addi x28, x0, 0      # path_flag = 0  (armed just before the branch)

    ################################################################
    # Align to 64B boundary so we can place the branch as instr #16
    ################################################################
    .align 6             # 64-byte align => 16 instructions per block

# ---------------- Block N (16 instr total) ----------------
# [0]  target entry runs twice:
#      - linear pass:     x28==0 => stay on linear path
#      - redirect pass:   x28==1 => skip over branch & wrong-path
target:
    bne  x28, x0, from_branch    # [0] taken only on redirect after mispredict

    addi x5,  x0, 0              # [1] filler
    addi x6,  x0, 0              # [2]
    addi x7,  x0, 0              # [3]
    addi x8,  x0, 0              # [4]
    addi x9,  x0, 0              # [5]
    addi x10, x0, 0              # [6]
    addi x11, x0, 0              # [7]
    addi x12, x0, 0              # [8]
    addi x13, x0, 0              # [9]
    addi x14, x0, 0              # [10]
    addi x15, x0, 0              # [11]
    addi x16, x0, 0              # [12]

    addi x28, x0, 1              # [13] ARM path_flag just before branch

    beq  x0,  x0, target         # [14] BRANCH @ 16th instr:
                                  #  - predictor (WNT) predicts NOT-TAKEN
                                  #  - actual TAKEN (back to 'target') => MIS-PREDICT

# --------------- Block N+1 (fall-through = wrong path) ---------------
# The fall-through PC (wrong path) is the first instr of the *next* 64B block.
# With a cold I$, this fetch causes an I$ MISS while the branch resolves.
wrong_path:
    addi x31, x0, 1              # wrong-path marker (must be flushed)
    addi x20, x0, 99
    sw   x20, 100(x0)            # WRONG store if rollback is broken
    beq  x0,  x0, after_branch   # park wrong path

# Arrive here only via the taken branch after mispredict redirect.
# Skip over the branch and the entire wrong-path block.
from_branch:
    jal  x0,  after_branch

# ----------------------- Success epilogue -----------------------------
after_branch:
    bne  x31, x0, done           # if any wrong-path op committed, skip success
    addi x22, x0, 25
    sw   x22, 100(x0)            # mem[100] = 25  (only on correct rollback)

done:
    beq  x0, x0, done            # spin

