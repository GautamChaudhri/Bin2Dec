// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: Bin2Dec.asm

//************************* "MAIN" *****************************************
// Description: Main entry point and control loop for binary-to-decimal converter.
//              Initializes state, handles keyboard input, and dispatches to appropriate handlers.
// Input: Keyboard input (0, 1, Enter, Backspace, 'c', 'q')
// Output: Displays binary input and decimal result on screen
(gc_RESTART)
    // Initialize State Variables
    @gc_bitsEntered
    M=0              
    @ge_currentColumn
    M=0
    @ks_convRet
    M=0

(gc_LOOP_START)
    @jm_getKey
    0;JMP

(jm_getKeyReturn) 
    @gc_currKey     
    M=D             

    // --- GLOBAL CHECKS (c and q) ---
    // Check for 'q' (Quit)
    @81             // 'q'
    D=A
    @gc_currKey
    D=M-D
    @cc_QUIT_CLEAR_LOOP   // <--- CHANGED: Go to clear routine
    D;JEQ

    // Check for 'c' (Clear)
    @67             // 'c'
    D=A
    @gc_currKey
    D=M-D
    @cc_FULL_RESET
    D;JEQ

    // --- INPUT CHECKS ---
    // Check for 'Enter' (128)
    @128
    D=A
    @gc_currKey
    D=M-D
    @gc_CHECK_PROCESS
    D;JEQ

    // Check for 'Backspace' (129)
    @129
    D=A
    @gc_currKey
    D=M-D
    @cc_DEL_BUFFER_BTN
    D;JEQ

    // --- DIGIT ENTRY (0 or 1) ---
    // Check if we have room (max 16 bits)
    @16
    D=A
    @gc_bitsEntered
    D=M-D
    @gc_LOOP_START
    D;JGE           // If bitsEntered >= 16, ignore digit input

    // Check if key is 0 or 1
    @gc_currKey
    D=M
    @ks_addBuf      // If key is 0 (literal), add it
    D;JEQ
    D=D-1
    @ks_addBuf      // If key is 1 (literal), add it
    D;JEQ

    // If key is neither 0, 1, Enter, BS, c, or q -> Ignore
    @gc_LOOP_START
    0;JMP

// Check if we can process (must have exactly 16 bits)
(gc_CHECK_PROCESS)
    @16
    D=A
    @gc_bitsEntered
    D=M-D
    @gc_LOOP_START   // If bitsEntered != 16, ignore Enter
    D;JNE
    
    // Process the buffer
    @gc_PROCESS_LOOP
    0;JMP

(END)
    @END
    0;JMP


//************************* "PROCESS & DISPLAY" *************************************
// Description: Converts the 16-bit binary buffer to decimal and displays the result.
//              Handles sign detection, special case for -32768, and prints arrow separator.
// Input: R0-R15 containing the 16 binary bits entered by user
// Output: Displays "->" followed by signed decimal value on screen
(gc_PROCESS_LOOP)
    // 1. Convert Binary to Integer (Result in ks_convRet)
    @ks_conv16b
    0;JMP

(gc_DISPLAY_START)
    // 2. Output Arrow "->"
    @gc_PRINT_ARROW_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_-
    0;JMP
(gc_PRINT_ARROW_RET)
    @ge_currentColumn
    M=M+1
    @gc_PRINT_ARROW_RET2
    D=A
    @ge_output_return
    M=D
    @ge_output_g
    0;JMP
(gc_PRINT_ARROW_RET2)
    @ge_currentColumn
    M=M+1

    // 3. Check Special Case (-32768)
    // -32768 is 1000...000. 
    // Logic: If (32767 + 1) - ks_convRet == 0
    @32767
    D=A
    D=D+1           // D = -32768
    @ks_convRet
    D=D-M
    @gc_SPECIAL_MIN_INT
    D;JEQ

    // 4. Check Sign
    @ks_convRet
    D=M
    @gc_IS_NEG
    D;JLT

    // POSITIVE: Print '+' and setup positive number
    @gc_PRINT_PLUS_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_+
    0;JMP
