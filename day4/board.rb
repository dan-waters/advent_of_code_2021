class Board
  attr_accessor :rows

  def initialize(lines)
    @rows = lines.map do |line|
      line.split(' ').map(&:to_i)
    end

    @called_numbers = []
  end

  def columns
    @columns ||= rows.transpose
  end

  def call(number)
    @called_numbers << number
  end

  def complete?
    rows.any? {|row| (row - @called_numbers).empty?} || columns.any? {|col| (col - @called_numbers).empty?}
  end

  def remaining_number_sum
    sum = 0
    rows.each do |row|
      row.each do |number|
        unless @called_numbers.include?(number)
          sum += number
        end
      end
    end
    sum
  end
end