.text
main:
   # load UART_input_comparison into GPR[3]
   ld $3, UART_input_comparison

parse_input:
   # display the letter A
   disp A

   # wait for a UART input and store in UART_input address when received
   rx UART_input

   # load UART_input into GPR[2]
   ld $2, UART_input

   # Compare the above two values to see if they are equal, store result in garbage register
   subs $0, $2, $3

   # i f values are the same, branch to the uart_display subroutine
   brz uart_display

   # i f the values are not the same (prior brz not met), branch back parse_input
   br parse_input


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
   brz parse_input

   # e lse, go back to start of loop
   br display_loop



.data
# zero value stored at address 7, will be received from UART
UART_input: .word 0 7

# value that UART will be compared against
# is equivalent to ascii code of "w"
UART_input_comparison: .word 119 8

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
UART_DB_0: .word "ab"
UART_DB_1: .word "cd"
UART_DB_2: .word "ef"
UART_DB_3: .word "gh"
UART_DB_4: .word "ij"
UART_DB_5: .word "kl"
UART_DB_6: .word "mn"
UART_DB_7: .word "op"
UART_DB_8: .word "qr"
UART_DB_9: .word "st"
UART_DB_10: .word "uv"
UART_DB_11: .word "wx"
UART_DB_12: .word "yz"
UART_DB_13: .word 0
UART_DB_14: .word 0
UART_DB_15: .word 0
UART_DB_16: .word 0
UART_DB_17: .word 0
UART_DB_18: .word 0
UART_DB_19: .word 0
UART_DB_20: .word 0
UART_DB_21: .word 0
UART_DB_22: .word 0
UART_DB_23: .word 0
UART_DB_24: .word 0
UART_DB_25: .word 0
UART_DB_26: .word 0
UART_DB_27: .word 0
UART_DB_28: .word 0
UART_DB_29: .word 0
UART_DB_30: .word 0
UART_DB_31: .word 0
