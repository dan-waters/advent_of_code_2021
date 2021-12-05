require 'open-uri'
require_relative 'board'

numbers = open('numbers.txt').readline.split(',').map(&:to_i)
board_file = open('boards.txt').read.split(/\n\n/)

boards = board_file.map do |board|
  lines = board.split(/\n/)
  Board.new(lines)
end

final_number = nil

numbers.each do |number|
      boards.each do |board|
        board.call(number)
      end
      if boards.any?(&:complete?)
        final_number = number
    break
  end
end

winning_board = boards.detect(&:complete?)

puts winning_board.remaining_number_sum * final_number


boards = board_file.map do |board|
  lines = board.split(/\n/)
  Board.new(lines)
end

complete_boards = []

numbers.each do |number|
  boards.each do |board|
    board.call(number)
  end
  boards.select(&:complete?).each do |board|
    complete_boards << board unless complete_boards.include?(board)
  end

  if boards.all?(&:complete?)
    final_number = number
    break
  end
end

losing_board = complete_boards.last

puts losing_board.remaining_number_sum * final_number