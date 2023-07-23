.text
main:
   # GPR[1] will store 0xFF from RAM
   ld $1, operand_1

   # check if GPR[1] is equal to zero
   cmp $1

   # If 0xFF from RAM == 0, then immediately store result
   brz store_result

   # GPR[2] will store 0xFE from RAM
   ld $2, operand_2

   # GPR[4] will store the value 1 (for decrementing)
   # note how I did not use anything from data, I simply hard_coded the value which is allowed
   ldi $4, 1

15 loop:
   # i f decrementer reaches 0, multiplication is complete and result can be stored
   brz store_result

   # add to the running total in GPR[3]
   add $3, $3, $2

   # decrement GPR[1] by 1 and set condition codes (checking if zero)
   subs $1, $1, $4

   # go back to the start of loop
   br loop

store_result:
   # stores the running total (GPR[3]) back at intended location in RAM
   st $3, op_result

   # program is complete
   end


.data
operand_1: .offset 0x25
operand_2: .offset b10110010
op_result: .offset 253
testing: .word -3452 0xFF
testing1: .offset_long 567
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"
testingagain: .word "dq"