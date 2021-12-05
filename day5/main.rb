require 'open-uri'
require_relative 'vent_line.rb'
Coordinate = Struct.new(:x, :y)

text_lines = open('lines.txt').readlines(chomp: true)

all_lines = text_lines.map { |l| VentLine.new(l) }

# part 1

vertical_lines = all_lines.select(&:vertical?)
horizontal_lines = all_lines.select(&:horizontal?)

map = {}

(vertical_lines + horizontal_lines).each do |line|
  line.points.each do |point|
    if map.key?(point)
      map[point] += 1
    else
      map[point] = 1
    end
  end
end

puts map.values.select { |i| i > 1}.count

#part 2

map = {}

all_lines.each do |line|
  line.points.each do |point|
    if map.key?(point)
      map[point] += 1
    else
      map[point] = 1
    end
  end
end

puts map.values.select { |i| i > 1}.count