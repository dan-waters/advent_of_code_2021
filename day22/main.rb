require 'open-uri'

ranges = []
REGEX = /(?<switch>on|off) x=(?<x_from>-?\d+)..(?<x_to>-?\d+),y=(?<y_from>-?\d+)..(?<y_to>-?\d+),z=(?<z_from>-?\d+)..(?<z_to>-?\d+)/

open('init.txt').readlines(chomp: true).each do |line|
  parts = REGEX.match(line)
  x_range = (parts[:x_from].to_i..parts[:x_to].to_i)
  y_range = (parts[:y_from].to_i..parts[:y_to].to_i)
  z_range = (parts[:z_from].to_i..parts[:z_to].to_i)
  ranges << { switch: parts[:switch], cuboid: { x: x_range, y: y_range, z: z_range } }
end

Coord = Struct.new(:x, :y, :z) do
  def hash
    @hash ||= super
  end
end

def part_1(ranges)
  init_range = (-50..50)
  init_zone = Hash.new('off')
  ranges.each do |instruction|
    x_range = instruction[:cuboid][:x]
    y_range = instruction[:cuboid][:y]
    z_range = instruction[:cuboid][:z]
    if init_range.cover?(x_range.min) || init_range.cover?(x_range.max) &&
      init_range.cover?(y_range.min) || init_range.cover?(y_range.max) &&
      init_range.cover?(z_range.min) || init_range.cover?(z_range.max)
      z_range.each do |z|
        y_range.each do |y|
          x_range.each do |x|
            if init_range.cover?(x) && init_range.cover?(y) && init_range.cover?(z)
              init_zone[Coord.new(x, y, z)] = instruction[:switch]
            end
          end
        end
      end
    end
  end
  init_zone.values.select { |v| v == 'on' }.count
end

puts part_1(ranges)

  ############
 # part two #
############

Cuboid = Struct.new(:x_range, :y_range, :z_range) do
  def count
    (x_range.count) * (y_range.count) * (z_range.count)
  end

  def overlap(other)
    x_min = [x_range.min, other.x_range.min].max
    x_max = [x_range.max, other.x_range.max].min
    y_min = [y_range.min, other.y_range.min].max
    y_max = [y_range.max, other.y_range.max].min
    z_min = [z_range.min, other.z_range.min].max
    z_max = [z_range.max, other.z_range.max].min
    if x_max >= x_min && y_max >= y_min && z_max >= z_min
      Cuboid.new((x_min..x_max), (y_min..y_max), (z_min..z_max))
    else
      nil
    end
  end
end

ranges = []

open('init.txt').readlines(chomp: true).each do |line|
  parts = REGEX.match(line)
  x_range = (parts[:x_from].to_i..parts[:x_to].to_i)
  y_range = (parts[:y_from].to_i..parts[:y_to].to_i)
  z_range = (parts[:z_from].to_i..parts[:z_to].to_i)
  ranges << { switch: parts[:switch], cuboid: Cuboid.new(x_range, y_range, z_range) }
end

on_cubes = []
neg_cubes = []

while ranges.any? do
  range = ranges.shift
  cuboid = range[:cuboid]
  new_neg_cubes = on_cubes.map { |cube| cuboid.overlap(cube) }.compact
  new_on_cubes = neg_cubes.map { |cube| cuboid.overlap(cube) }.compact

  if range[:switch] == 'on'
    new_on_cubes << cuboid
  end
  neg_cubes += new_neg_cubes
  on_cubes += new_on_cubes
end

puts (on_cubes.map(&:count).sum - neg_cubes.map(&:count).sum)