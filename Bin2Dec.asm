// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: Bin2Dec.asm

// Performs a binary-to-decimal conversion using a combination of the functions already defined in Mult.asm, Pow.asm, and Div.asm in the same directory

// TODO: ks_processBuf, ks_getKey
// * current condition checks check against 0 and 1 literally instead of their ASCII values. So getKey should convert
//      characters 0-9 from their ASCII values to their literal values and store them in currKey
//      non-numeric characters should remain as ASCII values
// *DONE* | Condition 2 and 3 need safety checks for when entered bits = 0
// *DONE* | Condition 1 should check for < 16 bits, not <= 16 bits as it says in the flowchart because if 
//      there are already 16 bits and it continues, then we end up with overflow
// * Need default case at bottom of decision tree in main to return to getKey and restart loop

//************************* "MAIN" *****************************************
(gc_RESTART)
// set important variables to their initial values
@ge_currentColumn   // track column to draw in
M=0
@gc_bitsEntered     // keeps track of number of bits entered, if-else structure depends on this
M=0              

(gc_LOOP_START)
@jm_getKeyReturn              // set return address for jm_getKey
D=A
@jm_getKey_return
M=D
@jm_getKey
0;JMP

(jm_getKeyReturn) // Return from jm_getKey with key input in stored in D register

@gc_currKey     // this should be the return value of get_key, the if-else structure depends on this
M=D             // Stores value from D register (jm_getKey) into gc_currKey              // just a test value for now until get_key is done


// Now begin if else structure to decide what happens next

// 1) If current key = 0 or 1 and < 16 bits entered, then draw 0 or 1 and add to buffer
@gc_currKey
D=M
@0_16BIT_CHECK
D;JEQ               // if currKey = 0, then jump to 0-16 bit check
D-1;JEQ             // else if currKey = 1, then also jump to 0-16 bit check
@gc_CONDITION2      // otherwise currKey is neither, jump to next condition check
0;JMP

(0_16BIT_CHECK)          // check if < 16 bits entered
@16
D=A 
@gc_bitsEntered
D=M-D                   // bitsEntered - 16
@gc_CONDITION1_MET
D;JLT                   // if bitsEntered - 16 < 0 is true, then do the next steps
@gc_CONDITION2          
0;JMP                   // otherwise its false and jump to next condition check

(gc_CONDITION1_MET)     // now call gc_OUTPUT_09 and then addBuf
@gc_CONDITION1_NEXT     // setup function call, this is return point
D=A 
@gc_OUTPUT_09_RETURN
M=D 
@gc_OUTPUT_09
0;JMP

(gc_CONDITION1_NEXT)
@gc_LOOP_START
D=A
@ks_addBuf_hlt
M=D
@ks_addBuf          // after function call, restart loop to get the next key
0;JMP


// 2) If current key = backspace AND enteredBits > 0, then remove last input
(gc_CONDITION2)
@gc_CONDITION2_MET              // if 0BIT_CHECK is false, then backspace is permitted
D=A                             // so prepare jump to next steps on return from function call
@gc_0BIT_CHECK_FALSE_RETURN     
M=D 

@gc_LOOP_START                  // if 0BIT_CHECK is true, then backspace is not permitted
D=A                             // so jump back to loop start and wait for next key
@gc_0BIT_CHECK_TRUE_RETURN
M=D 

@129                // ASCII value for backspace
D=A 
@gc_currKey
D=M-D               // currKey value - backspace ASCII value 
@gc_0BIT_CHECK
D;JEQ               // if currKey is backspace, then jump to 0BIT_CHECK and let the function handle where to jump back to
@gc_CONDITION3      // otherwise it is not backspace so jump to next condition check
0;JMP

(gc_CONDITION2_MET)
@gc_LOOP_START          //access the next sequential label
D=A                     //store the label itself in D
@cc_delBuffer_return    //access the delete buffer return variable
M=D                     //store the label in the variable
@cc_DEL_BUFFER          //access the delete buffer function label
0;JMP                   //jump there unconditionally


