import sys

fl_objects = []

# function location (not an instruction, things like "75 loop:" and "function:")
class FuncLoc:
    def __init__(self, instr_string, pc):
        print("Parsing \"" + instr_string + "\" into its components...")
        original_string = instr_string
        try:
            if instr_string[0].isdigit():
                substrings = instr_string.split(" ")
                self.pc = int(substrings[0])
                self.name = substrings[1][:-1]
            else:
                self.pc = pc 
                self.name = instr_string[:-1]
        except:
            sys.exit("Unable to parse \"" + original_string + "\" into its components! Should be something like \"75 function:\" or \"subroutine:\".")

   
    def __str__(self):
        return f"Function Location Name: {self.name}, pc: {self.pc}"