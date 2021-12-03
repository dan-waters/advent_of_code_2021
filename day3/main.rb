require 'open-uri'

diagnostics = open('diagnostics.txt').readlines(chomp: true).map(&:chars)

length = diagnostics.first.length

gamma = []
epsilon = []

length.times do |i|
  all = diagnostics.map { |d| d[i] }
  gamma << all.max_by { |i| all.count(i) }
  epsilon << all.min_by { |i| all.count(i) }
end

puts gamma.join.to_i(2) * epsilon.join.to_i(2)

oxygen = 0
co2 = 0

oxygens = diagnostics.dup
co2s = diagnostics.dup

length.times do |i|
  all_oxygens = oxygens.map { |d| d[i] }
  more_common = all_oxygens.count('0') > all_oxygens.count('1') ? '0' : '1'
  oxygens = oxygens.select { |x| x[i] == more_common }
  oxygen = oxygens.join.to_i(2) if oxygens.count == 1

  all_co2s = co2s.map { |d| d[i] }
  less_common = all_co2s.count('1') < all_co2s.count('0') ? '1' : '0'
  co2s = co2s.select { |x| x[i] == less_common }
  co2 = co2s.join.to_i(2) if co2s.count == 1
end

puts oxygen * co2