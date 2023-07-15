import sys
import re

data_objects = []

class DataVal:
    def __init__(self, data_line, data_address):
        self.data_line = data_line
        self.var_name = ""
        self.data_type = ""
        self.bits = 0
        self.value_string = ""
        self.value = 0
        self.address = 0
        self.data_address = 0  # will remain 0 if data value is offset or offset_long because doesnt have RAM address
        self.dec_parse(data_address)


    def __str__(self):
        return f"Name: {self.var_name}, Number of bits: {self.bits}, value in decimal: {self.value}, data_address: {self.data_address}"

    def dec_parse(self, data_address):
        original_string = self.data_line
        print("Parsing \"" + original_string + "\"...")

        # split data_line into three substrings (last substring may contain a space as it may have a specified address)
        try:
            #self.var_name, self.data_type, self.value_string = self.data_line.split(" ")
            substrings = self.data_line.split(" ")
            self.var_name = substrings[0]
            self.data_type = substrings[1]
            self.value_string = ' '.join(substrings[2:])  # contains everything not in the first 2 substrings, reconstructed with space
        except:
            sys.exit("Unable to split \"" + self.data_line + "\" into name, datatype, and value (+ address). Check syntax!")

        # parse var_name to remove colon and check if valid variable name
        if self.var_name[-1] != ':' or not re.match("^[A-Za-z_][A-Za-z0-9_]*$", self.var_name[:-1]):
            sys.exit("Syntax error: \"" + self.var_name[:-1] + "\" not a valid variable name!")
        else:
            self.var_name = self.var_name[:-1]

        # parse data_type to remove period and check if valid data type name
        if self.data_type[0] != '.' or not re.match("^[A-Za-z_][A-Za-z0-9_]*$", self.data_type[1:]):
            sys.exit("Syntax error: \"" + self.data_type[1:] + "\" not a valid data type!")
        else:
            self.data_type = self.data_type[1:]
            if self.data_type == "word":
                self.bits = 16
            elif self.data_type == "offset":
                self.bits = 9
            elif self.data_type == "offset_long":
                self.bits = 12
            else:
                sys.exit("\"" + original_string + "\" not a valid datatype! Needs to be \"word\", \"offset\", or \"offset_long\"!")

        address_string = ""
        # check if there is a space remaining, meaning that there are two arguments
        if self.value_string.count(" ") == 1 and self.data_type == "word":
            split_string = self.value_string.split(" ")
            self.value_string = split_string[0]
            address_string = split_string[1]
        elif self.value_string.count(" ") > 0:
            sys.exit("\"" + original_string + "\": too many spaces after datatype!")

        address_val = 0
        # parse address string if it was created in prior step
        if address_string != "":
            if address_string[:2] == "0x":
                address_val = int(address_string[2:], 16)
            # binary string to integer
            elif self.value_string[0] == 'b':
                address_val = int(address_string[1:], 2)
            # integer string (positive or negative) to integer
            else: 
                address_val = int(address_string)
            if address_val > 4095 or address_val < 1:
                sys.exit("\"" + original_string + "\": address outside of range of RAM! 1 <= x <= 4095")

        # parse value
        try: 
            print("Parsing value " + self.value_string + "...")
            # hexadecimal string to integer
            if self.value_string[:2] == "0x":
                self.value = int(self.value_string[2:], 16)
                print(self.data_type + "Value as an integer: " + str(self.value))
            # binary string to integer
            elif self.value_string[0] == 'b':
                self.value = int(self.value_string[1:], 2)
                print(self.data_type + " Value as an integer: " + str(self.value))
            # character(s) to ascii integer
            elif self.value_string[0] == '\"' and self.value_string[-1] == '\"' and len(self.value_string) == 4:
                self.value = ord(self.value_string[1])*256 + ord(self.value_string[2])
            # integer string (positive or negative) to integer
            else: 
                self.value = int(self.value_string)
                print(self.data_type + " Value as an integer: " + str(self.value))
        except:
            sys.exit("Unable to parse \"" + self.data_type + "\" value into an integer value!")

        # test that value as integer is within the limits of the datatype
        match self.bits:
            case 9:
                maxVal = 511
                minVal = -256
            case 12:
                maxVal = 4095
                minVal = 0
            case 16:
                maxVal = 65535
                minVal = -32768
            case _:
                sys.exit("Unable to set maximums and minimums for value!")
        if self.value > maxVal or self.value < minVal:
            sys.exit("Overflow error! \"" + self.var_name + "\" is too large for declared datatype!")

        # if the datatype is a word, need to assign that data to a location in memory (address 0 thru 4095)
        # start at the final address (4095) and work backwards
        if self.data_type == "word" and address_val != 0:
            self.data_address = address_val
        elif self.data_type == "word":
            self.data_address = data_address