// 3) If current key = c, then clear whole buffer
(gc_CONDITION3)
@gc_CONDITION3_CALL_CLEARBUF    // if 0BIT_CHECK is false, then clearbuf needs to be called
D=A                             // so prepare jump to call it on return from function call
@gc_0BIT_CHECK_FALSE_RETURN     
M=D 

@gc_LOOP_START                  // if 0BIT_CHECK is true, then buffer is already empty so 
D=A                             // clearbuf doesnt need to be called, jump straight to loop start
@gc_0BIT_CHECK_TRUE_RETURN
M=D 

@67                 // ASCII value for c
D=A 
@gc_currKey
D=M-D               // currKey value - c ASCII value 
@gc_0BIT_CHECK
D;JEQ               // if currKey is c, then jump to 0 bit check and let it handle where to jump control back to
@gc_CONDITION4      // otherwise it is not c so jump to next condition check
0;JMP

(gc_CONDITION3_CALL_CLEARBUF)
@gc_LOOP_START          //access the next sequential label
D=A                     //store the label itself in D
@cc_clrBuffer_return    //access the clear buffer return variable
M=D                     //store the label in the variable
@cc_CLEAR_BUFFER        //access the clear buffer function
0;JMP                   //jump there unconditionally


// 4) If current key = q, then clear whole buffer AND terminate program
(gc_CONDITION4)
@gc_CONDITION4_CALL_CLEARBUF    // if 0BIT_CHECK is false, then clearbuf needs to be called
D=A                             // so prepare jump to call it on return from function call
@gc_0BIT_CHECK_FALSE_RETURN     
M=D 

@END                            // if 0BIT_CHECK is true, then buffer is already empty so 
D=A                             // clearbuf doesnt need to be called, jump straight to terminate program
@gc_0BIT_CHECK_TRUE_RETURN
M=D 

@81                // ASCII value for q
D=A 
@gc_currKey
D=M-D               // currKey value - q ASCII value 
@gc_0BIT_CHECK
D;JEQ               // if currKey is q, then do next steps
@gc_CONDITION5      // otherwise it is not q so jump to next condition check
0;JMP

(gc_CONDITION4_CALL_CLEARBUF)
@END                    //access the next sequential label
D=A                     //store the label itself in D
@cc_clrBuffer_return    //access the clear buffer return variable
M=D                     //store the label in the variable
@cc_CLEAR_BUFFER        //access the clear buffer function
0;JMP                   //jump there unconditionally


// 5) If current key = enter AND exactly 16 bits entered, then process buffer
(gc_CONDITION5)
@128                // ASCII value for enter
D=A 
@gc_currKey
D=M-D               // currKey value - enter ASCII value 
@16BIT_CHECK
D;JEQ               // if currKey is enter, then jump to 16 bit check
@gc_LOOP_START      // otherwise it is not enter so restart loop
0;JMP

(16BIT_CHECK)
@16
D=A 
@gc_bitsEntered
D=M-D                   // bitsEntered - 16
@gc_CONDITION5_MET
D;JEQ                   // if bitsEntered - 16 = 0 is true, then do the next steps
@gc_LOOP_START          
0;JMP                   // otherwise its false so restart loop

(gc_CONDITION5_MET)
@gc_PROCESS_LOOP        // Jump to helper function that begins processing
0;JMP

(END)
@END
0;JMP
//************************* "END MAIN" *************************************





//************************* "gc_PROCESS_LOOP" *************************************
// 1) Call processBuf and then output to display
(gc_PROCESS_LOOP)
@gc_DISPLAY_DECIMAL         // set return address
D=A 
@ks_conv_return
M=D
@ks_conv16b                 // jump to processBuf function
0;JMP

(gc_DISPLAY_DECIMAL)
@ks_convRet              // copy over decimal value received into parameter for output decimal function
D=M 
@gc_dec_digit
M=D 

@gc_PROCESS_LOOP_NEXT       // set return address
D=A
@gc_OUTPUT_DECIMAL_RETURN 
M=D 
@gc_OUTPUT_DECIMAL          // jump to display
0;JMP

// 2) Get next key
(gc_PROCESS_LOOP_NEXT)
@gc_PROCESS_LOOP_KEY_RETURN   // set return address for jm_getKey
D=A
@jm_getKey_return
M=D
@jm_getKey
0;JMP


