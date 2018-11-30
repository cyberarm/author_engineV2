# Game API
An example game
``` ruby
# Your setup method
def init
  @x = 0
  @y = 0
  @z = 0

  @birdie = 0
end

# All drawing operations must happen in draw
def draw
  rect(@x, @y, width, height, black, @z)
  sprite(@birdie, @x, @y, @z)
  text("string", @x, @y, 10, @z, white)
end

def update
  @x+=1 if button?("right")
  @x-=1 if button?("left")
  @y-=1 if button?("up")
  @y+=1 if button?("down")
end
```

# Common
### width
  Virtual display width (e.g. 128)

### height
  Virtual display height (e.g. 128)

### fps
  Current Frames Per Second

### milliseconds
  Milliseconds since game started

# Graphics
### rect(x = 0, y = 0, width = 1, height = 1, color = white, z = 0)
### sprite(sprite_sheet_index, x = 0, y = 0, z = 0, color = white)
### text(string, x = 0, y = 0, size = 4, z = 0, color = white)

### translate(x, y, &block)
  Translate the contents of block by x and y
### rotate(angle, around_x = 0, around_y = 0, &block)
  Rotate the contents of block by angle, rotating about at around_x and around_y

# Input
### button?(string)
returns true if the specied button is currently being pressed

Valid values for string are:
#### "left"
#### "right"
#### "up"
#### "down"
#### "x"
mapped to the X key
#### "y"
mapped to the C key

# Colors
### black
### dark_blue
### dark_purple
### dark_green
### brown
### dark_gray
### light_gray
### white
### red
### orange
### yellow
### green
### blue
### indigo
### pink
### peach
