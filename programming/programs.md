## Important note

Within this folder, anything that is a ```.txt``` file is binary that will be used to initialize contents of RAM on the FPGA (contains both instructions and data).
Anything that is a ```.asm``` file is assembly code that outlines programming logic and the data that the program will work on. This can be assembled into a ```.txt``` binary file by opening a python terminal in this directory and typing this command:
```assembler.py test.asm test.txt``` where the .asm file is input and the .txt file is generated as output.

### multiply_program.txt
Multiplies the values in memory address 0xFE (line 255) and memory address 0xFF (line 256) and stores the result in memory address 0xFD (line 254).
Only the first 256 of the 4096 memory cells are used.

### print_digits.txt
Multiplies the values in memory address 0xFE (line 255) and memory address 0xFF (line 256) and stores the result in memory address 0xFD (line 254).
Only the first 256 of the 4096 memory cells are used.

### uart_receive.txt
Receives 2 bytes from serial UART connection rx line to RAM, then loads those 2 bytes from RAM to GPR[1] where the 7 least significant bits are displayed on the 7-segment display. Can be repeated with reset button.

### uart_send.txt
Sends 2 bytes from RAM[3] to the serial UART connection tx line. Can be repeated with reset button.

### uart_send_multiple.txt
Sends 64 bytes total (32 addresses) to the serial UART connection tx line. Can be repeated with reset button.

### send_receive_test.txt
While the letter "A" is displayed on 7-segment display, is waiting to receive the characters "ab" over UART. Once this occurs, it will send the alphabet over UART, then go back to the start (waiting to receive "ab" over UART while displaying "A").
When creating this program, I discovered that loading from and storing to a memory address that holds an instruction rather than data is possible, but the instruction has to be within 256 addresses in front of the load/store instruction 
