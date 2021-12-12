require 'open-uri'

Cave = Struct.new(:name) do
  def big?
    /[A-Z]+/.match?(self.name)
  end
end

@connections = open('caves.txt').readlines(chomp: true).map do |cave_connection|
  cave_1, cave_2 = cave_connection.split('-')
  [Cave.new(cave_1), Cave.new(cave_2)]
end

@start_cave = Cave.new('start')
@end_cave = Cave.new('end')

# part 1

paths = [[@start_cave]]

def extend_paths(current_path)
  last_cave = current_path.last
  unless last_cave == @end_cave
    @connections.select { |con| con.include?(last_cave) }.map do |con|
      new_cave = con.detect { |c| c != last_cave }
      if new_cave.big? || !current_path.include?(new_cave)
        new_path = current_path.dup
        new_path << new_cave
      end
    end
  else
    []
  end
end

loop do
  new_paths = []
  paths.each do |path|
    new_paths += extend_paths(path).compact
  end

  break if new_paths.count == 0

  paths = paths.select{|path| path.include?(@end_cave)} + new_paths
end

puts paths.select{|path| path.include?(@end_cave)}.count

# part 2

@start_cave = Cave.new('start')
@end_cave = Cave.new('end')

paths = [[@start_cave]]

def extend_paths(current_path)
  last_cave = current_path.last
  if last_cave == @end_cave
    []
  else
    @connections.select { |con| con.include?(last_cave) }.map do |con|
      new_cave = con.detect { |c| c != last_cave }
      if new_cave.big? ||
          !current_path.include?(new_cave) ||
          # the idea here is to ask "are all the small caves we've visited unique?" while
          # also checking to make sure we're not revisiting the start or end caves
          (![@start_cave, @end_cave].include?(new_cave) &&
              current_path.select{|cave| !cave.big?}.count == current_path.select{|cave| !cave.big?}.uniq.count)
        new_path = current_path.dup
        new_path << new_cave
      end
    end
  end
end

loop do
  new_paths = []
  paths.each do |path|
    new_paths += extend_paths(path).compact
  end

  break if new_paths.count == 0

  paths = paths.select{|path| path.include?(@end_cave)} + new_paths
end

puts paths.select{|path| path.include?(@end_cave)}.count