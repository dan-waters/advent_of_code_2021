require_relative 'numbers'

def reduce(snail_number)
  loop do
    snail_number, exploded = explode(snail_number)
    next if exploded

    snail_number, has_split = split(snail_number)
    next if has_split

    return snail_number unless (exploded || has_split)
  end
end

def explode(snail_number, level = 0)
  # if we're dealing with a pair nested 4 levels deep, explode it!
  # remember to cache the exploded values for later
  if level == 4 && snail_number.is_a?(Array)
    @left, @right = snail_number
    return 0, true
  end

  # otherwise recurse through the pairs and try and find one that matches
  if snail_number.is_a?(Array)
    snail_number.each_with_index do |num, index|
      # check if it explodes, and if it does,
      # - get the replacement for the exploded element
      # - get the values we need to add elsewhere
      # if it doesn't, move on!
      new_element, exploded = explode(num, level + 1)
      next unless exploded

      # copy and replace the exploded part
      new_number = snail_number.dup
      new_number[index] = new_element

      # each level up the stack we go, we check to see if both
      # - we are on the right of a pair (or, "is there an element to the left of us?")
      # - we have not yet dealt with the left value for the exploded pair
      if index == 1 && @left
        new_number[0] = add_number_to_next_number_on_the_left(new_number[0], @left)
        # we have dealt with it now, we can ignore it
        @left = nil
      end

      # and similarly for the right
      if index == 0 && @right
        new_number[1] = add_number_to_next_number_on_the_right(new_number[1], @right)
        @right = nil
      end
      return new_number, true
    end
  end

  # if no explosion necessary, just move on
  return snail_number, false
end

def split(snail_number)
  # if we need to split, let's split!
  if snail_number.is_a?(Numeric) && snail_number > 9
    return [(snail_number / 2.0).floor, (snail_number / 2.0).ceil], true
  end

  # otherwise, let's recurse!
  if snail_number.is_a?(Array)
    snail_number.each_with_index do |num, index|
      # check if it needs to split, and if not, move on!
      new_element, has_split = split(num)
      next unless has_split

      # copy and replace the split part
      new_number = snail_number.dup
      new_number[index] = new_element
      return new_number, true
    end
  end

  # if no split necessary, just move on
  return snail_number, false
end

def add_number_to_next_number_on_the_left(snail_number, value)
  if snail_number.is_a?(Array)
    [snail_number[0], add_number_to_next_number_on_the_left(snail_number[1], value)]
  else
    snail_number + value
  end
end

def add_number_to_next_number_on_the_right(snail_number, value)
  if snail_number.is_a?(Array)
    [add_number_to_next_number_on_the_right(snail_number[0], value), snail_number[1]]
  else
    snail_number + value
  end
end

def magnitude(snail_number)
  left_mag = snail_number[0].is_a?(Array) ? magnitude(snail_number[0]) : snail_number[0]
  right_mag = snail_number[1].is_a?(Array) ? magnitude(snail_number[1]) : snail_number[1]
  3 * left_mag + 2 * right_mag
end

puts magnitude(NUMBERS.reduce { |sum, n| reduce([sum, n]) })

puts(NUMBERS.permutation(2).map do |pair|
  magnitude(reduce(pair))
end.max)