require 'open-uri'

Coord = Struct.new(:x, :y) do
  def neighbours
    [
        Coord.new(x - 1, y),
        Coord.new(x + 1, y),
        Coord.new(x, y - 1),
        Coord.new(x, y + 1)
    ]
  end

  def in_grid?(min_x, max_x, min_y, max_y)
    0 <= self.x && self.x <= max_x && 0 <= self.y && self.y <= max_y
    #self.x.between?(min_x, max_x) && self.y.between?(min_y, max_y)
  end
end

chitons = {}

open('chitons.txt').readlines(chomp: true).each_with_index do |risks, y|
  risks.chars.each_with_index do |risk, x|
    chitons[Coord.new(x, y)] = risk.to_i
  end
end
# part 1 - it's slow, so comment out for part 2 debugging
min_risks = {}

chitons.keys.each do |key|
  min_risks[key] = nil
end

starting_corner = Coord.new(0, 0)
min_risks[starting_corner] = 0
points_to_search = starting_corner.neighbours

while min_risks.values.any?(&:nil?) do
 point_set = points_to_search & chitons.keys
 next_set = []
 point_set.each do |point|
   min_risks[point] ||= chitons[point] + point.neighbours.map { |neighbour| min_risks[neighbour] }.compact.min
   next_set += point.neighbours.select { |n| min_risks[n].nil? }
 end
end


max_x = chitons.keys.map(&:x).max
max_y = chitons.keys.map(&:y).max

puts min_risks[Coord.new(max_x, max_y)]

# part 2

larger_map = {}

max_x = chitons.keys.map(&:x).max
max_y = chitons.keys.map(&:y).max
x_repeat = max_x + 1
y_repeat = max_y + 1

(0..4).each do |dx|
  (0..4).each do |dy|
    chitons.each do |k, v|
      coord = Coord.new(k.x + dx * x_repeat, k.y + dy * y_repeat)
      value = v + dx + dy
      if value > 9
        value -= 9
      end
      larger_map[coord] = value
    end
  end
end

def search(map)
  lowest_risk_by_point = {}

  starting_corner = Coord.new(0, 0)
  lowest_risk_by_point[starting_corner] = 0
  points_to_search = [starting_corner]

  max_x = map.keys.map(&:x).max
  max_y = map.keys.map(&:y).max
  final_corner = Coord.new(max_x, max_y)

  while points_to_search.any?
    point = points_to_search.shift

    cost = lowest_risk_by_point[point]
    point.neighbours.each do |neighbour|
      if neighbour.in_grid?(0, max_x, 0, max_y)
        neighbour_cost = cost + map[neighbour]
        previous_cost = lowest_risk_by_point[neighbour]
        if previous_cost.nil? || previous_cost > neighbour_cost
          lowest_risk_by_point[neighbour] = neighbour_cost
          index = points_to_search.bsearch_index{|p| lowest_risk_by_point[p] > neighbour_cost} || points_to_search.size
          points_to_search.insert(index, neighbour)
        end
      end
    end
  end

  lowest_risk_by_point[final_corner]
end

start = Time.now
puts search(chitons)
puts (Time.now - start)


start = Time.now
puts search(larger_map)
puts (Time.now - start)

# optimising

Search = Struct.new(:point, :value) do
  def <=>(other)
    self.value <=> other.value
  end
end

def pqueue_search(map)
  lowest_risk_by_point = {}

  starting_corner = Search.new(Coord.new(0, 0), 0)
  lowest_risk_by_point[starting_corner.point] = 0
  points_to_search = [starting_corner]

  max_x = map.keys.map(&:x).max
  max_y = map.keys.map(&:y).max
  final_corner = Coord.new(max_x, max_y)

  until points_to_search.empty?
    search = points_to_search.shift
    point = search.point

    cost = search.value
    point.neighbours.each do |neighbour|
      if neighbour.in_grid?(0, max_x, 0, max_y)
        neighbour_cost = cost + map[neighbour]
        previous_cost = lowest_risk_by_point[neighbour]
        if previous_cost.nil? || previous_cost > neighbour_cost
          lowest_risk_by_point[neighbour] = neighbour_cost
          index = points_to_search.bsearch_index{|p| lowest_risk_by_point[p.point] > neighbour_cost} || points_to_search.size
          points_to_search.insert(index, Search.new(neighbour, neighbour_cost))
        end
      end
    end
  end

  lowest_risk_by_point[final_corner]
end


start = Time.now
puts pqueue_search(larger_map)
puts (Time.now - start)