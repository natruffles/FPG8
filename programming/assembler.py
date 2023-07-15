# This program will take in an assembly (.asm) file and output a binary executable (.txt)

import sys  # used to pass in arguments from command line
import re  # used for string parsing
import instr
import data
import floc

try:
    print("Parsing filename arguments...")
    assembly_file = sys.argv[1]
    binary_file = sys.argv[2]
except:
    sys.exit("Unable to parse arguments! Make sure to specify assembly file name and binary file name!")

try:
    print("Parsing lines of " + assembly_file + "...")
    with open(assembly_file, 'r') as file:
        assembly_file_data = file.read()
except:
    sys.exit("Unable to parse lines of " + assembly_file + "! Make sure is located in the assembler's directory!")

try:
    print("Splitting assembly file into lines...")
    asm_lines = re.split("\n", assembly_file_data)
except:
    sys.exit("Unable to split assembly file by newline!")

try:
    print("Removing empty lines, comment lines, and extra whitespace...")
    # use list comprehension to delete all empty lines
    asm_lines = [string for string in asm_lines if string]

    # remove all leading and trailing whitespace
    asm_lines = [string.strip() for string in asm_lines]

    # delete all comment lines (start with '#')
    asm_lines = [string for string in asm_lines if not string.startswith('#')]
except:
    sys.exit("Unable to remove empty lines, comment lines, and extra whitespace!")

try:
    print("Isolating machine instructions...")
    start_index = asm_lines.index("main:")
    end_index = asm_lines.index(".data")
    instr_lines = asm_lines[start_index+1:end_index]
except:
    sys.exit("Unable to isolate machine isntructions! Please make sure \
             your file contains .text, main, and .data lines!")
    
try:
    print("Isolating data declarations...")
    start_index = asm_lines.index(".data")
    data_lines = asm_lines[start_index+1:]
except:
    sys.exit("Unable to isolate data declarations! Please make sure your assembly \
             file contains \".data\" line before data declarations at the end of file!")

# parse all of the data entries into a list of objects
word_data_address = 4000  # default start address for data if not specified for first word data declaration
for i in range(len(data_lines)):
    data.data_objects.append(None)
    data.data_objects[i] = data.DataVal(data_lines[i], word_data_address)
    if data.data_objects[i].data_type == "word" and data.data_objects[i].data_address != 0:
        word_data_address = data.data_objects[i].data_address + 1
    elif data.data_objects[i].data_type == "word":
        word_data_address = word_data_address + 1

# parse all function locations into a list of objects
fl_counter = 0
pcounter = 0
for i in range(len(instr_lines)):
    instr_type = instr.instr_decode(instr_lines[i])

    if instr_type == "FL":
        floc.fl_objects.append(None)
        floc.fl_objects[fl_counter] = floc.FuncLoc(instr_lines[i], pcounter)
        pcounter = floc.fl_objects[fl_counter].pc
        fl_counter = fl_counter + 1
    else: 
        pcounter = pcounter + 1

# parse all instructions into a list of objects
instr_objects = []
line_number = 0
instr_counter = 0
FL_counter = 0
instr_type = ""
for i in range(len(instr_lines)):
    instr_type = instr.instr_decode(instr_lines[i])

    if instr_type == "FL":
        line_number = floc.fl_objects[FL_counter].pc
        FL_counter = FL_counter + 1
    elif instr_type == "F1":
        instr_objects.append(None)
        instr_objects[instr_counter] = instr.AsmInstF1(instr_lines[i], line_number)
        instr_counter = instr_counter + 1
        line_number = line_number + 1
    elif instr_type == "F2":
        instr_objects.append(None)
        instr_objects[instr_counter] = instr.AsmInstF2(instr_lines[i], line_number)
        instr_counter = instr_counter + 1
        line_number = line_number + 1
    elif instr_type == "F3":
        instr_objects.append(None)
        instr_objects[instr_counter] = instr.AsmInstF3(instr_lines[i], line_number)
        instr_counter = instr_counter + 1
        line_number = line_number + 1

print()
for string in data.data_objects:
    print(string)
print()
for string in floc.fl_objects:
    print(string)
print()
for string in instr_objects:
    print(string)
        