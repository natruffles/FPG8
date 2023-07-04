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
