require 'open-uri'

starting_string = 'CKFFSCFSCBCKBPBCSPKP'

rules = open('rules.txt').readlines(chomp: true).map do |line|
  line.split(' -> ')
end.to_h

# part 1 - this was horribly slow

output = starting_string

10.times do
  new_output = ''
  output.chars.each_cons(2) do |first, second|
    if inserted = rules[first + second]
      new_output += first + inserted
    else
      new_output += first
    end
  end
  output = new_output + output.chars.last
end

most_common = output.chars.max_by { |char| output.chars.count(char) }
least_common = output.chars.min_by { |char| output.chars.count(char) }

puts(output.chars.count(most_common) - output.chars.count(least_common))

# part 2 - this was surprisingly quick

def count_pairs(polymer)
  counts = Hash.new(0)
  polymer.chars.each_cons(2) do |first, second|
    pair = first + second
    counts[pair] += 1
  end
  counts
end

def iterate_rules(rule_counts, rules)
  new_counts = Hash.new(0)
  rule_counts.each do |pair, count|
    if insert = rules[pair]
      new_counts[pair[0] + insert] += count
      new_counts[insert + pair[1]] += count
    else
      new_counts[pair] += count
    end
  end
  new_counts
end

pairs = count_pairs(starting_string)

40.times do
  pairs = iterate_rules(pairs, rules)
end

# at this point we have a map of all pairs of two letters, but we
# still need to count how much they contribute to the final string

all_letters = pairs.keys.join.chars.uniq
letter_counts = all_letters.map { |l| [l, 0] }.to_h

# each pair contributes 'half' a letter, since the letter
# will appear in two pairs
# exceptions are:
# * double letter pairs, which contribute half per letter (so 1)
# * the first and last letters, which only appear in one pair

all_letters.each do |letter|
  pairs.select { |k, v| k.include?(letter) }.each do |k, v|
    if k == letter * 2
      letter_counts[letter] += v
    else
      letter_counts[letter] += (v * 0.5)
    end
  end

  if [starting_string[0], starting_string[-1]].include?(letter)
    letter_counts[letter] += 0.5
  end
end

puts (letter_counts.values.max - letter_counts.values.min).to_i