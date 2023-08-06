.text
main:
   # load UART_title_comparison into GPR[3]
   ld $3, UART_title_comparison

   # load UART_start_comparison into GPR[2]
   ld $2, UART_start_comparison

parse_title_input:
   # display the letter A
   disp A

   # wait for a UART input and store in UART_input address when received
   rx UART_input

   # load UART_input into GPR[4]
   ld $4, UART_input

   # Compare UART_input and UART_title_comparison to see if they are equal, store result in garbage register
   subs $0, $4, $3

   # i f values are the same, branch to the uart_display subroutine
   brz uart_display

   # Compare UART_input and UART_start_comparison to see if they are equal, store result in garbage register
   subs $0, $4, $2

   # i f values are the same, branch to the parse_game_input subroutine
   brz parse_game_input

   # i f the values are not the same (prior brz not met), branch back parse_title_input
   br parse_title_input


100 uart_display:
   # load the value stored in UART_end_pointer into GPR[1]
   ld $1, UART_end_pointer

   # load the value "1" into GPR[4] for incrementing
   ldi $4, 1

   # load the value stored in UART_start_pointer into GPR[2]
   ld $2, UART_start_pointer

   # making sure that the first store instruction in display_loop isn't changing anything
   ld $5, instr_to_update_base

display_loop:
   # update the instruction itself (dangerous! instr_to_update floc PC must be < 256 in front)
   st $5, instr_to_update

   # load the instruction "tx UART_write_data" into GPR[5] (dangerous! instr_to_update floc PC must be < 256 in front)
   ld $5, instr_to_update

   # increment GPR[5] by 1 such that the instruction will now be "tx UART_write_data + 1"
   add $5, $5, $4

instr_to_update:
   # write the address specified by UART_write_data over tx channel
   tx UART_DB_0

   # write nothing, as display needs to alternate between 2 data bytes and 2 junk bytes
   tx nothin

   # increment GPR[2] (address of what we want to write to UART next) by 1
   add $2, $2, $4

   # compare UART current write address and UART_end_pointer to see if they are equal
   subs $0, $1, $2

   # i f loop has gone 32 times, all addresses sent over UART, go back to parsing input
   brz parse_title_input

   # e lse, go back to start of loop
   br display_loop


400 parse_game_input:
   # load W, A, S, and D into GPR[1], 2, 3, and 4 respectively
   ldi $1, 119
   ldi $2, 97
   ldi $3, 115
   ldi $4, 100

   # wait for a UART input and store in UART_input address when received
   rx UART_game_input

   # load UART_game_input into GPR[5]
   ld $5, UART_game_input

   # Compare UART_game_input and "w" to see if they are equal, store result in garbage register
   subs $0, $5, $1

   # i f values are the same, branch to the move_up subroutine
   brz move_up

   # Compare UART_game_input and "a" to see if they are equal, store result in garbage register
   subs $0, $5, $2

   # i f values are the same, branch to the move_left subroutine
   brz move_left

   # Compare UART_game_input and "s" to see if they are equal, store result in garbage register
   subs $0, $5, $3

   # i f values are the same, branch to the move_down subroutine
   brz move_down

   # Compare UART_game_input and "d" to see if they are equal, store result in garbage register
   subs $0, $5, $4

   # i f values are the same, branch to the move_right subroutine
   brz move_right

   # i f no keyboard input, go to no_move
   br no_move


# for these next 4 subroutines, GPR[5] will store x-axis offset (-1, 0, or 1) and 
# GPR[6] will store y-axis offset (-1, 0, or 1)
move_left:
   ldi $6, 0
   ldi $5, -1
   br calc_new_position

move_right:
   ldi $6, 0
   ldi $5, 1
   br calc_new_position

move_down:
   ldi $5, 0
   ldi $6, 1
   br calc_new_position

move_up:
   ldi $5, 0
   ldi $6, -1
   br calc_new_position

no_move:
   ldi $5, 0
   ldi $6, 0
   br calc_new_position