// 3) If current key = c or enter, then clear whole buffer
(gc_PROCESS_LOOP_KEY_RETURN)
@gc_currKey     // store returned key value
M=D

@gc_PL_CALL_CLEARBUF    // if 0BIT_CHECK is false, then clearbuf needs to be called
D=A                             // so prepare jump to call it on return from function call
@gc_0BIT_CHECK_FALSE_RETURN     
M=D 

@gc_RESTART                  // if 0BIT_CHECK is true, then buffer is already empty so 
D=A                             // clearbuf doesnt need to be called, jump straight to restart
@gc_0BIT_CHECK_TRUE_RETURN
M=D 

@67                 // ASCII value for c
D=A 
@gc_currKey
D=M-D               // currKey value - c ASCII value 
@gc_0BIT_CHECK
D;JEQ               // if currKey is c, then jump to 0 bit check and let it handle where to jump control back to

@128                 // ASCII value for c
D=A 
@gc_currKey
D=M-D               // currKey value - c ASCII value 
@gc_0BIT_CHECK
D;JEQ               // if currKey is c, then jump to 0 bit check and let it handle where to jump control back to

@gc_TERMINATE       // otherwise it is not c so jump to next condition check
0;JMP

(gc_PL_CALL_CLEARBUF)
@gc_RESTART             //access the next sequential label
D=A                     //store the label itself in D
@cc_clrBuffer_return    //access the clear buffer return variable
M=D                     //store the label in the variable
@cc_CLEAR_BUFFER        //access the clear buffer function
0;JMP                   //jump there unconditionally


// 4) If current key = q, then clear whole buffer AND terminate program
(gc_TERMINATE)
@gc_CLEAR_TERMINATE             // if 0BIT_CHECK is false, then clearbuf needs to be called
D=A                             // so prepare jump to call it on return from function call
@gc_0BIT_CHECK_FALSE_RETURN     
M=D 

@END                            // if 0BIT_CHECK is true, then buffer is already empty so 
D=A                             // clearbuf doesnt need to be called, jump straight to terminate program
@gc_0BIT_CHECK_TRUE_RETURN
M=D 

@81                // ASCII value for q
D=A 
@gc_currKey
D=M-D               // currKey value - q ASCII value 
@gc_0BIT_CHECK
D;JEQ                       // if currKey is q, then do next steps
@gc_PROCESS_LOOP_NEXT      // otherwise it is not q so get key again
0;JMP

(gc_CLEAR_TERMINATE)
@END                    //access the next sequential label
D=A                     //store the label itself in D
@cc_clrBuffer_return    //access the clear buffer return variable
M=D                     //store the label in the variable
@cc_CLEAR_BUFFER        //access the clear buffer function
0;JMP                   //jump there unconditionally





// Performs raw conversion logic (sum of product expansion) using Mult and Pow functions
// R0-R15 store the bits to convert in big-endian order (R0 = most significant bit)
// If R0 is 1, then we start counting at -32768, otherwise we start counting at 0
// We need to store the -32768 in 4 steps: @R0, D=A, @32768, D=D-A, because we can't directly @ a negative address
// In addition, we can't use any R0-R15 registers to perform any logic; we need to use variables to store anything that isn't a bit
// Store the result in ks_convRet, use ks_conv_i for the index, ks_conv_sum for the accumulator, and other ks_conv_* variables as needed
(ks_conv16b)
    // Special case: highest negative value detected
    @R0
    D=M
    @KS_MOST_NEGATIVE
    M=D
    M=1;JEQ

    // Initialize sum to 0
    @ks_conv_sum
    M=0

    // Initialize index
    @ks_conv_i
    M=0
    (ks_conv_loop)
        // for (i = 0; i < 16; ++i) and make sure we're starting from 0 and incrementing, NOT the other way around

        // Initialize incrementing (emphasis on incrementing) loop counter
        @ks_conv_i
        D=A
        @ks_conv_tmp
        M=D

        // Set exponent = 15 - i
        @R15
        D=A
        @ks_conv_tmp
        D=D-M
        @ks_conv_exp
        M=D

        // Get register address from ks_conv_tmp
        @ks_conv_tmp
        D=M
        
        // Load bit value from R[i]
        @ks_conv_i
        A=D+M
        D=M

        // Store into ks_conv_bitValue
        @ks_conv_bitValue
        M=D

        // Compute contribution: sum = bitValue + 2^(15 - i)
        // If bit is 0 then we're just adding 0 anyway, which is a no-op, so no need to check for that

        // Load address of R2 (which is always 2) into the base (which is the arbitrary variable name of R103 in our case)
        @R2
        D=A
        @R103
        M=D

        // Load exponent into R104
        @ks_conv_exp
        D=M
        @R104
        M=D

        // Call Pow subroutine
        @ks_Pow

        // Retrieve Pow result
        @ks_Pow_return
        D=M

        // Add to the sum (again, if bit is 0 then we're calculating 2^(15 - i) + 0, which is just 2^(15 - i) anyway)
        @ks_conv_sum
        M=D+M

        // Increment index
        @ks_conv_i
        A=A+1

        // Check loop condition (note that ks_conv_exp is just ks_conv_i inverted, making this, in theory, equivalent to i < 16)
        @ks_conv_exp
        D=M
        @ks_conv_loop
        0;JGT

        // Store final result in ks_convRet
        @ks_conv_sum
        D=M
        @ks_convRet
        M=D
        @24000
        M=D

        @ks_conv_return
        A=M
        0;JMP