(gc_PRINT_PLUS_RET)
    @ge_currentColumn
    M=M+1
    @ks_convRet
    D=M
    @gc_dec_digit
    M=D             // Store positive number for extraction
    @gc_EXTRACT_DIGITS
    0;JMP

    // NEGATIVE: Print '-' and negate number
(gc_IS_NEG)
    @gc_PRINT_MINUS_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_-
    0;JMP
(gc_PRINT_MINUS_RET)
    @ge_currentColumn
    M=M+1
    @ks_convRet
    D=M
    M=-D            // Negate to make positive
    @gc_dec_digit
    M=M             // Store positive magnitude
    @gc_EXTRACT_DIGITS
    0;JMP


//************************* "DIGIT EXTRACTION" *************************************
// Description: Extracts individual decimal digits from the converted integer value.
//              Uses repeated division by 10 to isolate digits, stores them in RAM[2000+],
//              then prints them in reverse order (most significant first).
// Input: gc_dec_digit containing the positive magnitude of the number to display
// Output: Prints decimal digits to screen, increments ge_currentColumn for each digit
(gc_EXTRACT_DIGITS)
    // Setup array at RAM[2000] to store digits
    @2000
    D=A
    @gc_arrBase
    M=D
    @gc_arrIdx
    M=0

    @gc_dec_digit
    D=M
    
    // Handle '0' case explicitly
    @gc_HANDLE_ZERO
    D;JEQ

    // Save number to temporary variable for division loop
    @gc_numHold
    M=D

(gc_EXTRACT_LOOP)
    @gc_numHold
    D=M
    @gc_EXTRACT_PRINT_START
    D;JEQ       // If numHold is 0, we are done dividing

    // Prepare Div: R100 = numHold, R101 = 10
    @gc_numHold
    D=M
    @R100
    M=D         // Dividend
    @10
    D=A
    @R101
    M=D         // Divisor

    // Call Div
    @gc_DIV_RET
    D=A
    @ks_Div_return
    M=D
    @ks_Div
    0;JMP

(gc_DIV_RET)
    // R102 = Quotient, R103 = Remainder
    
    // Update numHold = Quotient
    @R102
    D=M
    @gc_numHold
    M=D
    
    // Store Remainder into RAM[2000 + gc_arrIdx]
    @gc_arrBase
    D=M
    @gc_arrIdx
    D=D+M       // D = Address (2000 + i)
    @gc_tempAddr
    M=D
    
    @R103
    D=M         // The digit (0-9)
    @gc_tempAddr
    A=M
    M=D         // Store it

    // Increment Index
    @gc_arrIdx
    M=M+1
    
    @gc_EXTRACT_LOOP
    0;JMP

// Print the digits we stored (Reverse Order)
(gc_EXTRACT_PRINT_START)
    // gc_arrIdx currently points 1 PAST the last digit. Decrement first.
    @gc_arrIdx
    M=M-1

(gc_EXTRACT_PRINT_LOOP)
    @gc_arrIdx
    D=M
    @gc_WAIT_ENTER
    D;JLT       // If index < 0, we are done printing

    // Load digit from RAM[2000 + idx]
    @gc_arrBase
    D=M
    @gc_arrIdx
    A=D+M
    D=M         // D now holds the digit (0-9)

    @gc_currKey
    M=D         // Set up for output function

    // Call Output
    @gc_PRINT_DIG_RET
    D=A
    @gc_OUTPUT_09_RETURN
    M=D
    @gc_OUTPUT_09
    0;JMP

(gc_PRINT_DIG_RET)
    @gc_arrIdx
    M=M-1       // Move to next digit (backwards)
    @gc_EXTRACT_PRINT_LOOP
    0;JMP

(gc_HANDLE_ZERO)
    @gc_Z_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_0
    0;JMP
(gc_Z_RET)
    @ge_currentColumn
    M=M+1
    @gc_WAIT_ENTER
    0;JMP


