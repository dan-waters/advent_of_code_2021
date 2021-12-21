require 'open-uri'

Coordinate = Struct.new(:x, :y) do
  def neighbours
    @neighbours ||= [
      find_coord(x - 1, y - 1),
      find_coord(x, y - 1),
      find_coord(x + 1, y - 1),
      find_coord(x - 1, y),
      self,
      find_coord(x + 1, y),
      find_coord(x - 1, y + 1),
      find_coord(x, y + 1),
      find_coord(x + 1, y + 1)
    ]
  end

  def hash
    @hash ||= super
  end
end

COORDS = {}

def find_coord(x, y)
  if COORDS[[x, y]]
    COORDS[[x, y]]
  else
    COORDS[[x, y]] = Coordinate.new(x, y)
  end
end

algorithm = open('algorithm.txt').readline(chomp: true).chars
image = {}

open('image.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    coord = find_coord(x, y)
    image[coord] = (char == '#' ? 1 : 0)
  end
end

2.times do |i|
  processed_image = {}
  image.keys.each do |coord|
    value = 0
    coord.neighbours.each do |neighbour|
      unless image[neighbour]
        image[neighbour] = i % 2
        processed_image[neighbour] = (i + 1) % 2
      end
      value <<= 1
      value |= image[neighbour]
    end
    processed_image[coord] = (algorithm[value] == '#' ? 1 : 0)
  end
  image = processed_image
end

puts image.values.select { |i| i == 1 }.count

# part 2

algorithm = open('algorithm.txt').readline(chomp: true).chars
image = {}

open('image.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    coord = find_coord(x, y)
    image[coord] = (char == '#' ? 1 : 0)
  end
end

now = Time.now
50.times do |i|
  processed_image = {}
  image.keys.each do |coord|
    value = 0
    coord.neighbours.each do |neighbour|
      unless neighbour_val = image[neighbour]
        # by inspecting the algorithm, we can see that the current value
        # of the background is going to be off-on-off-...
        # and the next colour will be on-off-on...
        # this lets us dynamically expand the grid
        neighbour_val = image[neighbour] = i % 2
        processed_image[neighbour] = (i + 1) % 2
      end
      value <<= 1
      value |= neighbour_val
    end
    processed_image[coord] = (algorithm[value] == '#' ? 1 : 0)
  end
  image = processed_image
end

puts image.values.select { |i| i == 1 }.count
puts (Time.now - now)