//************************* "cc_DEL_BUFFER" *************************************
//after backspace is pressed, and if bits entered is more than 0
//deletes the previous bit entered from the user display and decrements
//the bits entered to reflect that change
(cc_DEL_BUFFER)
@gc_bitsEntered       //go to the amount of bits entered
D=M                   //store the variable's stored value in D
@cc_DEL_END           //access the end of this function
D;JEQ                 //jump to the end of the function if bits entered is 0
@ge_currentColumn     //get the current column
M=M-1                 //decrement by 1 to previous bit
@cc_CONTINUE_DEL      //set return
D=A                   //put the return in D
@ge_output_return     //access the output function return
M=D                   //put the return in the output function return
@ge_output_s          //access the space output function
0;JMP                 //jump there unconditionally

(cc_CONTINUE_DEL) 
@gc_bitsEntered       //access the bits entered again
M=M-1                 //decrement the amount stored by 1
A=M                   //access this previously entered bit
M=0                   //clear this bit

(cc_DEL_END)
@cc_delBuffer_return  //access the return for this function
A=M                   //set the address to the stored return
0;JMP                 //jump there unconditionally





//************************* "cc_CLEAR_BUFFER" *************************************
//after c is pressed, and if bits entered is more than 0
//takes the current amount of bits entered as a loop control
//and calls the delete buffer function that many times
//which resets bits entered to 0, gradually, to reflect the change
(cc_CLEAR_BUFFER)
@gc_bitsEntered       //go to the amount of bits entered
D=M                   //store the variable's stored value in D
@cc_CLEAR_END         //access the end of this function
D;JEQ                 //jump to the end of the function if bits entered is 0
@cc_bitsToClear       //create a variable tracking how many bits need clearing
M=D                   //store current bits entered there

(cc_CLEAR_LOOP)
@cc_bitsToClear       //access bits to clear
D=M                   //store its value in D
@cc_CLEAR_END         //access the end of this function
D;JEQ                 //jump when bits to clear is 0

@cc_DEL_RETURN        //access the delete function return
D=A                   //store this in D         
@cc_delBuffer_return  //access the return variable
M=D                   //store the function return in the return variable
@cc_DEL_BUFFER        //access the delete buffer function
0;JMP                 //jump there unconditionally

(cc_DEL_RETURN)
@cc_bitsToClear       //access bits to clear
M=M-1                 //decrement bits to clear
@cc_CLEAR_LOOP        //access the start of the loop
0;JMP                 //jump there unconditionally

(cc_CLEAR_END)
@cc_clrBuffer_return  //access the return for this function
A=M                   //set the address to the stored return
0;JMP                 //jump there unconditionally





