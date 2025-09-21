    .section .text
    .globl _start
_start:
    addi x31, x0, 0          # fail_flag = 0 (set to 1 if any wrong-path commits)

    ############################################################
    # Case A: CACHE MISS + MIS-PREDICT
    # - Make branch the FIRST instruction in a brand-new block
    # - First encounter => predict NOT-TAKEN (WNT)
    # - Actual outcome = TAKEN  => MIS-PREDICT
    ############################################################
    .align 6                  # align to 64B block boundary
A_branch:
    beq   x0, x0, A_taken     # always TAKEN -> initial prediction (NT) is wrong
    addi  x31, x0, 1          # WRONG-PATH: if this commits, recovery is broken
A_taken:
    addi  x5, x0, 1           # harmless

    ############################################################
    # Case B: CACHE MISS + CORRECT PREDICTION
    # - Branch is again the FIRST instruction in a fresh block
    # - First encounter => predict NOT-TAKEN (WNT)
    # - Actual outcome = NOT-TAKEN => CORRECT
    ############################################################
    .align 6
B_branch:
    bne   x0, x0, B_taken     # always NOT-TAKEN -> predicted NT is correct
    addi  x5, x5, 1           # fall-through executes on the correct path
    beq   x0, x0, B_cont
B_taken:
    addi  x31, x0, 2          # WRONG-PATH marker (should not execute)
B_cont:
    addi  x5, x5, 1

    ############################################################
    # Case C: CACHE HIT + MIS-PREDICT
    # - Warm the block with one instruction (causes the miss)
    # - Then place a NEW branch (first encounter) within same block
    # - Predict NOT-TAKEN (WNT), but make it TAKEN => MIS-PREDICT
    ############################################################
    .align 6
C_warm:
    addi  x6, x0, 0           # first instr in this block -> fills I$ (miss here)
C_branch:
    beq   x0, x0, C_taken     # TAKEN on first encounter -> mispredict
    addi  x31, x0, 3          # WRONG-PATH marker (if it commits, fail)
C_taken:
    addi  x6, x6, 1

    ############################################################
    # Case D: CACHE HIT + CORRECT PREDICTION
    # - Warm the block with one instruction (causes the miss)
    # - Then NEW branch (first encounter) within same block
    # - Predict NOT-TAKEN (WNT) and make it NOT-TAKEN => CORRECT
    ############################################################
    .align 6
D_warm:
    addi  x7, x0, 0           # warms this block -> branch fetch will be a hit
D_branch:
    bne   x0, x0, D_taken     # NOT-TAKEN on first encounter -> correct
    addi  x7, x7, 1           # correct fall-through
    beq   x0, x0, D_cont
D_taken:
    addi  x31, x0, 4          # WRONG-PATH marker (should not execute)
D_cont:
    addi  x7, x7, 1

    ############################################################
    # Final: only store 25 if NO wrong-path markers committed
    ############################################################
    bne   x31, x0, done       # if fail_flag != 0, skip the store
    addi  x10, x0, 25
    sw    x10, 100(x0)        # mem[100] = 25 (only when all 4 cases behaved)

done:
    beq   x0, x0, done        # spin


