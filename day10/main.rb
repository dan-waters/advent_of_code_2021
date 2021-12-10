require 'open-uri'

OPENERS = '([{<'.chars
CLOSERS = ')]}>'.chars
PAIRS = {'(' => ')', '[' => ']', '{' => '}', '<' => '>'}

class ChunkLine
  attr_accessor :corrupt_character, :incomplete_pairs, :completion

  def initialize(input)
    @input = input
  end

  def parse
    parsed = []

    @input.chars.each do |bracket|
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
      @completion = @incomplete_pairs.reverse.map{|bracket| PAIRS[bracket]}
    end
  end

  def corrupt?
    parse
    @corrupt_character != nil
  end

  def incomplete?
    parse
    @incomplete_pairs != nil
  end
end


SCORES = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
}

part_1_score = 0

open('chunks.txt').readlines(chomp: true).map {|input| ChunkLine.new(input)}.select(&:corrupt?).each do |chunk_line|
  part_1_score += SCORES[chunk_line.corrupt_character]
end

puts part_1_score


MULTIPLIERS = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
}

all_scores = []

open('chunks.txt').readlines(chomp: true).map {|input| ChunkLine.new(input)}.select(&:incomplete?).each do |chunk_line|
  score = 0
  chunk_line.completion.map {|bracket| MULTIPLIERS[bracket]}.each do |value|
    score = (score * 5) + value
  end
  all_scores << score
end

part_2_score = all_scores.sort[(all_scores.length - 1) / 2]

puts part_2_score