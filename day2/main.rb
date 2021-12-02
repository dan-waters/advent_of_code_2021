require 'open-uri'

instructions = open('instructions.txt').readlines(chomp: true)

puts 'part 1'

displacement = 0
depth = 0

instructions.each do |instruction|
  type, value = instruction.split(' ')
  value = value.to_i

  case type
  when 'forward'
    displacement += value
  when 'down'
    depth += value
  when 'up'
    depth -= value
  else
    raise 'o no'
  end
end

puts depth * displacement
puts
puts 'part 2'

aim = 0
displacement = 0
depth = 0

instructions.each do |instruction|
  type, value = instruction.split(' ')
  value = value.to_i

  case type
  when 'forward'
    displacement += value
    depth += aim * value
  when 'down'
    aim += value
  when 'up'
    aim -= value
  else
    raise 'o no'
  end
end

puts depth * displacement