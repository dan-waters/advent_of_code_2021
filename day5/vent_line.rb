class VentLine
  attr_accessor :start_point, :end_point

  def initialize(line)
    points = line.split(' -> ').map do |coords|
      x, y = coords.split(',').map(&:to_i)
      Coordinate.new(x, y)
    end
    @start_point = points[0]
    @end_point = points[1]
  end

  def horizontal?
    start_point.y == end_point.y
  end

  def vertical?
    start_point.x == end_point.x
  end

  def points
    if horizontal?
      x_range.map do |x|
        Coordinate.new(x, start_point.y)
      end
    elsif vertical?
      y_range.map do |y|
        Coordinate.new(start_point.x, y)
      end
    else
      # because this is guaranteed to be
      # at 45 degrees, these ranges will
      # have the same length
      x_range.zip(y_range).map do |x, y|
        Coordinate.new(x, y)
      end
    end
  end

  private

  # this needs to return in the original order for the
  # diagonal coordinates to zip in part 2
  def x_range
    if start_point.x <= end_point.x
      (start_point.x..end_point.x).to_a
    else
      (end_point.x..start_point.x).to_a.reverse
    end
  end

  # this needs to return in the original order for the
  # diagonal coordinates to zip in part 2
  def y_range
    if start_point.y <= end_point.y
      (start_point.y..end_point.y).to_a
    else
      (end_point.y..start_point.y).to_a.reverse
    end
  end
end