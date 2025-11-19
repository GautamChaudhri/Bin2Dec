// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: Bin2Dec.asm

// Performs a binary-to-decimal conversion using a combination of the functions already defined in Mult.asm, Pow.asm, and Div.asm in the same directory

// TODO: ks_processBuf, ks_getKey
// NOTES: 
// * current condition checks check against 0 and 1 literally instead of their ASCII values. So getKey should convert
//      characters 0-9 from their ASCII values to their literal values and store them in currKey
//      non-numeric characters should remain as ASCII values
// * Condition 2 and 3 need safety checks for when entered bits = 0. 
// * Condition 1 should check for < 16 bits, not <= 16 bits as it says in the flowchart because if 
//      there are already 16 bits and it continues, then we end up with overflow

//************************* "MAIN" *****************************************
(gc_RESTART)
// set important variables to their initial values
@ge_currentColumn   // track column to draw in
M=0
@gc_bitsEntered     // keeps track of number of bits entered, if-else structure depends on this
M=0                 

(gc_LOOP_START)
// 0) get_key function call goes here
@gc_currKey         // this should be the return value of get_key, the if-else structure depends on this
M=1                 // just a test value for now until get_key is done


// Now begin if else structure to decide what happens next

// 1) If current key = 0 or 1 and <= 16 bits entered, then draw 0 or 1 and add to buffer
@gc_currKey
D=M
@0_16BITCHECK
D;JEQ               // if currKey = 0, then jump to 0-16 bit check
D-1;JEQ             // else if currKey = 1, then also jump to 0-16 bit check
@CONDITION2         // otherwise currKey is neither, jump to next condition check
0;JMP

(0_16BITCHECK)          // check if <= 16 bits entered
@16
D=A 
@gc_bitsEntered
D=M-D                   // bitsEntered - 16
@gc_CONDITION1_MET
D;JLE                   // if bitsEntered - 16 <= 0 is true, then do the next steps
@gc_CONDITION2          
0;JMP                   // otherwise its false and jump to next condition check

(gc_CONDITION1_MET)     // now call gc_OUTPUT_01 and then addBuf
@gc_CONDITION1_NEXT     // setup function call, this is return point
D=A 
@gc_OUTPUT_01_RETURN
M=D 
@gc_OUTPUT_01
0;JMP

(gc_CONDITION1_NEXT)
//addBuf function call goes HERE
@gc_LOOP_START          // after function call, restart loop to get the next key
0;JMP



// 2) If current key = backspace, then remove last input
(gc_CONDITION2)
@129                // ASCII value for backspace
D=A 
@gc_currKey
D=M-D               // currKey value - backspace ASCII value 
@gc_CONDITION2_MET
D;JEQ               // if currKey is backspace, then do next steps
@gc_CONDITION3      // otherwise it is not backspace so jump to next condition check
0;JMP

(gc_CONDITION2_MET)
//delBuf function call goes here
@gc_LOOP_START          // after function call, restart loop to get the next key
0;JMP



// 3) If current key = c, then clear whole buffer
(gc_CONDITION3)
@99                 // ASCII value for c
D=A 
@gc_currKey
D=M-D               // currKey value - c ASCII value 
@gc_CONDITION3_MET
D;JEQ               // if currKey is c, then do next steps
@gc_CONDITION4      // otherwise it is not c so jump to next condition check
0;JMP

(gc_CONDITION3_MET)
//clearBuf function call goes here
@gc_LOOP_START          // after function call, restart loop to get the next key
0;JMP



// 4) If current key = c, then clear whole buffer AND terminate program
(gc_CONDITION4)
@113                // ASCII value for q
D=A 
@gc_currKey
D=M-D               // currKey value - q ASCII value 
@gc_CONDITION4_MET
D;JEQ               // if currKey is q, then do next steps
@gc_CONDITION5      // otherwise it is not q so jump to next condition check
0;JMP

(gc_CONDITION4_MET)
//clearBuf function call goes here
@END                // terminate program
0;JMP



// 5) If current key = enter AND exactly 16 bits entered, then process buffer
(gc_CONDITION5)
@128                // ASCII value for enter
D=A 
@gc_currKey
D=M-D               // currKey value - enter ASCII value 
@16BITCHECK
D;JEQ               // if currKey is enter, then jump to 16 bit check
@gc_LOOP_START      // otherwise it is not enter so restart loop
0;JMP

(16BITCHECK)
@16
D=A 
@gc_bitsEntered
D=M-D                   // bitsEntered - 16
@gc_CONDITION5_MET
D;JEQ                   // if bitsEntered - 16 = 0 is true, then do the next steps
@gc_LOOP_START          
0;JMP                   // otherwise its false so restart loop

(gc_CONDITION5_MET)
// processBuf and steps after that go here


(END)
@END
0;JMP

//************************* "END MAIN" *************************************

