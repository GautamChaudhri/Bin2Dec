// Manual test harness: set R0-R5 bits here, run 6-bit conversion, store result in 'here'
(ks_conv6_manualTest)
    // Example value: 001010 (decimal 10). Change bits below as needed.
    @0
    D=A
    @R0
    M=D         // bit 5 (sign)
    @R1
    M=D         // bit 4
    @R2
    M=D         // bit 3
    @1
    D=A
    @R3
    M=D         // bit 2
    @0
    D=A
    @R4
    M=D         // bit 1
    @1
    D=A
    @R5
    M=D         // bit 0

    // zero out the rest just in case
    @0
    D=A
    @R6
    M=D
    @R7
    M=D
    @R8
    M=D
    @R9
    M=D
    @R10
    M=D
    @R11
    M=D
    @R12
    M=D
    @R13
    M=D
    @R14
    M=D
    @R15
    M=D

    @ks_conv6b
    0;JMP


// Performs raw 6-bit conversion using Mult and Pow functions
// R0-R5 store the bits to convert in big-endian order (R0 = most significant bit)
// If R0 is 1, then we start counting at -32, otherwise we start counting at 0
// Store the result in ks_convRet and here
(ks_conv6b)
    // Handle sign bit: if negative, seed sum with -32 and start after the sign bit
    @R0
    D=M
    @ks_conv6_negativeStart
    D;JNE

    // Positive number: sum = 0, start at bit 0
    @ks_conv_sum
    M=0
    @ks_conv_i
    M=0
    @ks_conv6_loop
    0;JMP

    (ks_conv6_negativeStart)
        @R0
        D=A
        @32
        D=D-A
        @ks_conv_sum
        M=D
        @ks_conv_i
        M=1

    (ks_conv6_loop)
        // for (i = start; i < 6; ++i)
        @ks_conv_i
        D=M
        @6
        D=D-A
        @ks_conv6_end
        D;JGE

        // exponent = 5 - i
        @5
        D=A
        @ks_conv_i
        D=D-M
        @ks_conv_exp
        M=D

        // Load bit value from R[i]
        @ks_conv_i
        D=M
        @R0
        A=D+A
        D=M
        @ks_conv_bitValue
        M=D

        // If bit is 0, skip contribution
        @ks_conv6_loop_increment
        D;JEQ

        // Load base = 2 into R103
        @2
        D=A
        @R103
        M=D

        // Load exponent into R104
        @ks_conv_exp
        D=M
        @R104
        M=D

        // Call Pow subroutine
        @ks_conv6_afterPow
        D=A
        @ks_Pow_return
        M=D
        @ks_Pow
        0;JMP

    (ks_conv6_afterPow)
        @R105
        D=M
        @ks_conv_sum
        M=M+D

    (ks_conv6_loop_increment)
        @ks_conv_i
        M=M+1
        @ks_conv6_loop
        0;JMP

    (ks_conv6_end)
        // Store final result in ks_convRet and here
        @ks_conv_sum
        D=M
        @ks_convRet
        M=D
        @here
        M=D

        @ks_conv6_end
        0;JMP


// Performs raw conversion logic (sum of product expansion) using Mult and Pow functions
// R0-R15 store the bits to convert in big-endian order (R0 = most significant bit)
// If R0 is 1, then we start counting at -32768, otherwise we start counting at 0
// We need to store the -32768 in 4 steps: @R0, D=A, @32768, D=D-A, because we can't directly @ a negative address
// In addition, we can't use any R0-R15 registers to perform any logic; we need to use variables to store anything that isn't a bit
// Store the result in ks_convRet, use ks_conv_i for the index, ks_conv_sum for the accumulator, and other ks_conv_* variables as needed
(ks_conv16b)
    // Handle sign bit: if negative, seed sum with -32768 and start after the sign bit
    @R0
    D=M
    @ks_conv_negativeStart
    D;JNE

    // Positive number: sum = 0, start at bit 0
    @ks_conv_sum
    M=0
    @ks_conv_i
    M=0
    @ks_conv_loop
    0;JMP

    (ks_conv_negativeStart)
        @R0
        D=A
        @32768
        D=D-A
        @ks_conv_sum
        M=D
        @ks_conv_i
        M=1

    (ks_conv_loop)
        // for (i = start; i < 16; ++i)
        @ks_conv_i
        D=M
        @16
        D=D-A
        @ks_conv_end
        D;JGE

        // exponent = 15 - i
        @15
        D=A
        @ks_conv_i
        D=D-M
        @ks_conv_exp
        M=D

        // Load bit value from R[i]
        @ks_conv_i
        D=M
        @R0
        A=D+A
        D=M
        @ks_conv_bitValue
        M=D

        // If bit is 0, skip contribution
        @ks_conv_loop_increment
        D;JEQ

        // Load base = 2 into R103
        @2
        D=A
        @R103
        M=D

        // Load exponent into R104
        @ks_conv_exp
        D=M
        @R104
        M=D

        // Call Pow subroutine
        @ks_conv_afterPow
        D=A
        @ks_Pow_return
        M=D
        @ks_Pow
        0;JMP

    (ks_conv_afterPow)
        @R105
        D=M
        @ks_conv_sum
        M=M+D

    (ks_conv_loop_increment)
        @ks_conv_i
        M=M+1
        @ks_conv_loop
        0;JMP

    (ks_conv_end)
        // Store final result in ks_convRet
        @ks_conv_sum
        D=M
        @ks_convRet
        M=D

        @ks_conv_hlt
        0;JMP