//************************* "WAIT FOR ENTER (RESET)" *************************************
// Description: Waits for user keypress after displaying the decimal result.
//              Handles Enter/c (restart), q (quit), ignores other keys.
// Input: Keyboard input from user
// Output: Jumps to cc_FULL_RESET on Enter/c, cc_QUIT_CLEAR_LOOP on q
(gc_WAIT_ENTER)
    // Loop until key is pressed
    @KBD
    D=M
    @gc_WAIT_ENTER
    D;JEQ

    @gc_tempKey
    M=D

    // Debounce: Wait for release
(gc_WAIT_RELEASE)
    @KBD
    D=M
    @gc_WAIT_RELEASE
    D;JNE

    // Process Key
    @gc_tempKey
    D=M

    // Check 'Enter' (128) -> Restart (Clear screen/buffers)
    @128
    D=D-A
    @cc_FULL_RESET
    D;JEQ

    // Check 'c' (67) -> Restart
    @gc_tempKey
    D=M
    @67
    D=D-A
    @cc_FULL_RESET
    D;JEQ

    // Check 'q' (81) -> Quit
    @gc_tempKey
    D=M
    @81
    D=D-A
    @cc_QUIT_CLEAR_LOOP   // <--- CHANGED: Go to clear routine
    D;JEQ

    // Ignore all other keys
    @gc_WAIT_ENTER
    0;JMP


//************************* "HARDCODED SPECIAL CASE (-32768)" *************************************
// Description: Handles the special case of -32768 which cannot be negated in 16-bit two's complement.
//              Manually prints "-32768" character by character.
// Input: None (called when ks_convRet equals -32768)
// Output: Prints "-32768" to screen, then jumps to gc_WAIT_ENTER
(gc_SPECIAL_MIN_INT)
    // Print -32768 manually
    @gc_SM_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_-
    0;JMP
(gc_SM_RET)
    @ge_currentColumn
    M=M+1
    
    // 3
    @gc_S3_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_3
    0;JMP
(gc_S3_RET)
    @ge_currentColumn
    M=M+1

    // 2
    @gc_S2_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_2
    0;JMP
(gc_S2_RET)
    @ge_currentColumn
    M=M+1

    // 7
    @gc_S7_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_7
    0;JMP
(gc_S7_RET)
    @ge_currentColumn
    M=M+1

    // 6
    @gc_S6_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_6
    0;JMP
(gc_S6_RET)
    @ge_currentColumn
    M=M+1

    // 8
    @gc_S8_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_8
    0;JMP
(gc_S8_RET)
    @ge_currentColumn
    M=M+1

    @gc_WAIT_ENTER
    0;JMP


//************************* "CONVERSION LOGIC" *************************************
// Description: Converts 16 binary bits stored in R0-R15 to a signed 16-bit integer.
//              Uses shift-and-add algorithm: result = result*2 + bit[i] for each bit.
// Input: R0-R15 containing binary bits (R0 = MSB, R15 = LSB)
// Output: ks_convRet contains the signed 16-bit integer result (-32768 to 32767)
(ks_conv16b)
    @ks_convRet
    M=0
    @0
    D=A
    @ks_conv_i
    M=D

(ks_CONV_LOOP)
    @ks_conv_i
    D=M
    @16
    D=D-A
    @ks_CONV_DONE
    D;JEQ

    // Shift Left (Result = Result * 2)
    @ks_convRet
    D=M
    M=D+M

    // Add Bit from RAM[R0 + i]
    @ks_conv_i
    D=M
    @R0
    A=A+D
    D=M
    @ks_convRet
    M=M+D

    @ks_conv_i
    M=M+1
    @ks_CONV_LOOP
    0;JMP

(ks_CONV_DONE)
    @gc_DISPLAY_START
    0;JMP