// Outputs 0 or 1 to the display followed by a blank space, updates current column accordingly
(gc_OUTPUT_01)         
@gc_currKey             // get current key and see if it is a 0 or 1
D=M
@DRAW0
D;JEQ                   // if key = 0, jump to correct location to draw 0

// DRAW1
@gc_ADDSPACE            // otherwise, key = 1 so draw 1
D=A
@ge_output_return       // set return address
M=D
@ge_output_1            // draw 1 on screen
0;JMP

(DRAW0)
@gc_ADDSPACE            // set return address
D=A
@ge_output_return
M=D
@ge_output_0            // draw 0 on screen
0;JMP

(gc_ADDSPACE)           // draw space after drawing character
@ge_currentColumn       // increment current bit index
M=M+1
@gc_NEXT                // set return address
D=A
@ge_output_return
M=D
@ge_output_s
0;JMP

(gc_NEXT)
@ge_currentColumn       // increment current bit index
M=M+1
@gc_OUTPUT_01_RETURN    // jump back to function call
A=M
0;JMP


// Mult function
// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
// The algorithm handles positive and negative operands.
(Mult)
    @R2
    M=0
    @R0
    D=M
    @mul_tmp_X
    M=D
    @R1
    D=M
    @mul_tmp_Y
    M=D
    @mul_tmp_Y
    D=M
    @Mult_endLoop
    D;JEQ
    @mul_tmp_Y
    D=M
    @Mult_isNegativeMultiplier
    D;JLT
    (Mult_isPositiveMultiplier)
        @mul_tmp_X
        D=M
        @R2
        M=D+M
        @mul_tmp_Y
        M=M-1
        D=M
        @Mult_isPositiveMultiplier
        D;JGT
        @Mult_endLoop
        0;JMP
    (Mult_isNegativeMultiplier)
        @mul_tmp_X
        D=-M
        @mul_tmp_X
        M=D
        @mul_tmp_Y
        M=-M
        @Mult_isPositiveMultiplier
        0;JMP
    (Mult_endLoop)
        @R14
        A=M
        0;JMP

// Pow function
// Uses Mult to compute R5 = R3 ^ R4 (R3 = base, R4 = exponent, R5 = result).
// R8 is used as the exponent counter. R5 is initialized to 1 and repeatedly
// multiplied by R3 using the Mult routine R4 times.
(Pow)
    @R5
    M=1
    @R4
    D=M
    @R8
    M=D
    (Pow_startLoop)
        @R8
        D=M
        @Pow_endPower
        D;JEQ
        @R5
        D=M
        @R0
        M=D
        @R3
        D=M
        @R1
        M=D
        @Mult
        @Pow_mulRet
        0;JMP
    (Pow_mulRet)
        @R2
        D=M
        @R5
        M=D
        @R8
        M=M-1
        @Pow_startLoop
        0;JMP
    (Pow_endPower)
        @R14
        A=M
        0;JMP

// Div function
// Performs integer (Euclidean) division: R0 / R1 = R2  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])
// The remainder is stored in R3.
// Usage: Before executing, put the dividend in R0 and the divisor in R1.
(Div)
    @R0
    D=M
    @R1
    A=M
    D=A
    @Div_sigfpe
    D;JEQ
    @R0
    D=M
    @Div_posDividend
    D;JGE
    @Div_negDividend
    0;JMP
    (Div_posDividend)
        @R5
        M=0
        @R1
        D=M
        @Div_posDivisor
        D;JGE
        @Div_negDivisor
        0;JMP
    (Div_negDividend)
        @R5
        M=1
        @R1
        D=M
        @Div_posDivisor
        D;JGE
        @Div_negDivisor
        0;JMP
    (Div_posDivisor)
        @R1
        D=M
        @R4
        M=D
        @R6
        M=0
        @Div_runAlgorithm
        0;JMP
    (Div_runAlgorithm)
        @R5
        D=M
        @Div_runAlgorithm_posdiv
        D;JEQ
        @R0
        D=M
        D=-D
        @R3
        M=D
        @Div_runAlgorithm_after
        0;JMP
    (Div_runAlgorithm_posdiv)
        @R0
        D=M
        @R3
        M=D
    (Div_runAlgorithm_after)
        @R2
        M=0
    (Div_algo1)
        @R3
        D=M
        @R4
        D=D-M
        @Div_endAlgo1
        D;JLT
        @R3
        M=D
        @R2
        D=M
        D=D+1
        @R2
        M=D
        @Div_algo1
        0;JMP
    (Div_negDivisor)
        @R1
        D=M
        D=-D
        @R4
        M=D
        @R6
        M=1
        @Div_runAlgorithm
        0;JMP
    (Div_sigfpe)
        @R2
        M=0
        @R0
        D=M
        @Div_sigfpe_nonzero_dividend
        D;JNE
        @R3
        M=-1
        @R3
        M=M-1
        @Div_halt
        0;JMP
    (Div_endAlgo1)
        @R5
        D=M
        @Div_dividend_nonneg
        D;JEQ
        @R6
        D=M
        @Div_both_negative
        D;JNE
        @R3
        D=M
        @Div_div_neg_divpos_rem_zero
        D;JEQ
        @R2
        D=M
        D=-D
        D=D-1
        @R2
        M=D
        @R4
        D=M
        @R3
        D=D-M
        @R3
        M=D
        @Div_halt
        0;JMP
    (Div_div_neg_divpos_rem_zero)
        @R2
        D=M
        D=-D
        @R2
        M=D
        @Div_halt
        0;JMP
    (Div_both_negative)
        @R3
        D=M
        @Div_both_neg_rem_zero
        D;JEQ
        @R2
        D=M
        D=D+1
        @R2
        M=D
        @R4
        D=M
        @R3
        D=D-M
        @R3
        M=D
        @Div_halt
        0;JMP
    (Div_both_neg_rem_zero)
        @Div_halt
        0;JMP
    (Div_dividend_nonneg)
        @R6
        D=M
        @Div_div_pos_divneg
        D;JNE
        @Div_halt
        0;JMP
    (Div_div_pos_divneg)
        @R2
        D=M
        D=-D
        @R2
        M=D
        @Div_halt
        0;JMP
    (Div_sigfpe_nonzero_dividend)
        @R3
        M=-1
        @Div_halt
        0;JMP
    (Div_halt)
        @R14
        A=M
        0;JMP