//************************* "ks_addBuf" *************************************
//DESCRIPTION: Adds 0 or 1 to buffer
//INPUT: gc_currKey holds the value of either 0 or 1
//OUTPUT: the bit has been entered into the buffer
(ks_addBuf)
    // Load current bit from gc_currKey
    @gc_currKey
    D=M

    // Store bit into R[gc_bitsEntered]
    @gc_bitsEntered
    A=M // R[gc_bitsEntered]
    M=D

    // Increment gc_bitsEntered by 1 after having stored the bit
    @gc_bitsEntered
    M=M+1

    // Exit function; this is only called when the a key is pressed
    @ks_addBuf_hlt
    A=M
    0;JMP




//************************* "jm_getKey" *************************************
// Description: Reads ASCII data from keyboard 
// Input: User keyboard input
// Output: Output literal value for '0' and '1' OR ASCII value for keys 'c', 'q', 'enter', and 'backspace'
(jm_getKey)                 // Primary loop that waits for a key press and debounces it
(jm_getKey_waitPress)       // Secondary loop that waits for a key press

// === Loads key press and stores in temp. variable ===
@KBD                        // Stores keyboard input into A register
D=M                         // Load RAM [A] ASCII value into D 
@jm_getKey_waitPress        // Load jm_getKey_waitPress into A register
D;JEQ                       // Loop back to (jm_getKey_waitPress) if no value detected in D (D = '0' / NULL)
@jm_keyTemp                 // Loads temp. variable location into A register
M=D                         // Stores the ASCII value of the key pressed into RAM [A]

// === Check for '0' (48) ===
@48                         // Loads 48 into A register
D=D-A                       // Subtracts 48 from user inputted key value
@jm_key0                    // Loads jm_key0 into A regsiter
D;JEQ                       // Jumps to jm_key0 if D == 0

// === Check for '1' (49) ===
@jm_keyTemp                 // Reloads temp. variable location into A register
D=M                         // Reloads the ASCII value of the key pressed into RAM [A]
@49                         // Loads 49 into A register
D=D-A                       // Subtracts 49 from user inputted key value
@jm_key1                    // Loads jm_key1 into A regsiter
D;JEQ                       // Jumps to jm_key1 if D == 0

// === Check for 'backspace' (129) ===
@jm_keyTemp                 // Reloads temp. variable location into A register
D=M                         // Reloads the ASCII value of the key pressed into RAM [A]
@129                        // Loads 129 into A register
D=D-A                       // Subtracts 129 from user inputted key value
@jm_validKey                // Loads jm_validKey into A regsiter
D;JEQ                       // Jumps to jm_validKey if D == 0

// === Check for 'enter' (128) ===
@jm_keyTemp                 // Reloads temp. variable location into A register
D=M                         // Reloads the ASCII value of the key pressed into RAM [A]
@128                        // Loads 128 into A register
D=D-A                       // Subtracts 128 from user inputted key value
@jm_validKey                // Loads jm_validKey into A regsiter
D;JEQ                       // Jumps to jm_validKey if D == 0

// === Check for 'c' (67) ===
@jm_keyTemp                 // Reloads temp. variable location into A register
D=M                         // Reloads the ASCII value of the key pressed into RAM [A]
@67                         // Loads 67 into A register
D=D-A                       // Subtracts 67 from user inputted key value
@jm_validKey                // Loads jm_validKey into A regsiter
D;JEQ                       // Jumps to jm_validKey if D == 0

// === Check for 'q' (81) ===
@jm_keyTemp                 // Reloads temp. variable location into A register
D=M                         // Reloads the ASCII value of the key pressed into RAM [A]
@81                        // Loads 81 into A register
D=D-A                       // Subtracts 81 from user inputted key value
@jm_validKey                // Loads jm_validKey into A regsiter
D;JEQ                       // Jumps to jm_validKey if D == 0

// === Invalid Key Inputted ===
@jm_getKey                  // Loads jm_getKey into A register
D=A                         // Loads jm_getKey address into D register
@jm_keyDebounce_return      // Loads jm_keyDebounce_return into A register
M=D                         // Stores jm_getKey location into jm_keyDebounce_return RAM location
@jm_keyDebounce             // Waits here until key is released
0;JMP 

