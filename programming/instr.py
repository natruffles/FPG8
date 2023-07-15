import sys
import re
from data import data_objects
from floc import fl_objects

def instr_decode(instr_string):
    instr_format = ""
    if instr_string.endswith(":"):
        instr_format = "FL"
    elif instr_string.startswith("add ") or \
        instr_string.startswith("adds ") or \
        instr_string.startswith("sub ") or \
        instr_string.startswith("subs ") or \
        instr_string.startswith("and ") or \
        instr_string.startswith("ands ") or \
        instr_string.startswith("or ") or \
        instr_string.startswith("ors ") or \
        instr_string.startswith("not ") or \
        instr_string.startswith("nots ") or \
        instr_string.startswith("shft ") or \
        instr_string.startswith("shfts ") or \
        instr_string.startswith("cmp ") or \
        instr_string == "nop" or \
        instr_string == "end":
        instr_format = "F2"
    elif instr_string.startswith("ldi ") or \
        instr_string.startswith("ld ") or \
        instr_string.startswith("st ") or \
        instr_string.startswith("jsr ") or \
        instr_string.startswith("rts ") or \
        instr_string.startswith("disp "):
        instr_format = "F1"
    elif instr_string.startswith("rx ") or \
        instr_string.startswith("brn ") or \
        instr_string.startswith("brz ") or \
        instr_string.startswith("br ") or \
        instr_string.startswith("tx "):
        instr_format = "F3"
    else:
        sys.exit("\"" + instr_string + "\" doesn't have a valid opcode / function location!")
    return instr_format

# assembly instruction format 1 (opcode, rd, offset)
class AsmInstF1:
    def __init__(self, instr_string, pc):
        self.pc = pc
        original_instr = instr_string
        print("Parsing \"" + original_instr + "\" into its components...")

        # handle macros
        pattern = r"disp ."
        if re.match(pattern, instr_string):
            self.opcode = 6    # ldi instruction
            self.rd = 1   # register 1 is 7-seg display register
            disp_char = instr_string[5]
            if disp_char == '0':
                self.offset = int('001110111', 2)
            elif disp_char == '1':
                self.offset = int('000010001', 2)
            elif disp_char == '2':
                self.offset = int('000111110', 2)
            elif disp_char == '3':
                self.offset = int('000111011', 2)
            elif disp_char == '4':
                self.offset = int('001011001', 2)
            elif disp_char == '5':
                self.offset = int('001101011', 2)
            elif disp_char == '6':
                self.offset = int('001101111', 2)
            elif disp_char == '7':
                self.offset = int('000110001', 2)
            elif disp_char == '8':
                self.offset = int('001111111', 2)
            elif disp_char == '9':
                self.offset = int('001111011', 2)
            elif disp_char.lower() == 'a':
                self.offset = int('001111101', 2)
            elif disp_char.lower() == 'b':
                self.offset = int('001001111', 2)
            elif disp_char.lower() == 'c':
                self.offset = int('001100110', 2)
            elif disp_char.lower() == 'd':
                self.offset = int('000011111', 2)
            elif disp_char.lower() == 'e':
                self.offset = int('001101110', 2)
            elif disp_char.lower() == 'f':
                self.offset = int('001101100', 2)
            elif disp_char.lower() == 'g':
                self.offset = int('001100111', 2)
            elif disp_char.lower() == 'h':
                self.offset = int('001001101', 2)
            elif disp_char.lower() == 'i':
                self.offset = int('001000100', 2)
            elif disp_char.lower() == 'j':
                self.offset = int('000010011', 2)
            else:
                sys.exit("\"" + original_instr + "\" is not a valid character to display! 0-9 or a-j only!")

        # now that macros are handled, parse the rest of the instructions
        else:
            # parse the opcode and remove that part of the instruction string
            if instr_string.startswith("ldi"):
                self.opcode = 6
                instr_string = instr_string[len("ldi"):].lstrip()
            elif instr_string.startswith("ld"):
                self.opcode = 7
                instr_string = instr_string[len("ld"):].lstrip()
            elif instr_string.startswith("st"):
                self.opcode = 8
                instr_string = instr_string[len("st"):].lstrip()
            elif instr_string.startswith("jsr"):
                self.opcode = 12
                instr_string = instr_string[len("jsr"):].lstrip()
            elif instr_string.startswith("rts"):
                self.opcode = 13
                instr_string = instr_string[len("rts"):].lstrip()
            else:
                sys.exit("Unable to parse opcode identifier of \"" + original_instr + "\"!")

            # parse the Rd argument
            pattern = r"\$\d, .*"
            if re.match(pattern, instr_string):
                self.rd = int(instr_string[1])
                if self.rd == 8 or self.rd == 9:
                    sys.exit("\"" + original_instr + "\": registers must be between 0-7, inclusive!")
                instr_string = instr_string[4:]
            else:
                sys.exit("Unable to parse content following opcode identifier of \"" + original_instr + "\"!")

            # at this point, only the final argument should be left
            # if the final argument is a positive or negative number
            if instr_string[0] == '-' or instr_string.isdigit():
                self.offset = int(instr_string)
            elif instr_string[0:2] == "0x":
                self.offset = int(instr_string[2:], 16)
            else:
                found_flag = 0
                for data in data_objects:
                    if instr_string == data.var_name:
                        if data.data_type == "offset":
                            self.offset = data.value     # reminder that the actual address will be PC + offset
                            found_flag = 1
                        elif data.data_type == "word":
                            self.offset = data.data_address - self.pc  # such that PC + offset will reach the data address
                            found_flag = 1
                        else:
                            sys.exit("\"" + original_instr + "\": Cannot reference an offset long datatype!")
                        break
                if found_flag == 0:
                    sys.exit("\"" + original_instr + "\": Unable to parse final offset argument!")

            if self.offset < -256 or self.offset > 511:
                sys.exit("\"" + original_instr + "\": Offset argument overflow! Must be -256 <= x <= 511!")
            
            print(self)

    def __str__(self):
        return f"Opcode: {self.opcode}, Rd: {self.rd}, Offset: {self.offset}, pc: {self.pc}"
    

