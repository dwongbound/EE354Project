from PIL import Image

# Load the sprite image
sprite_img = Image.open("./doodle_left.png")

# Get the dimensions of the sprite
width, height = sprite_img.size

OFF_WHITE = (240,240,192)

# Iterate over each pixel in the sprite and populate the array
# Has to be in one line.
with open('./output.txt', 'w') as out:
    out.write('\'{\n')
    for y in range(height):
        out.write('\'{')
        for x in range(width):
            r,g,b,a = sprite_img.getpixel((x, y))
            if a == 0:
                r,g,b = OFF_WHITE
            out.write(f"12\'h{r>>4:x}{g>>4:x}{b>>4:x}")
            if x != width - 1:
                out.write(',')
        out.write('}')
        if y != height - 1:
            out.write(',\n')
    out.write('}\n')

    out.write(f"Width: {width}, Height: {height}")
