class DeterministicDie
  attr_reader :rolls

  def initialize(sides = 100)
    @value = 1
    @sides = sides
    @rolls = 0
    @die = Enumerator.new do |enum|
      loop do
        @rolls += 1
        value = @value
        @value += 1
        if @value > @sides
          @value = @value % @sides
        end
        enum.yield value
      end
    end
  end

  def roll!(n = 1)
    @die.take(n)
  end
end

class Player
  attr_reader :score

  def initialize(number, starting_position)
    @number = number
    @position = starting_position
    @score = 0
  end

  def move!(roll_total)
    @position = ((@position + roll_total - 1) % 10) + 1
    @score += @position
    @position
  end

  def number
    @number
  end
end

die = DeterministicDie.new(100)

player1 = Player.new(1, 8)
player2 = Player.new(2, 5)

@current_player = player1
@next_player = player2

loop do
  total = die.roll!(3).sum
  @current_player.move!(total)
  break if @current_player.score >= 1000

  next_player = @next_player
  @next_player = @current_player
  @current_player = next_player
end

puts die.rolls * @next_player.score

player1 = Player.new(1, 8)
player2 = Player.new(2, 5)

ongoing_games = [{ players: { current_player: player1, next_player: player2 }, count: 1 }]
wins = { player1.number => 0, player2.number => 0 }

frequencies = Hash.new(0)
[1, 2, 3].each do |roll1|
  [1, 2, 3].each do |roll2|
    [1, 2, 3].each do |roll3|
      sum = roll1 +roll2 + roll3
      frequencies[sum] += 1
    end
  end
end

while ongoing_games.any?
  new_games = []
  ongoing_games.each do |game|
    frequencies.each do |total, frequency|
      current_player = game[:players][:current_player].dup
      next_player = game[:players][:next_player].dup
      current_player.move!(total)
      if current_player.score >= 21
        wins[current_player.number] += game[:count] * frequency
      else
        new_games << {players: { current_player: next_player, next_player: current_player }, count: game[:count] * frequency}
      end
    end
  end
  ongoing_games = new_games
end

puts wins