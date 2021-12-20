require 'matrix'

permutations = [
  Matrix.rows([[1, 0, 0],
               [0, 1, 0],
               [0, 0, 1]]),
  Matrix.rows([[0, 1, 0],
               [0, 0, 1],
               [1, 0, 0]]),
  Matrix.rows([[0, 0, 1],
               [1, 0, 0],
               [0, 1, 0]])
]

flips = [
  Matrix.rows([[1, 0, 0],
               [0, 1, 0],
               [0, 0, 1]]),
  Matrix.rows([[-1, 0, 0],
               [0, -1, 0],
               [0, 0, 1]]),
  Matrix.rows([[-1, 0, 0],
               [0, 1, 0],
               [0, 0, -1]]),
  Matrix.rows([[1, 0, 0],
               [0, -1, 0],
               [0, 0, -1]])
]

determinants = [
  Matrix.rows([[1, 0, 0],
               [0, 1, 0],
               [0, 0, 1]]),

  Matrix.rows([[0, 0, -1],
               [0, -1, 0],
               [-1, 0, 0]])
]

MATRICES = []
permutations.each do |permutation|
  flips.each do |flip|
    determinants.each do |determinant|
      MATRICES << permutation * flip * determinant
    end
  end
end