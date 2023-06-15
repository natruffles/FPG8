This sample code will multiply the values stored in address 0xFF (255) and 0xFE (254) in RAM and store the result back in 0xFD (253).

LD 1 255 (PC = 0)
GPR[1] = MM[0 + 255]
GPR 1 will store 0xFF from RAM

LD 2 253 (PC = 1)
GPR[2] = MM[1 + 253]
GPR 2 will store 0xFE from RAM

LDI 4 1 (PC = 2)
GPR[4] = 1
GPR 4 will store the value 1 (for decrementing)

ADD 3 3 2 (IR.shift must equal 0!)
GPR[3] = GPR[3] + GPR[2]
Add MM[0xFE] to result

SUB 1 1 4
GPR[1] = GPR[1] - GPR[4]
Decrement MM[0xFF] by 1

FIXME: check if GPR[1] equal to 0, if so, load result to RAM. Else, jump back to "ADD 3 3 2"

https://stackoverflow.com/questions/58400869/i-want-to-perform-a-multiplication-with-add-in-assembler-that-uses-a-loop

int GPR1 = MM[0xFF];
int GPR2 = MM[0xFE];
int GPR3 = 0;
int GPR4 = 1;

while (GPR1 > 0) {
   acc += m2;
   GPR3 = GPR3 + GPR2;
   GPR1 = GPR1 - GPR4;
}

MM[0xFD] = GPR3;