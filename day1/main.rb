require 'open-uri'


depths = open('depths.txt').readlines(chomp: true).map(&:to_i)
depth_pairs = depths.zip(depths[1..-1])

puts depth_pairs.select{|first, second| second && second > first}.count


depth_triples = depths.zip(depths[1..-1], depths[2..-1])
depth_windows = depth_triples.select(&:all?).map(&:sum)

window_pairs = depth_windows.zip(depth_windows[1..-1])

puts window_pairs.select{|first, second| second && second > first}.count