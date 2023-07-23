import serial
import sys
import time

port = "COM5"  # Specify the serial port name or path
baudrate = 115200  # Specify the baudrate

# Open the serial port
ser = serial.Serial(port, baudrate, timeout=0.1)

time.sleep(1)

data = ""
ser.write(b"ab")
data = ser.read(64)
if data:
    print(data)
else:
    print("no data!")

data = ""
ser.write(b"bc")
data = ser.read(64)
if data:
    print(data)
else:
    print("no data!")
    
data = ""
ser.write(b"ab")
data = ser.read(64)
if data:
    print(data)
else:
    print("no data!")