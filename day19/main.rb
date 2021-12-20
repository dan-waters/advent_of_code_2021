require 'open-uri'
require_relative 'matrices'

Scanner = Struct.new(:number, :beacons) do
  attr_accessor :offset, :translation, :reoriented

  def add_beacon(beacon)
    beacons << beacon
  end

  def magnitudes
    magnitudes_with_beacons.keys
  end

  # this builds a map of all the distances (squared) between all beacons, and
  # will return a pair of beacons that are that far apart
  def magnitudes_with_beacons
    @magnitudes_with_beacons ||= beacons.combination(2).map do |beacon_1, beacon_2|
      [[0, 1, 2].map do |index|
        (beacon_1[index, 0] - beacon_2[index, 0]) ** 2
      end.sum, [beacon_1, beacon_2]]
    end.to_h
  end

  # This takes each beacon, rotates its position and offsets it from
  # the scanner - the effect is that the new set of beacons is as if
  # the scanner is positioned at (0, 0, 0) and facing the right way!
  def reorient!
    reoriented_beacons = beacons.map do |beacon|
      offset = self.offset
      translation = self.translation
      translation * beacon - offset
    end
    @reoriented = true
    @magnitudes_with_beacons = nil
    self.beacons = reoriented_beacons
  end
end

scanners = []

scanner_info = open('scanners.txt').readlines
scanner_info.each do |line|
  if line =~ /--- scanner (\d+) ---/
    @scanner = Scanner.new($1.to_i, [])
    scanners << @scanner
  end
  if line =~ /(-?\d+),(-?\d+),(-?\d+)/
    @scanner.add_beacon(Matrix.column_vector([$1, $2, $3].map(&:to_i)))
  end
end

# we need twelve matching beacons to say that overlap,
# which means we need even more distances to match
# (this works out at 66)
matching_threshold = (1..12).to_a.combination(2).count

scanner_pairs = []

scanners.combination(2).each do |scanner_1, scanner_2|
  matches = scanner_1.magnitudes & scanner_2.magnitudes
  if matches.count >= matching_threshold
    scanner_pairs << [scanner_1, scanner_2]
  end
end

# so from inspection, the above shows that there are lots of matches
# and all have twelve beacons in common, which is nice

# I don't think the puzzle works out unless the scanners all overlap
# somewhere, so I assume that they do all overlap.
# Now we try and orient those beacons.

def find_orientation(oriented_scanner, next_scanner)
  matches = oriented_scanner.magnitudes & next_scanner.magnitudes
  translation = offset = nil
  loop do
    # pick any magnitude and start from there
    mag_1 = matches.shift
    scanner_1_point_a, scanner_1_point_b = oriented_scanner.magnitudes_with_beacons[mag_1]
    mag_2 = matches.detect { |m| oriented_scanner.magnitudes_with_beacons[mag_1].include?(scanner_1_point_a) }
    # if it's one of the matching sets of points, it should appear in more than one shared distance
    next unless mag_2

    # Find the same beacons in the second scanner's output.
    # We need two separate readings because otherwise we don't know
    # which of the two matching beacons is which
    scanner_2_match_1 = next_scanner.magnitudes_with_beacons[mag_1]
    scanner_2_match_2 = next_scanner.magnitudes_with_beacons[mag_2]
    scanner_2_point_a = (scanner_2_match_1 & scanner_2_match_2).first
    scanner_2_point_b = scanner_2_match_1.detect { |b| b != scanner_2_point_a }

    # find the relative vector between the two beacons
    scanner_1_difference = scanner_1_point_a - scanner_1_point_b
    scanner_2_difference = scanner_2_point_a - scanner_2_point_b

    # find the translation that turns the second scanner's vector into the first
    translation = MATRICES.detect { |m| m * scanner_2_difference == scanner_1_difference }

    # Our offset here is just the position the scanner is in - find it
    # by rotating one of the shared beacons.
    offset = (translation * scanner_2_point_a) - scanner_1_point_a
    break
  end
  [translation, offset]
end

# Use beacon 0 as the base - I think this could be any beacon though?
base_scanner = scanners.detect { |scanner| scanner.number == 0 }
base_scanner.reoriented = true
base_scanner.offset = Matrix.column_vector([0, 0, 0])
base_scanner.translation = Matrix.identity(3)

# loop through all beacons and orient them against one that's already been oriented
until scanners.all?(&:reoriented) do
  oriented_scanner, next_scanner = scanner_pairs.detect { |x, y| x.reoriented && !y.reoriented }
  if oriented_scanner.nil?
    next_scanner, oriented_scanner = scanner_pairs.detect { |x, y| y.reoriented && !x.reoriented }
  end
  translation, offset = find_orientation(oriented_scanner, next_scanner)
  next_scanner.translation = translation
  next_scanner.offset = offset
  next_scanner.reorient!
end

puts scanners.flat_map(&:beacons).uniq.count

max_distance = 0

scanners.combination(2) do |scanner_1, scanner_2|
  offset_1 = scanner_1.offset
  offset_2 = scanner_2.offset

  manhattan_distance = [0, 1, 2].map do |index|
    (offset_1[index, 0] - offset_2[index, 0]).abs
  end.sum

  if manhattan_distance > max_distance
    max_distance = manhattan_distance
  end
end

puts max_distance