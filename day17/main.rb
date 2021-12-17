class Missile
  attr_accessor :peak_y

  def initialize(x_velocity, y_velocity)
    @x_velocity = x_velocity
    @y_velocity = y_velocity
    @x_position = 0
    @y_position = 0
    @peak_y = 0
  end

  def fire!(x_range, y_range)
    loop do
      @x_position += @x_velocity
      @y_position += @y_velocity
      @x_velocity -= 1 unless @x_velocity == 0
      @y_velocity -= 1
      @peak_y = @y_position if @y_position > @peak_y

      if x_range.include?(@x_position) && y_range.include?(@y_position)
        return true
      elsif @x_position > x_range.max or @y_position < y_range.min
        return false
      end
    end
  end
end


def find_peak_y(x_range, y_range)
  peak_y = 0
  (0..x_range.max).each do |x_velocity|
    (y_range.min..1000).each do |y_velocity|
      missile = Missile.new(x_velocity, y_velocity)
      if missile.fire!(x_range, y_range)
        peak_y = missile.peak_y if missile.peak_y > peak_y
      end
    end
  end

  peak_y
end

ex_x_range = (20..30)
ex_y_range = (-10..-5)

p find_peak_y(ex_x_range, ex_y_range)

x_range = (135..155)
y_range = (-102..-78)

p find_peak_y(x_range, y_range)

# part 2

def find_velocities(x_range, y_range)
  velocities = []
  (0..x_range.max).each do |x_velocity|
    (y_range.min..1000).each do |y_velocity|
      missile = Missile.new(x_velocity, y_velocity)
      if missile.fire!(x_range, y_range)
        velocities << [x_velocity, y_velocity]
      end
    end
  end

  velocities
end

p find_velocities(ex_x_range, ex_y_range).count
p find_velocities(x_range, y_range).count