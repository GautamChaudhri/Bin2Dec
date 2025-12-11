// This file uses the Hack language and fonts
// that are part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
//
// coded by George Eaton November 2020 for CS 3A

//
// functions ge_output_X (where X is one of the characters 0,1,2,3,4,5,6,7,8,9,0,- (minus),
//                        + (plus), s (space bar), or g (greater than  > )
//
// Outputs character X (see above) at a specified column, where columns run from
// 0 to 31.
//
// Call ge_output_X as follows (Pre-conditions):
//     - save return address in ge_output_return
//     - save the current column (starting with 0 for the first column) in
//       variable ge_currentColumn
//     - jump to ge_output_X to output the character X in
//       column ge_currentColumn, where X is one of the
//       the characters 0,1,2,3,4,5,6,7,8,9,0,-,+,s, or g
//
// Result (Post-conditions) is character X is output on the display at column ge_currentColumn
//


// //************************* "gc_OUTOUT_MOST_NEGATIVE" *****************************************












@ge_currentColumn
M=0
@0
D=A
@24576
D=D-A
@8192
D=D-A
@gc_dec_digit
M=D
@mostNegative
M=D
//************************* "gc_OUTPUT_DECIMAL" *****************************************
// 0) Output -> first
@gc_PRINT_G
D=A 
@ge_output_return
M=D
@ge_output_-            // print -
0;JMP

(gc_PRINT_G)
@ge_currentColumn
M=M+1                   // increment current column since - just printed

@gc_0CASE
D=A 
@ge_output_return
M=D
@ge_output_g            // print >
0;JMP

// 1) Check for special case: gc_dec_digit = 0
// If true, then print 0 to display and terminate function call
(gc_0CASE)
@ge_currentColumn
M=M+1                   // increment current column since > just printed

@gc_dec_digit
D=M
@gc_OD_CHECKSIGN        
D;JNE                   // if gc_dec_digit != 0, then jump to CHECKSIGN

@END                    // otherwise gc_dec_digit = 0 so fall through and deal with it
D=A 
@ge_output_return       // set return address to end after function call
M=D 
@ge_output_0            // print 0 to display, then terminate function
0;JMP


// 2) Check if decimal is positive or negative and then print corresponding sign to screen
(gc_OD_CHECKSIGN)
@gc_dec_digit
D=M 
@gc_OD_NEG
D;JLT                   // if gc_dec_digit < 0, then number is negative, jump and prepare to call output_-

@gc_OD_EXTRACT           // else gc_dec_digit is positive, fall through and prepare to call output_+
D=A 
@ge_output_return       // set return address of function call to be next step, EXTRACT
M=D 
@ge_output_+            // call function and print + to screen
0;JMP

(gc_OD_NEG)             // gc_dec_digit is negative, first negate gc_dec_digit so - is not extracted in the next step
@gc_dec_digit
D=M
@R0                     // R0 = gc_dec_digit
M=D 
@R1                     // R1 = -1
M=-1

// Use mult to negate gc_dec_digit
@gc_OD_NEG_NEXT         // set return point
D=A 
@ks_Mult_return
M=D
@ks_Mult                // R0 * R1 = R2
0;JMP

(gc_OD_NEG_NEXT)
@R2                     // move mult result back in to gc_dec_digit
D=M
@gc_dec_digit                // gc_dec_digit = gc_dec_digit * -1
M=D 

// Now print - to display
@gc_OD_EXTRACT           
D=A 
@ge_output_return       // set return address of function call to be next step, EXTRACT
M=D 
@ge_output_-            // call function and print - to screen
0;JMP


// 3) Take decimal number and extract each number from each place value and store in reverse order in array
// Needed to find out which output_X function to call for each place value
(gc_OD_EXTRACT)
@ge_currentColumn
M=M+1               // increment since either + or - was just printed to the screen

@50
D=A
@gc_numArr          // initialize numArr
M=D

// Place decimal number in new variable so original variable is not changed
@gc_dec_digit 
D=M
@gc_numHold
M=D 

// Divide numHold by 10, place remainder in numArry, repeat until numHold = 0
@gc_index
M=0
(gc_OD_EXTRACT_LOOP)
@gc_numHold
D=M
@R0
M=D             // R0 = numHold
@10
D=A 
@R1
M=D             // R1 = 10