//************************* "BUFFER & RESET LOGIC" *************************************
// Description: Handles adding bits to buffer, deleting bits (backspace), and full reset operations.
//              ks_addBuf: Displays digit and stores in R0-R15 buffer
//              cc_DEL_BUFFER: Removes last entered bit and clears from display
//              cc_FULL_RESET: Clears entire display and resets all R0-R15 registers
//              cc_QUIT_CLEAR_LOOP: Clears display then terminates program
// Input: gc_currKey (for addBuf), gc_bitsEntered, ge_currentColumn
// Output: Updates R0-R15 buffer, gc_bitsEntered, ge_currentColumn, screen display
// Add 0 or 1
(ks_addBuf)
    @gc_currKey
    D=M
    // Temporarily set return for output function
    @ks_addBuf_Store
    D=A
    @gc_OUTPUT_09_RETURN
    M=D
    @gc_OUTPUT_09
    0;JMP

(ks_addBuf_Store)
    @gc_bitsEntered
    D=M
    @R0
    D=A+D       // Address = R0 + bitsEntered
    @gc_addrTemp
    M=D
    @gc_currKey
    D=M
    @gc_addrTemp
    A=M
    M=D         // Store in Memory
    @gc_bitsEntered
    M=M+1
    @gc_LOOP_START
    0;JMP

// Backspace Entry Point from Button (Only for Input correction)
(cc_DEL_BUFFER_BTN)
    // Setup return address to Main Loop
    @gc_LOOP_START
    D=A
    @cc_delBuffer_return
    M=D
    @cc_DEL_BUFFER_EXEC
    0;JMP

// Backspace Execution Logic (Deletes 1 Bit and 1 Char)
(cc_DEL_BUFFER_EXEC)
    @gc_bitsEntered
    D=M
    @cc_DEL_EXIT
    D;JEQ       // If 0 bits, cannot delete

    // Decrement Count
    @gc_bitsEntered
    M=M-1

    // Clear Memory
    D=M
    @R0
    A=A+D
    M=0

    // Visual Backspace
    @ge_currentColumn
    M=M-1       // Move cursor back

    // Print Space over the character
    @cc_DEL_EXIT
    D=A
    @ge_output_return
    M=D
    @ge_output_s
    0;JMP

(cc_DEL_EXIT)
    // Jump to the stored return address
    @cc_delBuffer_return
    A=M
    0;JMP

// ***************** FULL RESET FUNCTION *****************
// Clears visual line AND clears all memory registers R0-R15
(cc_FULL_RESET)

    // 1. VISUAL CLEAR LOOP
    // Keeps backspacing until ge_currentColumn is 0
(cc_VISUAL_CLEAR_LOOP)
    @ge_currentColumn
    D=M
    @cc_MEM_CLEAR_INIT
    D;JEQ       // If Col=0, visual is clear

    @ge_currentColumn
    M=M-1       // Back up 1
    
    // Draw Space
    @cc_VCL_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_s
    0;JMP

(cc_VCL_RET)
    @cc_VISUAL_CLEAR_LOOP
    0;JMP

    // 2. MEMORY CLEAR LOOP (HARD RESET)
    // Initializes a counter to 16 and clears R0 through R15 explicitly
(cc_MEM_CLEAR_INIT)
    @16
    D=A
    @gc_clrIdx
    M=D

(cc_MEM_CLEAR_LOOP)
    @gc_clrIdx
    D=M
    @cc_RESET_DONE
    D;JEQ
    
    @gc_clrIdx
    M=M-1       // 16 -> 15
    D=M         // D=15
    @R0
    A=A+D       // Address = R0 + 15
    M=0         // Clear Bit
    
    @cc_MEM_CLEAR_LOOP
    0;JMP

(cc_RESET_DONE)
    @gc_RESTART
    0;JMP

// ***************** QUIT CLEAR LOOP (NEW) *****************
// Clears visual line then goes to END
(cc_QUIT_CLEAR_LOOP)
    @ge_currentColumn
    D=M
    @END
    D;JEQ       // If Col=0, visual is clear, go to END

    @ge_currentColumn
    M=M-1       // Back up 1
    
    // Draw Space
    @cc_QCL_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_s
    0;JMP