# assembly instruction format 2 (opcode, s, shift, rd, rs1, rs2)
class AsmInstF2:
    def __init__(self, instr_string, pc):
        self.pc = pc
        original_instr = instr_string
        print("Parsing \"" + original_instr + "\" into its components...")
        
        # handle macros
        if instr_string.startswith("cmp"):
            rd_string = instr_string[4:]
            instr_string = "subs $0, " + rd_string + ", $0"
        elif instr_string == "nop":
            instr_string = "sub $0, $0, $0"
        elif instr_string == "end":
            instr_string = "add $0, $0, $0"
        
        # handle parsing the opcode
        if instr_string.startswith("add"):
            self.opcode = 0
            instr_string = instr_string[len("add"):].lstrip()
        elif instr_string.startswith("sub"):
            self.opcode = 1
            instr_string = instr_string[len("sub"):].lstrip()
        elif instr_string.startswith("and"):
            self.opcode = 2
            instr_string = instr_string[len("and"):].lstrip()
        elif instr_string.startswith("or"):
            self.opcode = 3
            instr_string = instr_string[len("or"):].lstrip()
        elif instr_string.startswith("not"):
            self.opcode = 4
            instr_string = instr_string[len("not"):].lstrip()
        elif instr_string.startswith("shft"):
            self.opcode = 5
            instr_string = instr_string[len("shft"):].lstrip()
        else:
            sys.exit("Unable to parse opcode identifier of \"" + original_instr + "\"!")

        # handle parsing the optional s bit
        if instr_string[0] == 's':
            self.s = 1
            instr_string = instr_string[2:]
        else:
            self.s = 0

        # instr_string looks like: "$5, $3, $1, 3"
        pattern = r"\$\d, \$\d, \$\d.*"
        if re.match(pattern, instr_string):
            self.rd = int(instr_string[1])
            self.rs1 = int(instr_string[5])
            self.rs2 = int(instr_string[9])
            if self.rd == 8 or self.rs1 == 8 or self.rs2 == 8 or \
                self.rd == 9 or self.rs1 == 9 or self.rs2 == 9:
                sys.exit("\"" + original_instr + "\": registers must be between 0-7, inclusive!")
            instr_string = instr_string[10:]
        else:
            sys.exit("\"" + instr_string + "\" does not fit string formatting! Should start with \"$x, $x, $x\" where x is a decimal number!")

        # instr_string should either be blank or ", x" where x is an integer 0-3
        pattern = r"^, \d"
        if re.match(pattern, instr_string):
            self.shift = int(instr_string[2])
            if self.shift < 0 or self.shift > 3:
                sys.exit("Shift amount of \"" + original_instr + "\" must be between 0 and 3 inclusive!")
        elif len(instr_string) == 0:
            self.shift = 0
        else:
            sys.exit("Unable to parse shift syntax of \"" + original_instr + "\"!")
        
        print(self)

    
    def __str__(self):
        return f"Opcode: {self.opcode}, S: {self.s}, Shift: {self.shift}, Rd: {self.rd}, Rs1: {self.rs1}, Rs2: {self.rs2}, pc: {self.pc}"


# assembly instruction format 3 (opcode, offset_long)
class AsmInstF3:
    def __init__(self, instr_string, pc):
        self.pc = pc
        original_instr = instr_string
        print("Parsing \"" + original_instr + "\" into its components...")

        # parse the opcode
        if instr_string.startswith("rx"):
            self.opcode = 14
            instr_string = instr_string[len("rx") + 1:].lstrip()
        elif instr_string.startswith("tx"):
            self.opcode = 15
            instr_string = instr_string[len("tx") + 1:].lstrip()
        elif instr_string.startswith("brn"):
            self.opcode = 9
            instr_string = instr_string[len("brn") + 1:].lstrip()
        elif instr_string.startswith("brz"):
            self.opcode = 10
            instr_string = instr_string[len("brz") + 1:].lstrip()
        elif instr_string.startswith("br"):
            self.opcode = 11
            instr_string = instr_string[len("br") + 1:].lstrip()

        # the rest of the argument should just be the long offset
        if instr_string.isdigit():
            self.offset_long = int(instr_string)
        elif instr_string[0:2] == "0x":
            self.offset_long = int(instr_string[2:], 16)
        else:
            found_flag = 0
            for data in data_objects:
                if instr_string == data.var_name:
                    if data.data_type == "offset_long":
                        self.offset_long = data.value     # reminder that the actual address will be PC + offset
                        found_flag = 1
                    else:
                        sys.exit("\"" + original_instr + "\": Cannot reference an offset or word datatype!")
                    break
            if found_flag == 0:
                for fl in fl_objects:
                    if instr_string == fl.name:
                        self.offset_long = fl.pc     # reminder that the actual address will be PC + offset
                        found_flag = 1
                        break
            if found_flag == 0:
                sys.exit("\"" + original_instr + "\": Unable to parse final offset_long argument!")

        if self.offset_long < 0 or self.offset_long > 4095:
            sys.exit("\"" + original_instr + "\": Offset_long argument overflow! Must be 0 <= x <= 4095!")

        print(self)

    def __str__(self):
        return f"Opcode: {self.opcode}, Offset_long: {self.offset_long}, pc: {self.pc}"