calc_new_position:
   # load the stored x and y positions from RAM into GPR[1] and GPR[2] respectively
   ld $1, x_head_position
   ld $2, y_head_position

   # add x and y offset to x and y head positions
   add $1, $1, $5
   add $2, $2, $6

   # store the new x and y head positions back to memory
   st $1, x_head_position
   st $2, y_head_position

# after calculating new position, need to convert that into which display_buffer needs to be modified
# basically, where in the display buffer will one bit (the snake head) have to be turned on
# display buffer number is == y*2 + x/16 (truncated)
calc_display_buffer_location:
   # shift x_head_position (GPR1) to the right (GPR7!=0) by 1 and store in GPR4
   shft $4, $1, $7, 1

   # shift GPR4 to the right by 3 and store back in GPR4
   # after these two shifts, GPR4 will now hold x/16 (truncated)
   shft $4, $4, $7, 3

   # add x/16 (GPR4) and y*2 (GPR2 bitshifted to the left by 1) to get the display buffer number
   # GPR5 == x/16 + y*2
   add $5, $4, $2, 1

# next, need to calculate which bit in that 16-bit display buffer needs to be turned on 
# 1. set the 5th-15th bits of x-coord all equal to 0 (so we get a value 0-15 instead of 0-31)
# 3. perform exponentiation: x -> 2^x
#    this will set, if value is 0, value will be 0....01, if value is 1 will be 0...10,
#    if value is 2 will be 0...0100, and so on. setting xth bit equal to 1
# 3. flip the bit orientation. because if x = 0 we need it to be 10...0, not 0...01




.data
# zero value stored at address 10, will be received from UART
UART_input: .word 0 10
# value that UART will be compared against to display title
# is equivalent to ascii code of "w"
UART_title_comparison: .word 119 
# value that UART will be compared against to start game
# is equivalent to ascii code of "s"
UART_start_comparison: .word 115

# stores the inital value of instr_to_update (tx UART_DB_0)
instr_to_update_base: .word b1111000010010110 146
# always stores 0, located at address 146
nothin: .word 0 
# pointer to start address in the display buffer below
# initialized to value 150 (start address of disp buffer), at address 147
UART_start_pointer: .word 150 
# pointer to 1 past the end address in the display buffer below
# initialized to value 182 (1 past the last address of disp buffer), at address 148
UART_end_pointer: .word 182 
# UART display buffer, 32 values always sent over uart in a row, addresses 150-181 inclusive
# make sure the start address is ALWAYS < 256
UART_DB_0: .word b0000000000000000
UART_DB_1: .word b0000000000000000
UART_DB_2: .word b0011101000010001
UART_DB_3: .word b0001001011110110
UART_DB_4: .word b0100001100010001
UART_DB_5: .word b0001001010000110
UART_DB_6: .word b0100001100010001
UART_DB_7: .word b0001001010000110
UART_DB_8: .word b0100001100010010
UART_DB_9: .word b1001010010000110
UART_DB_10: .word b0100001010010010
UART_DB_11: .word b1001010010000110
UART_DB_12: .word b0100001010010010
UART_DB_13: .word b1001100010000110
UART_DB_14: .word b0011001010010010
UART_DB_15: .word b1001100010000110
UART_DB_16: .word b0000101001010010
UART_DB_17: .word b1001100011100110
UART_DB_18: .word b0000101001010100
UART_DB_19: .word b0101010010000110
UART_DB_20: .word b0000101001010100
UART_DB_21: .word b0101010010000110
UART_DB_22: .word b0000101000110111
UART_DB_23: .word b1101001010000000
UART_DB_24: .word b0000101000110100
UART_DB_25: .word b0101001010000000
UART_DB_26: .word b0100101000110100
UART_DB_27: .word b0101001010000110
UART_DB_28: .word b0011001000010100
UART_DB_29: .word b0101001011110110
UART_DB_30: .word b0000000000000000
UART_DB_31: .word b0000000000000000

# address to hold input from keyboard during game logic,
# at address 500 (100 in front of parse_game_input routine)
uart_game_input: .word 0 500
# holds the x and y positions of the snake's head, initial values in the middle of the screen
x_head_position: .word 16
y_head_position: .word 8

#######################################################################
# offset values do not have an address
