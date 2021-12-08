require 'open-uri'

readings = open('readings.txt').readlines(chomp: true)

# part 1

output_digits = readings.map { |reading| reading.split('|').last }.map { |outputs| outputs.split(' ') }

puts output_digits.flatten.select { |digit| [2, 3, 4, 7].include?(digit.length) }.count

# part 2

VALID_CODES = {
    0 => 'abcefg'.chars,
    1 => 'cf'.chars,
    2 => 'acdeg'.chars,
    3 => 'acdfg'.chars,
    4 => 'bcdf'.chars,
    5 => 'abdfg'.chars,
    6 => 'abdefg'.chars,
    7 => 'acf'.chars,
    8 => 'abcdefg'.chars,
    9 => 'abcdfg'.chars
}

class Reading
  attr_accessor :inputs, :outputs

  def initialize(reading)
    input_strings, output_strings = reading.split('|').map { |x| x.split(' ') }
    @inputs = input_strings.map(&:chars).map(&:sort)
    @outputs = output_strings.map(&:chars).map(&:sort)
  end

  def solve!
    available_chars = 'abcdefg'.chars
    all_possibilities = available_chars.reduce({}) { |hash, char| hash[char] = available_chars; hash }

    # try and make some sensible guesses at possible combinations
    @inputs.sort_by(&:length).each do |input|
      input_possibilities = VALID_CODES.select { |_, code| code.length == input.length }.values.flatten
      input.each do |letter|
        all_possibilities[letter] = (all_possibilities[letter] & input_possibilities)
      end
      if input_possibilities.length == input.length
        all_possibilities.reject { |k, v| input.include?(k) }.each do |k, v|
          all_possibilities[k] = v - input_possibilities
        end
      end
    end

    # hopefully by this point we've narrowed it down enough
    while all_possibilities.values.any? { |v| v.length > 1 } do
      all_possibilities.each do |letter, possibilities|
        frequency_of_key = @inputs.select { |input| input.include?(letter) }.count
        values = possibilities.select do |possibility|
          VALID_CODES.values.select { |code| code.include?(possibility) }.count == frequency_of_key
        end

        if values.length == 1
          all_possibilities.each do |k, v|
            if k == letter
              all_possibilities[k] = values
            else
              all_possibilities[k] = v - values
            end
          end
        end
      end
    end

    # not the prettiest way to join integers together, I agree
    @outputs.map do |output|
      VALID_CODES.keys.detect do |key|
        VALID_CODES[key].join == output.map { |char| all_possibilities[char] }.sort.join
      end.to_s
    end.join.to_i
  end
end

puts(readings.map do |reading|
  Reading.new(reading).solve!
end.sum)