@gc_OD_EXTRACT_NEXT
D=A 
@ks_Div_return     // set div return address
M=D 
@ks_Div            // R0 / R1 = R2, remainder in R3
0;JMP           // jump to Div function

(gc_OD_EXTRACT_NEXT)
@R2 
D=M 
@gc_numHold
M=D             // numHold = numHold / 10

@gc_numArr
D=M             // D = base address (2500)
@gc_index 
D=D+M           // D = base address + index
@gc_temp
M=D             // gc_temp = address of numArr[index]
@R3
D=M             // D = remainder value
@gc_temp
A=M             
M=D             // numArr[index] = remainder
@gc_index
M=M+1           // index++

@gc_numHold
D=M 
@gc_OD_EXTRACT_LOOP
D;JGT                   // restart loop if numHold > 0


// 4) Traverse num array in reverse and print each decimal value located in each element to screen by calling relevent
// output_X function
(gc_OD_PRINTDEC_LOOP)
// Copy last digit in array to gc_digit, the parameter of gc_OUTPUT_09
@gc_index 
M=M-1               // index--
@gc_numArr
D=M
@gc_index
A=D+M
D=M                 // D = numArr[index]
@gc_digit
M=D                 // gc_digit = D
             

// Call helper function OUTPUT_09 and let it handle printing to display
@gc_PRINTDEC_NEXT
D=A 
@gc_OUTPUT_09_RETURN    // set return point for function call
M=D
@gc_OUTPUT_09           // jump to function
0;JMP

(gc_PRINTDEC_NEXT)
@gc_index
D=M
@gc_OD_PRINTDEC_LOOP
D;JGT                   // if gc_index >= 0, then loop again

(END)
@END
0;JMP
//************************* "gc_OUTPUT_DECIMAL END" *************************************

// FUNCTION
// Outputs numbers 0-9 to the display using gc_digit as its parameter, updates ge_current_column accordingly
(gc_OUTPUT_09)         
@gc_digit                 
D=M                     // D = gc_digit

// Switch statement to find what number 0-9 gc_digit is
@gc_DRAW0
D;JEQ                   // key = 0
D=D-1
@gc_DRAW1
D;JEQ                   // key = 1
D=D-1
@gc_DRAW2
D;JEQ                   // key = 2
D=D-1
@gc_DRAW3
D;JEQ                   // key = 3
D=D-1
@gc_DRAW4
D;JEQ                   // key = 4
D=D-1
@gc_DRAW5
D;JEQ                   // key = 5
D=D-1
@gc_DRAW6
D;JEQ                   // key = 6
D=D-1
@gc_DRAW7
D;JEQ                   // key = 7
D=D-1
@gc_DRAW8
D;JEQ                   // key = 8
D=D-1
@gc_DRAW9
D;JEQ                   // key = 9

@gc_OUTPUT_09_RETURN    // default case, key is not 0-9
A=M                     // so print nothing and abort function
0;JMP

// Draw corresponding digit on display
(gc_DRAW0)                 // 0
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_0            // draw 0 on screen
0;JMP

(gc_DRAW1)                 // 1
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_1            // draw 1 on screen
0;JMP

(gc_DRAW2)                 // 2
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_2            // draw 2 on screen
0;JMP

(gc_DRAW3)                 // 3
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_3            // draw 3 on screen
0;JMP

(gc_DRAW4)                 // 4
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_4            // draw 4 on screen
0;JMP

(gc_DRAW5)                 // 5
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_5            // draw 5 on screen
0;JMP

(gc_DRAW6)                 // 6
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_6            // draw 6 on screen
0;JMP

(gc_DRAW7)                 // 7
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_7            // draw 7 on screen
0;JMP

(gc_DRAW8)                 // 8
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_8            // draw 8 on screen
0;JMP

(gc_DRAW9)                 // 9
@gc_NEXT                // return point after ge_output function call
D=A
@ge_output_return
M=D
@ge_output_9            // draw 9 on screen
0;JMP

// Jump back
(gc_NEXT)
@ge_currentColumn       // increment current column index
M=M+1
@gc_OUTPUT_09_RETURN    // jump back to function call
A=M
0;JMP








// @test_currKey
// M=1
// //************************* "gc_OUTPUT_01" *****************************************
// @ge_currentColumn         // track column to draw in
// M=0

