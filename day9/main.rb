require 'open-uri'

Coordinate = Struct.new(:x, :y) do
  def neighbours
    [
        Coordinate.new(x - 1, y),
        Coordinate.new(x + 1, y),
        Coordinate.new(x, y - 1),
        Coordinate.new(x, y + 1)
    ]
  end
end

map = {}

open('map.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |value, x|
    coord = Coordinate.new(x, y)
    map[coord] = value.to_i
  end
end

low_points = {}

map.each do |coord, value|
  neighbours = coord.neighbours
  if neighbours.all?{|neighbour| map[neighbour].nil? || map[neighbour] > value}
    low_points[coord] = value
  end
end

puts low_points.values.sum + low_points.length

# part 2

basins = []

low_points.each do |low_point, value|
  basin = {low_point => value}
  previous_size = basin.size

  loop do
    basin.dup.each do |point, value|
      neighbours = point.neighbours
      neighbours.select{|neighbour| map[neighbour] && map[neighbour] > value && map[neighbour] < 9}.each do |coord|
        basin[coord] = map[coord]
      end
    end
    # if we've not added any new boys we can stop
    break if previous_size == basin.size

    # otherwise, we keep trying!
    previous_size = basin.size
  end

  basins << basin
end

puts basins.sort_by(&:length).reverse.take(3).map(&:length).inject(:*)