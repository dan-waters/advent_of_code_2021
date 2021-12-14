require 'open-uri'

Dot = Struct.new(:x, :y)

dots = open('dots.txt').readlines(chomp: true).map do |dot|
  x, y = dot.split(',').map(&:to_i)
  Dot.new(x, y)
end

Fold = Struct.new(:axis, :value)

folds = open('folds.txt').readlines(chomp: true).map do |fold|
  axis, value = fold.split('=')
  Fold.new(axis, value.to_i)
end

# part 1

def fold_paper(fold, dots)
  new_dots = []

  dots.each do |dot|
    case fold.axis
    when 'x'
      if dot.x > fold.value
        new_dots << Dot.new(fold.value * 2 - dot.x, dot.y)
      else
        new_dots << dot
      end
    when 'y'
      if dot.y > fold.value
        new_dots << Dot.new(dot.x, fold.value * 2 - dot.y)
      else
        new_dots << dot
      end
    else
      puts 'o no'
    end
  end

  new_dots.uniq
end

puts fold_paper(folds.first, dots).count

# part 2

folds.each do |fold|
  dots = fold_paper(fold, dots)
end

max_x = dots.map(&:x).max
max_y = dots.map(&:y).max

(0..max_y).each do |y|
  line = (0..max_x).map do |x|
    dots.include?(Dot.new(x, y)) ? '@' : ' '
  end.join
  puts line
end