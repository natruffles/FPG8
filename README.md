# FPG8
Verilog implementation of a computer architecture project (single-bus processor) on an iCEstick FPGA

## Initial Writeup
In our [computer architecture class](https://eecs.ceas.uc.edu/~wilseypa/classes/eece3026/), we were tasked with a [project](https://eecs.ceas.uc.edu/~wilseypa/classes/eece3026/project/project3.pdf) which involved developing a gate-level design of a single-bus control unit that implements 16 different instructions in a simple processor. The processor in the project was required to have a 16-bit word size and a 16-bit single data bus with byte addressable memory. However, our FPGA, an [iCEstick Evaluation Kit](https://www.latticesemi.com/icestick), only has 12 I/O ports so we will need to input/output data over the process of multiple clock cycles.

My [project writeup](https://docs.google.com/presentation/d/1Ky87abrqP6Sl-3wUcDA0iaXHDzWbXQxgTyut-tx8uL8/edit?usp=sharing) will be a good starting resource in transferring my gate-level design to an FPGA, as well as my Logisim implementation, which I will upload to this repo shortly. 

I also plan to use [Shawn Hymel's FPGA tutorial](https://www.digikey.com/en/maker/projects/introduction-to-fpga-part-1-what-is-an-fpga/3ee5f6c8fa594161a655a9f960060893) as well as [Phil Does Tech's CPU on an FPGA series](https://www.youtube.com/watch?v=sa1id9DIick) for insipiration. 

## Update 6/18/2023
The processor design is mostly complete except for bug fixes, so I need to create a program that my processor can execute. Since I am not yet at the stage to program an encoder, I will create a sequence of assembly instructions and encode them myself into binary.

My first program will perform binary multiplication without having a dedicated multiplication instruction in my instruction set. This program will use 7 of the 16 instructions in my instruction set, but more importantly, will allow me to verify that my control unit finite state machine works as intented when connected to the rest of the processor. The below sample code will multiply the values stored in address 0xFF (255) and 0xFE (254) in RAM and store the result back in 0xFD (253).

```
0  LD 1 255
1  ADD 0 0 1
2  BRZ 7
3  LD 2 251
4  LDI 4 1
5  BRZ 4
6  ADD 3 3 2
7  SUB 1 1 4
8  RTS 0 5
9  ST 3
10 RTS 0 0
```

Here is what I am trying to accomplish (multiplication in the form of repeated addition) in a C-like syntax:
```
int GPR1 = MM[0xFF];
int GPR2 = MM[0xFE];
int GPR3 = 0;
int GPR4 = 1;

while (GPR1 > 0) {
   GPR3 = GPR3 + GPR2;
   GPR1 = GPR1 - GPR4;
}

MM[0xFD] = GPR3;
```

Here is a more detailed description of what the control unit is supposed to do when reading each assembly instruction:
```
LD 1 255 (PC = 0)
GPR[1] = MM[0 + 255]
GPR 1 will store 0xFF from RAM

ADD 0 0 1 (PC = 1)
GPR[0] = GPR[0] + GPR[1]
Adds 0xFF with zero, concerned if result = 0 (see next instruction)

BRZ 7 (PC = 2)
If CC.Z then PC = PC + 7 = 9
If 0xFF from RAM = 0, then go directly to store instruction (result = 0)

LD 2 251 (PC = 3)
GPR[2] = MM[3 + 251]
GPR 2 will store 0xFE from RAM

LDI 4 1 (PC = 4)
GPR[4] = 1
GPR 4 will store the value 1 (for decrementing)

BRZ 4 (PC = 5)
If CC.Z then PC = PC + 4 = 9

ADD 3 3 2 (IR.shift must equal 0!) (PC = 6)
GPR[3] = GPR[3] + GPR[2]
Add MM[0xFE] to result

SUB 1 1 4 (PC = 7)
GPR[1] = GPR[1] - GPR[4]
Decrement MM[0xFF] by 1

//RTS 0 5 (PC = 8)
//PC = GPR[0] + 5 = 5
//Go to the BRZ instruction

BR 65533 (PC = 8)
PC = PC + 65533 = 8 + 65533 = 65541 % 4096 = 5
Go to the BRZ instruction, 4096 RAM addresses cause MAR = RAM % 4096

ST 3 244 (PC = 9)
MM[9 + 244] = MM[253] = GPR[3]

ADD 0 0 0 (PC = 10)
GPR[0] = GPR[0] + GPR[0]
Represents null instruction, terminates program execution
```
The instructions above and the data that the instructions work with has to fit onto RAM that consists of 512 bytes, or 256 words of 16 bits each. The instructions fill up addresses 0-10 inclusive, while the R/W data fills up addresses 253-255, inclusive.
```
0 0111 001 011111111
1 0000 1 00 000 000 001
2 1010 000 000000111
3 0111 010 011111011
4 0110 100 000000001
5 1010 000 000000100
6 0000 0 00 011 011 010
7 0001 1 00 001 001 100
8 1011 000 111111101
9 1000 011 011110100
10 0000 0 00 000 000 000
...
253 (should write) 0111000100110100
254 0000000110100100
255 0000000001000101
```
In the next update, I will demonstrate my working simulation of my control unit performing binary multiplication.

### Evaluating performance of processor in simple terms
Listed below are the 16 possible instructions and how many clock cycles each takes to execute (assuming no traps / program check violations):
|Instruction |Opcode| Description | Clock Cycles to complete |
|-----|--------|-----------------|------|
|ADD|0000 (0)    |GPR[Rd] = GPR[Rs1] + left_shifted(GPR[Rs2], IR.Shift)|6
|SUB  |0001 (1)  |GPR[Rd] = GPR[Rs1] - left_shifted(GPR[Rs2], IR.Shift)|6
|AND  |0010 (2)  |GPR[Rd] = GPR[Rs1] and left_shifted(GPR[Rs2], IR.Shift)|6
|OR  |0011 (3)   |GPR[Rd] = GPR[Rs1] or left_shifted(GPR[Rs2], IR.Shift)|6
|NOT  |0100 (4)  |GPR[Rd] = not GPR[Rs1]|5
|SHFT  |0101 (5) | if IR.Rs2 == 0 then GPR[Rd] = shift_left(GPR[Rs1], IR.Shift) else GPR[Rd] = shift_right(GPR[Rs1], IR.Shift)|5
|LDI  |0110 (6)  |GPR[Rd] = IR.Offset|4
|LD  |0111 (7)   |GPR[Rd] == MM[PC + IR.Offset]|5
|ST  |1000 (8)   |MM[PC + IR.Offset] = GPR[RD]|5
|BRN  |1001 (9)  |If CC.N then PC = PC + IR.Offset|4
|BRZ  |1010 (10) |If CC.Z then PC = PC + IR.Offset|4
|BR  |1011 (11)  |PC = PC + IR.Offset|4
|JSR  |1100 (12) |GPR[Rd] = PC; PC = PC + IR.Offset|6
|RTS  |1101 (13) |PC = GPR[Rd] + IR.Offset|5
|CLK  |1110 (14) |Timer = MM[PC + IR.Offset]|5
|LPSW  |1111 (15)|PSW = MM[PC + IR.Offset]|5
|NULL|0000 (0)    |GPR[0] = GPR[0] + left_shifted(GPR[0], 0)|3

All instructions execute within 4-6 clock cycles (besides NULL instructions which terminate program directly after fetch states), with 3 of those cycles always taken up by fetching the instruction from memory. The average clock cycle time for all 16 instructions is 5.0625 although this value does not take into account average instruction execution frequency. That will only be known once more extensive programs have been developed with this ISA to execute on this processor.

If a timeout trap is thrown after an instruction is executed, an additional 8 clock cycles are added to that instruction's execution time. 

If a program check violation occurs when attempting to execute CLK or LPSW while not in privileged mode, those instructions will take 11 total clock cycles to execute (including handling of the PCV).

When executing the above sample program, assuming two nonzero numbers are multiplied, the first six instructions are always executed and take a total of 28 clock cycles. Then, the next four instructions (PC 6,7,8,5) are executed x times, where x = GPR[1](initial); the four instructions take 21 clock cycles. In order to decrease the average program execution time dramatically, the value stored in 0xFF in RAM should be smaller in magnitude than the value stored in 0xFE. Then, the last two instructions are executed and take a total of 8 clock cycles. 

The execution time for the program is 28 + 8 + 21*x = **36 + 21 * 0xFE** clock cycles.

## Update 7/1/2023

Many changes needed to be made to load the soft-core processor from simulation onto the FPGA hardware. I encountered many Yosys (synthesizer) errors that were not caught during simulation. After hours of looking through obscure questions on StackOverflow as well as consulting the Yosys manual, I was able to load the processor onto the FPGA, controlled by a physical reset and clock button. To confirm more functions of the processor rather than "it works", I would like to establish UART communication with the connected PC in the future.

To verify that my program runs as intended on the FPGA, I created the following test setup:
1. Set my program clock variable MODULO = 20000, which means that each clock cycle takes (20000 * 2) / 12,000,000 = 0.00333 seconds
2. Calculated using the formula above for execution time that my program should take 36 + 21 * 69 = 1485 clock cycles to complete
3. Calculated that my program should take 0.00333 seconds * 1485 clock cycles ~ 4.95 seconds to execute on the hardware.
4. Uploaded my program to the FPGA, while holding the reset button
5. Timed how long it took from releasing the reset button to the program counter LEDs to stop quickly flashing (meaning program has reached end and processor has reached idle state)

I timed 4.78 seconds, which is very close to the theoretical time of 4.95 seconds. Awesome!

