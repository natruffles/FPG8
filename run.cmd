REM \\ This script assembles the file, and uploads the resulting bitstream .txt file to the CPU, then runs a simulation \\
cd programming
assembler.py snake.asm ram_init.txt
cd ..
copy "programming\ram_init.txt" "ram_init.txt"
del "programming\ram_init.txt"
apio clean
apio upload -v
apio sim