// @test_currKey       // get current key and see if it is a 0 or 1
// D=M
// @DRAW0
// D;JEQ               // if key = 0, jump to correct location to draw 0

// // DRAW1
// @gc_ADDSPACE            // otherwise, key = 1 so draw 1
// D=A
// @ge_output_return       // set return address
// M=D
// @ge_output_1            // draw 1 on screen
// 0;JMP

// (DRAW0)
// @gc_ADDSPACE            // set return address
// D=A
// @ge_output_return
// M=D
// @ge_output_0            // draw 0 on screen
// 0;JMP

// (gc_ADDSPACE)           // draw space after drawing character
// @ge_currentColumn       // increment current bit index
// M=M+1
// @gc_NEXT                // set return address
// D=A
// @ge_output_return
// M=D
// @ge_output_s
// 0;JMP

// (gc_NEXT)
// @ge_currentColumn       // increment current bit index
// M=M+1


// (END)
// @END
// 0;JMP

//************************* "gc_OUTPUT_01 END" *************************************


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

// Mult function
// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
// The algorithm handles positive and negative operands.
(ks_Mult)
    @R2
    M=0
    @R0
    D=M
    @ks_mul_tmp_X
    M=D
    @R1
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
        @R2
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

// Div function
// Performs integer (Euclidean) division: R0 / R1 = R2  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])
// The remainder is stored in R3.
// Usage: Before executing, put the dividend in R0 and the divisor in R1.
(ks_Div)
    @R0
    D=M
    @R1
    A=M
    D=A
    @ks_Div_sigfpe
    D;JEQ
    @R0
    D=M
    @ks_Div_posDividend
    D;JGE
    @ks_Div_negDividend
    0;JMP
    (ks_Div_posDividend)
        @R5
        M=0
        @R1
        D=M
        @ks_Div_posDivisor
        D;JGE
        @ks_Div_negDivisor
        0;JMP
    (ks_Div_negDividend)
        @R5
        M=1
        @R1
        D=M
        @ks_Div_posDivisor
        D;JGE
        @ks_Div_negDivisor
        0;JMP
    (ks_Div_posDivisor)
        @R1
        D=M
        @R4
        M=D
        @R6
        M=0
        @ks_Div_runAlgorithm
        0;JMP
    (ks_Div_runAlgorithm)
        @R5
        D=M
        @ks_Div_runAlgorithm_posdiv
        D;JEQ
        @R0
        D=M
        D=-D
        @R3
        M=D
        @ks_Div_runAlgorithm_after
        0;JMP
    (ks_Div_runAlgorithm_posdiv)
        @R0
        D=M
        @R3
        M=D
    (ks_Div_runAlgorithm_after)
        @R2
        M=0
    (ks_Div_algo1)
        @R3
        D=M
        @R4
        D=D-M
        @ks_Div_endAlgo1
        D;JLT
        @R3
        M=D
        @R2
        D=M
        D=D+1
        @R2
        M=D
        @ks_Div_algo1
        0;JMP
    (ks_Div_negDivisor)
        @R1
        D=M
        D=-D
        @R4
        M=D
        @R6
        M=1
        @ks_Div_runAlgorithm
        0;JMP
    (ks_Div_sigfpe)
        @R2
        M=0
        @R0
        D=M
        @ks_Div_sigfpe_nonzero_dividend
        D;JNE
        @R3
        M=-1
        @R3
        M=M-1
        @ks_Div_halt
        0;JMP
    (ks_Div_endAlgo1)
        @R5
        D=M
        @ks_Div_dividend_nonneg
        D;JEQ
        @R6
        D=M
        @ks_Div_both_negative
        D;JNE
        @R3
        D=M
        @ks_Div_div_neg_divpos_rem_zero
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
        @ks_Div_halt
        0;JMP
    (ks_Div_div_neg_divpos_rem_zero)
        @R2
        D=M
        D=-D
        @R2
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_both_negative)
        @R3
        D=M
        @ks_Div_both_neg_rem_zero
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
        @R2
        D=M
        D=-D
        @R2
        M=D
        @ks_Div_halt
        0;JMP
    (ks_Div_sigfpe_nonzero_dividend)
        @R3
        M=-1
        @ks_Div_halt
        0;JMP
    (ks_Div_halt)
        @ks_Div_return
        A=M
        0;JMP