// ge_continue_output
// this helper function ge_continue_output outputs the character defined by
// frontRow1 through initialized below it in the functions ge_output_X
(ge_continue_output)
//
// ***constants***
//
// ge_rowOffset - number of words to move to the next row of pixels
@32
D=A
@ge_rowOffset
M=D
// end of constants
//

//
// ***key variables***
//

// ge_currentRow - variable holding the display memory address to be written,
//                 which starts at the fourth row of pixels (SCREEN + 3 x rowOffset) 
//                 offset by the current column and
//                 increments row by row to draw the character
//               - initialized to the beginning of the fourth row in screen memory
//                 plus the current column
@SCREEN
D=A
@ge_rowOffset
// offset to the fourth row
D=D+M
D=D+M
D=D+M
// add the current column
@ge_currentColumn
D=D+M
@ge_currentRow
M=D
//


// write the first row of pixels
// load pattern in D via A
@ge_fontRow1
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//

// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow2
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow3
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow4
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow5
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow6
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow7
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow8
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//


// update current line
@ge_rowOffset
D=M
@ge_currentRow
M=D+M
// load pattern in D via A
@ge_fontRow9
D=M
// write pattern at currentLine
@ge_currentRow
A=M
M=D
//



// return from function
@ge_output_return
A=M
0;JMP



//
// individual function ge_output_X definitions which are 
// just font definitions for the helper function above
//

//ge_output_0
(ge_output_0)
//do Output.create(12,30,51,51,51,51,51,30,12); // 0

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
// end ge_output_0

//ge_output_1
(ge_output_1)
//do Output.create(12,14,15,12,12,12,12,12,63); // 1

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
// end ge_output_1

//ge_output_2
(ge_output_2)
//do Output.create(30,51,48,24,12,6,3,51,63);   // 2

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
// end ge_output_2


//ge_output_3
(ge_output_3)
//do Output.create(30,51,48,48,28,48,48,51,30); // 3

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
// end ge_output_3

//ge_output_4
(ge_output_4)
//do Output.create(16,24,28,26,25,63,24,24,60); // 4

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
// end ge_output_4

//ge_output_5
(ge_output_5)
//do Output.create(63,3,3,31,48,48,48,51,30);   // 5

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
// end ge_output_5

//ge_output_6
(ge_output_6)
//do Output.create(28,6,3,3,31,51,51,51,30);    // 6

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
// end ge_output_6

//ge_output_7
(ge_output_7)
//do Output.create(63,49,48,48,24,12,12,12,12); // 7

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
// end ge_output_7


//ge_output_8
(ge_output_8)
//do Output.create(30,51,51,51,30,51,51,51,30); // 8

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
// end ge_output_8



//ge_output_9
(ge_output_9)
//do Output.create(30,51,51,51,62,48,48,24,14); // 9

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
// end ge_output_9


//ge_output_s
(ge_output_s)
//do Output.create(0,0,0,0,0,0,0,0,0); // space

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

@0 // temporarily change to 255 so you can see it
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
// end ge_output_s



//ge_output_-
(ge_output_-)
//do Output.create(0,0,0,0,0,63,0,0,0);         // -

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

@63 // use 16128 to have minus to the right of the word
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
// end ge_output_-


//ge_output_g
(ge_output_g)
//do Output.create(0,0,3,6,12,24,12,6,3);       // >

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
// end ge_output_g


//ge_output_+
(ge_output_+)
//do Output.create(0,0,0,12,12,63,12,12,0);     // +

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
// end ge_output_+