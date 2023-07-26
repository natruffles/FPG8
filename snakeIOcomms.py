# can set frames per second to be around 30 or less for a playable snake game experience

# follow the below link to install pysdl2 and its dependencies:
# https://pysdl2.readthedocs.io/en/0.9.13/install.html

# handles input and output devices for CPU running the snake game
# acts as an input device: sends ASCII value representing W, A, S, or D over UART
# acts as an output device: outputs a 32x16 black-and-white UART-driven display (like an old RS-232 monitor)

import sdl2
import sdl2.ext
import random
import serial
import struct
import time

# Set resolutions for display
low_res_width = 32
low_res_height = 16
window_width = 1280
window_height = 640
# Calculate the scale factor for display
scale_x = window_width // low_res_width
scale_y = window_height // low_res_height

# open the display window and initialize the pixel array
sdl2.ext.init()
window = sdl2.ext.Window("FPGsnAke", size=(window_width, window_height))
window.show()
surface = window.get_surface()
pixels2d = sdl2.ext.pixels2d(surface)

port = "COM5"  # Specify the serial port name or path of CPU I/O
baudrate = 115200
# open serial port, after 0.05 seconds will timout the attempted serial read
ser = serial.Serial(port, baudrate, timeout=0.1)

# reading 128 bytes (64 good bytes and 64 junk bytes) at 115200 baud rate takes 0.008888888 seconds
break_cond = 0

# INPUT/OUTPUT LOOP
running = True
while running:
    start_time = time.time()

    key_code = 0
    for event in sdl2.ext.get_events():
        if event.type == sdl2.SDL_QUIT:
            running = False
            break
        elif event.type == sdl2.SDL_KEYDOWN:
            # Get the key code from the event
            key_code = event.key.keysym.sym

            # Convert the key code to a string using SDL_GetKeyName
            key_name = sdl2.SDL_GetKeyName(key_code).decode("utf-8")

            if key_code == 1073741904:
                key_code = 97
            elif key_code == 1073741903:
                key_code = 100
            elif key_code == 1073741905:
                key_code = 115
            elif key_code == 1073741906:
                key_code = 119
            #a: 97
            #d: 100
            #s: 115
            #w: 119

    # if WASD or arrow keys are pressed, sends those over UART, else sends zeroes
    if key_code == 97 or key_code == 100 or key_code == 115 or key_code == 119:
        # print(f"Key pressed: {key_name} (key code: {key_code})")
        packed_data = struct.pack(">H", key_code)
        # print(packed_data)
        ser.write(packed_data)
        break_cond = 1
    else:
        # print("no key pressed...")
        ser.write(b'\x00\x00')

    # time to get keypress events
    elapsed_time = time.time() - start_time
    print(f"Time to get keypress events: {elapsed_time:.5f} seconds")
    start_time = time.time()

    # read all of the display data at once (64 bytes)
    data = ser.read(64)

    # if data is read over uart, update display, else don't bother (for now)
    if not data:
        continue

    # time to read data over uart
    elapsed_time = time.time() - start_time
    print(f"Time to read data over UART: {elapsed_time:.5f} seconds")
    start_time = time.time()

    # Reshape the 64-byte array into a 16x32 2D array of 0s and 1s (column-major order)
    array_2d = [[(data[j*4 + i//8] >> (7 - i%8)) & 1 for j in range(16)] for i in range(32)]

    # Print the 2D array (optional, for visualization)
    # for row in array_2d:
    #    print(row)

    # update the pixel2d array with the contents of array_2d of 0s and 1s
    for row_index in range(len(array_2d)):
        for col_index in range(len(array_2d[row_index])):
            # Scale the coordinates
            scaled_x = row_index * scale_x
            scaled_y = col_index * scale_y
            if array_2d[row_index][col_index] == 1:
                hex_val = 0xFFFFFFFF # white
            else:
                hex_val = 0xFF000000 # black
            pixels2d[scaled_x:scaled_x + scale_x, scaled_y:scaled_y + scale_y] = hex_val

    # refresh the window to show the updated pixels2d array
    window.refresh()

    elapsed_time = time.time() - start_time
    print(f"Time create pixel array and refresh window: {elapsed_time:.5f} seconds")

    if break_cond:
        break

sdl2.ext.quit()
