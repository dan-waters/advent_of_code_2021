require 'open-uri'

crabs = open('crabs.txt').readline.split(',').map(&:to_i)

# part 1

optimum = (crabs.min..crabs.max).min_by do |position|
  crabs.map{|crab| (crab - position).abs}.sum
end

puts crabs.map{|crab| (crab - optimum).abs}.sum

# part 2

@triangles = {}

def triangle(int)
  @triangles[int] ||= (1..int).sum
end

optimum = (crabs.min..crabs.max).min_by do |position|
  crabs.map{|crab| triangle((crab - position).abs)}.sum
end

puts crabs.map{|crab| triangle((crab - optimum).abs)}.sum