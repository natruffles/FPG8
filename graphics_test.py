# follow the below link to install pysdl2 and its dependencies:
# https://pysdl2.readthedocs.io/en/0.9.13/install.html

# this is a test of simulating a low-resolution black and white
# display, the goal in the future is for this display to function 
# like a UART-driven monitor (sort of like old RS-232 monitors)

import sdl2
import sdl2.ext
import random

# Set resolutions
low_res_width = 32
low_res_height = 16
window_width = 1280
window_height = 640

# Calculate the scale factor
scale_x = window_width // low_res_width
scale_y = window_height // low_res_height


sdl2.ext.init()

window = sdl2.ext.Window("FPGsnAke", size=(window_width, window_height))
window.show()
surface = window.get_surface()
pixels2d = sdl2.ext.pixels2d(surface)

blah = 0

running = True
while running:
    # Generate random pixel coordinates
    x = random.randint(0, low_res_width - 1)
    y = random.randint(0, low_res_height - 1)

    # Scale the coordinates
    scaled_x = x * scale_x
    scaled_y = y * scale_y

    # Set the pixel color using NumPy array indexing, 
    # x above should be from 0 to 31, y from 0 to 15 to set pixel value, the rest has to stay
    if blah == 0:
        pixels2d[scaled_x:scaled_x + scale_x, scaled_y:scaled_y + scale_y] = 0xFFFFFFFF
        blah = 1
    elif blah == 1:
        pixels2d[scaled_x:scaled_x + scale_x, scaled_y:scaled_y + scale_y] = 0xFF000000
        blah = 0

    # sdl2.SDL_Delay(500)

    window.refresh()
    for event in sdl2.ext.get_events():
        if event.type == sdl2.SDL_QUIT:
            running = False
            break

sdl2.ext.quit()