(cc_QCL_RET)
    @cc_QUIT_CLEAR_LOOP
    0;JMP


//************************* "INPUT ROUTINE" *************************************
// Description: Reads keyboard input and waits for a valid key press with debouncing.
//              Converts ASCII '0' (48) and '1' (49) to literal values 0 and 1.
//              Other valid keys (c, q, Enter, Backspace) are passed through as ASCII.
// Input: User keyboard input from KBD memory-mapped register
// Output: D register contains key value (0, 1, or ASCII code), returns to jm_getKeyReturn
(jm_getKey)                 
(jm_getKey_waitPress)       
    @KBD                        
    D=M                         
    @jm_getKey_waitPress        
    D;JEQ                       
    @jm_keyTemp                 
    M=D                         
    @48
    D=D-A
    @jm_key0
    D;JEQ
    @jm_keyTemp
    D=M
    @49
    D=D-A
    @jm_key1
    D;JEQ
    @jm_validKey
    0;JMP
(jm_key0)                   
    @jm_keyTemp                 
    M=0                         
    @jm_validKey                
    0;JMP
(jm_key1)                   
    @jm_keyTemp                 
    M=1                         
    @jm_validKey                
    0;JMP
(jm_validKey)               
    @jm_getKey_afterDebounce    
    D=A                         
    @jm_keyDebounce_return      
    M=D                         
    @jm_keyDebounce             
    0;JMP
(jm_getKey_afterDebounce)   
    @jm_keyTemp                 
    D=M                         
    @jm_getKeyReturn            
    0;JMP
(jm_keyDebounce)
    @KBD                         
    D=M                           
    @jm_keyDebounce              
    D;JNE                        
    @jm_keyDebounce_return       
    A=M                          
    0;JMP                        


//************************* "OUTPUT SUBROUTINE" *************************************
// Description: Dispatches to the correct digit output routine based on gc_currKey value (0-9).
//              Calls the appropriate ge_output_X function and increments column position.
// Input: gc_currKey containing digit value 0-9, gc_OUTPUT_09_RETURN containing return address
// Output: Displays digit at current column, increments ge_currentColumn, returns via gc_OUTPUT_09_RETURN
(gc_OUTPUT_09)
    @gc_currKey
    D=M
    @gc_D0
    D;JEQ
    D=D-1
    @gc_D1
    D;JEQ
    D=D-1
    @gc_D2
    D;JEQ
    D=D-1
    @gc_D3
    D;JEQ
    D=D-1
    @gc_D4
    D;JEQ
    D=D-1
    @gc_D5
    D;JEQ
    D=D-1
    @gc_D6
    D;JEQ
    D=D-1
    @gc_D7
    D;JEQ
    D=D-1
    @gc_D8
    D;JEQ
    D=D-1
    @gc_D9
    D;JEQ
    @gc_OUTPUT_09_RETURN
    A=M
    0;JMP

(gc_D0)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_0
    0;JMP
(gc_D1)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_1
    0;JMP
(gc_D2)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_2
    0;JMP
(gc_D3)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_3
    0;JMP
(gc_D4)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_4
    0;JMP
(gc_D5)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_5
    0;JMP
(gc_D6)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_6
    0;JMP
(gc_D7)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_7
    0;JMP
(gc_D8)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_8
    0;JMP
(gc_D9)
    @gc_DX_RET
    D=A
    @ge_output_return
    M=D
    @ge_output_9
    0;JMP
(gc_DX_RET)
    @ge_currentColumn
    M=M+1
    @gc_OUTPUT_09_RETURN
    A=M
    0;JMP


//************************* "MATH LIBRARY" *************************************
// Description: Performs signed integer division using repeated subtraction algorithm.
//              Handles all sign combinations for dividend and divisor.
// Input: R100 = dividend, R101 = divisor, ks_Div_return = return address
// Output: R102 = quotient, R103 = remainder, returns via ks_Div_return
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

