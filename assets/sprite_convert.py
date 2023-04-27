from PIL import Image

# Load the sprite image
image = Image.open("./dood_right.png")
sprite_img = image.convert('RGB')

# Get the dimensions of the sprite
width, height = sprite_img.size

# Iterate over each pixel in the sprite and populate the array
# Has to be in one line.
with open('./output.txt', 'w') as out:
    out.write('\'{\n')
    for y in range(height):
        out.write('\'{')
        for x in range(width):
            r,g,b = sprite_img.getpixel((x, y))
            out.write(f"12\'h{r>>4:x}{g>>4:x}{b>>4:x}")
            if x != width - 1:
                out.write(',')
        out.write('}')
        if y != height - 1:
            out.write(',\n')
    out.write('}\n')

    out.write(f"Width: {width}, Height: {height}")