// === Conversion Handlers ===
(jm_key0)                   // Converts ASCII '0' (48) to literal '0'
@jm_keyTemp                 // Loads temp. variable location into A register
M=0                         // Overrides literal 0 value into jm_keyTemp RAM location
@jm_validKey                // Loads jm_validKey into A regsiter
0;JMP

(jm_key1)                   // Converts ASCII '1' (49) to literal '1'
@jm_keyTemp                 // Loads temp. variable location into A register
M=1                         // Overrides literal 1 value into jm_keyTemp RAM location
@jm_validKey                // Loads jm_validKey into A regsiter
0;JMP

// === Valid Key Inputted ===
(jm_validKey)               // Proceeds to debounce the valid key inputted
@jm_getKey_afterDebounce    // Loads jm_getKey_afterDebounce into A register
D=A                         // Loads jm_getKey_afterDebounce address into D register
@jm_keyDebounce_return      // Loads jm_keyDebounce_return into A register
M=D                         // Stores jm_getKey_afterDebounce location into jm_keyDebounce_return's memory
@jm_keyDebounce             // Jumps to jm_keyDebounce and waits here until key is released
0;JMP

// === After Debounce ===
(jm_getKey_afterDebounce)   // After debounce, return the key value
@jm_keyTemp                 // Loads temp. variable location into A register
D=M                         // Loads the final key value into D register
@jm_getKey_return           // Returns to caller-specified return address
A=M
0;JMP





//************************* "jm_keyDebounce" *************************************
// Description: Secondary loop that prevents input from being repeated from a held/multiple keyboard inputs
// Input: User keyboard input
// Output: Original KBD value from jm_getKey
// === Loop debounce until key is released ===
(jm_keyDebounce)
@KBD                         // Stores keyboard input into A register
D=M                          // Load RAM [A] ASCII value into D 
@jm_keyDebounce              // Loads jm_keyDebounce into A register
D;JGT                        // Loop back to (jm_keyDebounce) if a value is still detected in D (D != '0' / NULL)
                             // AKA key has not been released yet

// === Key Released, return to calling function ===
@jm_keyDebounce_return       // Loads jm_keyDebounce_return into A register
A=M                          // Loads the return address into A register
0;JMP                        // Jumps to memory address stored from jm_getKey_afterDebounce






//************************* "gc_OUTPUT_DECIMAL" *************************************
// DESCRIPTION: takes an entire decimal value and prints it to the screen along with ->
// INPUT: decimal value should be placed in gc_dec_digit
// OUTPUT: entire decimal value is printed to the screen along with ->
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





//************************* "gc_OUTPUT_09" *****************************************
// DESCRIPTION: Takes a single decimal value 0-9 and prints it to the screen. If the given value is not 0-9, then function is aborted
// INPUT:       gc_currKey = holds decimal value 0-9
// OUTPUT:      A decimal value 0-9 is printed to the display
(gc_OUTPUT_09)         
@gc_currKey                 
D=M                     // D = currKey
// Switch statement to find what digit 0-9 currKey is
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
A=M                     // so abort function
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





//************************* "FUNCTION: gc_0BIT_CHECK" *****************************************
// DESCRIPTION: Checks if gc_bitsEntered is 0 or not and jumps to the appropriate return address based on the result
// INPUT:       gc_bitsEntered = number of bits currently entered

// OUTPUT:      Jumps to the address stored in gc_0BIT_CHECK_TRUE_RETURN if gc_bitsEntered = 0,
//              or jumps to the address stored in gc_0BIT_CHECK_FALSE_RETURN if gc_bitsEntered != 0
(gc_0BIT_CHECK)
@gc_bitsEntered     
D=M
@gc_0BITS_ENTERED
D;JEQ                               // if bits entered = 0, then jump and deal with it

@gc_0BIT_CHECK_FALSE_RETURN         // otherwise bits entered != 0, so jump back to address 
A=M                                 // located in gc_0BIT_CHECK_FALSE_RETURN
0;JMP

(gc_0BITS_ENTERED)                  // bits entered = 0, so jump back to address
@gc_0BIT_CHECK_TRUE_RETURN          // located in gc_0BIT_CHECK_TRUE_RETURN
A=M 
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