require 'open-uri'

Coordinate = Struct.new(:x, :y) do
  def neighbours
    [
        Coordinate.new(x - 1, y),
        Coordinate.new(x + 1, y),
        Coordinate.new(x, y - 1),
        Coordinate.new(x, y + 1),
        Coordinate.new(x - 1, y - 1),
        Coordinate.new(x + 1, y + 1),
        Coordinate.new(x + 1, y - 1),
        Coordinate.new(x - 1, y + 1)
    ]
  end
end

class Octopus
  def initialize(energy)
    @energy = energy
  end

  def increment!
    @energy += 1
  end

  def ready_to_flash?
    @energy > 9 && !flashed?
  end

  def flash!
    @flashed = true
  end

  def flashed?
    @flashed
  end

  def reset!
    @flashed = false
    @energy = 0
  end
end

octopi = {}

open('octopi.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    octopus = Octopus.new(char.to_i)
    coord = Coordinate.new(x, y)
    octopi[coord] = octopus
  end
end

flashes = 0

100.times do
  octopi.values.map(&:increment!)

  while octopi.values.any?(&:ready_to_flash?) do
    octopi.values.select(&:ready_to_flash?).each do |octopus|
      octopus.flash!
      octopi.key(octopus).neighbours.each do |coord|
        neighbour = octopi[coord]
        if neighbour
          neighbour.increment!
        end
      end

      flashes +=1
    end
  end

  octopi.values.select(&:flashed?).map(&:reset!)
end

puts flashes

# we start at 100 as we've already done those above

loops = 100

loop do
  loops += 1

  octopi.values.map(&:increment!)

  while octopi.values.any?(&:ready_to_flash?) do
    octopi.values.select(&:ready_to_flash?).each do |octopus|
      octopus.flash!
      octopi.key(octopus).neighbours.each do |coord|
        neighbour = octopi[coord]
        if neighbour
          neighbour.increment!
        end
      end

      flashes +=1
    end
  end

  break if octopi.values.all?(&:flashed?)

  octopi.values.select(&:flashed?).map(&:reset!)
end

puts loops