// Mult function
// Multiplies R100 and R101 and stores the result in R102.
// (R100, R101, R102 refer to RAM[0], RAM[1], and RAM[2], respectively.)
// The algorithm handles positive and negative operands.
(ks_Mult)
    @R102
    M=0
    @R100
    D=M
    @ks_mul_tmp_X
    M=D
    @R101
    D=M
    @ks_mul_tmp_Y
    M=D
    @ks_mul_tmp_Y
    D=M
    @ks_Mult_endLoop
    D;JEQ
    @ks_mul_tmp_Y
    D=M
    @ks_Mult_isNegativeMultiplier
    D;JLT
    (ks_Mult_isPositiveMultiplier)
        @ks_mul_tmp_X
        D=M
        @R102
        M=D+M
        @ks_mul_tmp_Y
        M=M-1
        D=M
        @ks_Mult_isPositiveMultiplier
        D;JGT
        @ks_Mult_endLoop
        0;JMP
    (ks_Mult_isNegativeMultiplier)
        @ks_mul_tmp_X
        D=-M
        @ks_mul_tmp_X
        M=D
        @ks_mul_tmp_Y
        M=-M
        @ks_Mult_isPositiveMultiplier
        0;JMP
    (ks_Mult_endLoop)
        @ks_Mult_return
        A=M
        0;JMP

// Pow function
// Uses Mult to compute R105 = R103 ^ R104 (R103 = base, R104 = exponent, R105 = result).
// R108 is used as the exponent counter. R105 is initialized to 1 and repeatedly
// multiplied by R103 using the Mult routine R104 times.
(ks_Pow)
    @R105
    M=1
    @R104
    D=M
    @R108
    M=D
    (ks_Pow_startLoop)
        @R108
        D=M
        @ks_Pow_endPower
        D;JEQ
        @R105
        D=M
        @R100
        M=D
        @R103
        D=M
        @R101
        M=D
        @ks_Mult
        @ks_Pow_mulRet
        0;JMP
    (ks_Pow_mulRet)
        @R102
        D=M
        @R105
        M=D
        @R108
        M=M-1
        @ks_Pow_startLoop
        0;JMP
    (ks_Pow_endPower)
        @ks_Pow_return
        A=M
        0;JMP

// Div function
// Performs integer (Euclidean) division: R100 / R101 = R102  (R100,R101,R102 refer to RAM[0],RAM[1],RAM[2])
// The remainder is stored in R103.
// Usage: Before executing, put the dividend in R100 and the divisor in R101.
(ks_Div)
    @R100
    D=M
    @R101
    A=M
    D=A
    @ks_Div_sigfpe
    D;JEQ
    @R100
    D=M
    @ks_Div_posDividend
    D;JGE
    @ks_Div_negDividend
    0;JMP
    (ks_Div_posDividend)
        @R105
        M=0
        @R101
        D=M
        @ks_Div_posDivisor
        D;JGE
        @ks_Div_negDivisor
        0;JMP
    (ks_Div_negDividend)
        @R105
        M=1
        @R101
        D=M
        @ks_Div_posDivisor
        D;JGE
        @ks_Div_negDivisor
        0;JMP
    (ks_Div_posDivisor)
        @R101
        D=M
        @R104
        M=D
        @R6
        M=0
        @ks_Div_runAlgorithm
        0;JMP
    (ks_Div_runAlgorithm)
        @R105
        D=M
        @ks_Div_runAlgorithm_posdiv
        D;JEQ
        @R100
        D=M
        D=-D
        @R103
        M=D
        @ks_Div_runAlgorithm_after
        0;JMP
    (ks_Div_runAlgorithm_posdiv)
        @R100
        D=M
        @R103
        M=D
    (ks_Div_runAlgorithm_after)
        @R102
        M=0
    (ks_Div_algo1)
        @R103
        D=M
        @R104
        D=D-M
        @ks_Div_endAlgo1
        D;JLT
        @R103
        M=D
        @R102
        D=M
        D=D+1
        @R102
        M=D
        @ks_Div_algo1
        0;JMP
    (ks_Div_negDivisor)
        @R101
        D=M
        D=-D
        @R104
        M=D
        @R6
        M=1
        @ks_Div_runAlgorithm
        0;JMP
    (ks_Div_sigfpe)
        @R102
        M=0
        @R100
        D=M
        @ks_Div_sigfpe_nonzero_dividend
        D;JNE
        @R103
        M=-1
        @R103
        M=M-1
        @ks_Div_halt
        0;JMP
    (ks_Div_endAlgo1)
        @R105
        D=M
        @ks_Div_dividend_nonneg
        D;JEQ
        @R6
        D=M
        @ks_Div_both_negative
        D;JNE
        @R103
        D=M
        @ks_Div_div_neg_divpos_rem_zero
        D;JEQ
        @R102
        D=M
        D=-D
        D=D-1
        @R102
        M=D
        @R104
        D=M
        @R103
        D=D-M
        @R103
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_div_neg_divpos_rem_zero)
        @R102
        D=M
        D=-D
        @R102
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_both_negative)
        @R103
        D=M
        @ks_Div_both_neg_rem_zero
        D;JEQ
        @R102
        D=M
        D=D+1
        @R102
        M=D
        @R104
        D=M
        @R103
        D=D-M
        @R103
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_both_neg_rem_zero)
        @ks_Div_halt
        0;JMP
    (ks_Div_dividend_nonneg)
        @R6
        D=M
        @ks_Div_div_pos_divneg
        D;JNE
        @ks_Div_halt
        0;JMP
    (ks_Div_div_pos_divneg)
        @R102
        D=M
        D=-D
        @R102
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_sigfpe_nonzero_dividend)
        @R103
        M=-1
        @ks_Div_halt
        0;JMP
    (ks_Div_halt)
        @ks_Div_return
        A=M
        0;JMP




(ks_conv_manualRet)
    @ks_convRet
    D=M
    @here
    M=D
    @ks_conv_manualRet
    0;JMP

// Storage for manual test output
(here)