//************************* "MULT" *************************************
// Description: Multiplies two signed 16-bit integers using repeated addition.
//              Handles negative operands by converting to positive and adjusting sign.
// Input: R100 = multiplicand, R101 = multiplier, ks_Mult_return = return address
// Output: R102 = product (R100 * R101), returns via ks_Mult_return
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

//************************* "POW" *************************************
// Description: Computes base raised to the power of exponent using repeated multiplication.
//              Calls ks_Mult repeatedly to compute the result.
// Input: R103 = base, R104 = exponent, ks_Pow_return = return address
// Output: R105 = result (R103 ^ R104), returns via ks_Pow_return
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

//************************* "FONT LIBRARY" *************************************
// Description: Low-level font rendering library that draws 6x9 pixel characters to the screen.
//              ge_continue_output: Core routine that writes 9 font rows to screen memory.
//              ge_output_X: Individual character routines that set font row data then call ge_continue_output.
//              Supported characters: 0-9, space, minus (-), greater-than (>), plus (+)
// Input: ge_currentColumn = x position, ge_fontRow1-9 = pixel data for each row, ge_output_return = return address
// Output: Character drawn at screen position, returns via ge_output_return
(ge_continue_output)
@32
D=A
@ge_rowOffset
M=D
@SCREEN
D=A
@ge_rowOffset
D=D+M
D=D+M
D=D+M
@ge_currentColumn
D=D+M
@ge_currentRow
M=D
@ge_fontRow1
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow2
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow3
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow4
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow5
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow6
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow7
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow8
D=M
@ge_currentRow
A=M
M=D
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
@ge_fontRow9
D=M
@ge_currentRow
A=M
M=D
@ge_output_return
A=M
0;JMP
(ge_output_0)
@12
D=A
@ge_fontRow1
M=D
@30
D=A
@ge_fontRow2
M=D
@51
D=A
@ge_fontRow3
M=D
@51
D=A
@ge_fontRow4
M=D
@51
D=A
@ge_fontRow5
M=D
@51
D=A
@ge_fontRow6
M=D
@51
D=A
@ge_fontRow7
M=D
@30
D=A
@ge_fontRow8
M=D
@12
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_1)
@12
D=A
@ge_fontRow1
M=D
@14
D=A
@ge_fontRow2
M=D
@15
D=A
@ge_fontRow3
M=D
@12
D=A
@ge_fontRow4
M=D
@12
D=A
@ge_fontRow5
M=D
@12
D=A
@ge_fontRow6
M=D
@12
D=A
@ge_fontRow7
M=D
@12
D=A
@ge_fontRow8
M=D
@63
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_2)
@30
D=A
@ge_fontRow1
M=D
@51
D=A
@ge_fontRow2
M=D
@48
D=A
@ge_fontRow3
M=D
@24
D=A
@ge_fontRow4
M=D
@12
D=A
@ge_fontRow5
M=D
@6
D=A
@ge_fontRow6
M=D
@3
D=A
@ge_fontRow7
M=D
@51
D=A
@ge_fontRow8
M=D
@63
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_3)
@30
D=A
@ge_fontRow1
M=D
@51
D=A
@ge_fontRow2
M=D
@48
D=A
@ge_fontRow3
M=D
@48
D=A
@ge_fontRow4
M=D
@28
D=A
@ge_fontRow5
M=D
@48
D=A
@ge_fontRow6
M=D
@48
D=A
@ge_fontRow7
M=D
@51
D=A
@ge_fontRow8
M=D
@30
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_4)
@16
D=A
@ge_fontRow1
M=D
@24
D=A
@ge_fontRow2
M=D
@28
D=A
@ge_fontRow3
M=D
@26
D=A
@ge_fontRow4
M=D
@25
D=A
@ge_fontRow5
M=D
@63
D=A
@ge_fontRow6
M=D
@24
D=A
@ge_fontRow7
M=D
@24
D=A
@ge_fontRow8
M=D
@60
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_5)
@63
D=A
@ge_fontRow1
M=D
@3
D=A
@ge_fontRow2
M=D
@3
D=A
@ge_fontRow3
M=D
@31
D=A
@ge_fontRow4
M=D
@48
D=A
@ge_fontRow5
M=D
@48
D=A
@ge_fontRow6
M=D
@48
D=A
@ge_fontRow7
M=D
@51
D=A
@ge_fontRow8
M=D
@30
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_6)
@28
D=A
@ge_fontRow1
M=D
@6
D=A
@ge_fontRow2
M=D
@3
D=A
@ge_fontRow3
M=D
@3
D=A
@ge_fontRow4
M=D
@31
D=A
@ge_fontRow5
M=D
@51
D=A
@ge_fontRow6
M=D
@51
D=A
@ge_fontRow7
M=D
@51
D=A
@ge_fontRow8
M=D
@30
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_7)
@63
D=A
@ge_fontRow1
M=D
@49
D=A
@ge_fontRow2
M=D
@48
D=A
@ge_fontRow3
M=D
@48
D=A
@ge_fontRow4
M=D
@24
D=A
@ge_fontRow5
M=D
@12
D=A
@ge_fontRow6
M=D
@12
D=A
@ge_fontRow7
M=D
@12
D=A
@ge_fontRow8
M=D
@12
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_8)
@30
D=A
@ge_fontRow1
M=D
@51
D=A
@ge_fontRow2
M=D
@51
D=A
@ge_fontRow3
M=D
@51
D=A
@ge_fontRow4
M=D
@30
D=A
@ge_fontRow5
M=D
@51
D=A
@ge_fontRow6
M=D
@51
D=A
@ge_fontRow7
M=D
@51
D=A
@ge_fontRow8
M=D
@30
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_9)
@30
D=A
@ge_fontRow1
M=D
@51
D=A
@ge_fontRow2
M=D
@51
D=A
@ge_fontRow3
M=D
@51
D=A
@ge_fontRow4
M=D
@62
D=A
@ge_fontRow5
M=D
@48
D=A
@ge_fontRow6
M=D
@48
D=A
@ge_fontRow7
M=D
@25
D=A
@ge_fontRow8
M=D
@14
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_s)
@0
D=A
@ge_fontRow1
M=D
@0
D=A
@ge_fontRow2
M=D
@0
D=A
@ge_fontRow3
M=D
@0
D=A
@ge_fontRow4
M=D
@0
D=A
@ge_fontRow5
M=D
@0
D=A
@ge_fontRow6
M=D
@0
D=A
@ge_fontRow7
M=D
@0
D=A
@ge_fontRow8
M=D
@0
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_-)
@0
D=A
@ge_fontRow1
M=D
@0
D=A
@ge_fontRow2
M=D
@0
D=A
@ge_fontRow3
M=D
@0
D=A
@ge_fontRow4
M=D
@0
D=A
@ge_fontRow5
M=D
@63
D=A
@ge_fontRow6
M=D
@0
D=A
@ge_fontRow7
M=D
@0
D=A
@ge_fontRow8
M=D
@0
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_g)
@0
D=A
@ge_fontRow1
M=D
@0
D=A
@ge_fontRow2
M=D
@3
D=A
@ge_fontRow3
M=D
@6
D=A
@ge_fontRow4
M=D
@12
D=A
@ge_fontRow5
M=D
@24
D=A
@ge_fontRow6
M=D
@12
D=A
@ge_fontRow7
M=D
@6
D=A
@ge_fontRow8
M=D
@3
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP
(ge_output_+)
@0
D=A
@ge_fontRow1
M=D
@0
D=A
@ge_fontRow2
M=D
@0
D=A
@ge_fontRow3
M=D
@12
D=A
@ge_fontRow4
M=D
@12
D=A
@ge_fontRow5
M=D
@63
D=A
@ge_fontRow6
M=D
@12
D=A
@ge_fontRow7
M=D
@12
D=A
@ge_fontRow8
M=D
@0
D=A
@ge_fontRow9
M=D
@ge_continue_output
0;JMP