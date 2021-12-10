require 'open-uri'

OPENERS = '([{<'.chars
CLOSERS = ')]}>'.chars
PAIRS = {'(' => ')', '[' => ']', '{' => '}', '<' => '>'}

class ChunkLine
  attr_accessor :corrupt_character, :incomplete_pairs, :completion

  def initialize(input)
    parsed = []

    input.chars.each do |bracket|
      if OPENERS.include?(bracket)
        parsed.push bracket
      elsif CLOSERS.include?(bracket)
        opener = parsed.pop
        if PAIRS[opener] != bracket
          @corrupt_character = bracket
          return
        end
      end
    end

    if parsed.any?
      @incomplete_pairs = parsed
      @completion = @incomplete_pairs.reverse.map { |bracket| PAIRS[bracket] }
    end
  end

  def corrupt?
    @corrupt_character != nil
  end

  def incomplete?
    @incomplete_pairs != nil
  end
end

chunks = open('chunks.txt').
    readlines(chomp: true).
    map { |input| ChunkLine.new(input) }


SCORES = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
}

part_1_score = chunks.
    select(&:corrupt?).
    map { |chunk_line| SCORES[chunk_line.corrupt_character] }.
    sum

puts part_1_score


MULTIPLIERS = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
}

all_scores = chunks.
    select(&:incomplete?).
    map { |chunk_line| chunk_line.completion.map { |bracket| MULTIPLIERS[bracket] }.reduce(0) { |acc, value| (acc * 5) + value } }

part_2_score = all_scores.sort[(all_scores.length - 1) / 2]

puts part_2_score