require 'byebug'
class Board
  def initialize(size)
    @grid = Array.new(size) { Array.new(size) }
  end

  def [](row,col)
    @grid[row][col]
  end

  def all_safe_pos
    all_pos.reject { |row,col| self[row,col] || unsafe?(row,col) }
  end

  def place_queens(positions)
    positions.each { |(row,col)| self[row,col] = true }
  end

  def place_queen(row,col)
    self[row,col] = true
  end

  def count
    all_pos.count { |row,col| self[row,col] }
  end

  def size
    @grid.size
  end

  def populate(count) # for testing
    place_queens(all_pos.shuffle.take(count))
  end

  def render
    puts '  ' + (0...size).to_a.join('  ')
    @grid.each.with_index do |row,i|
      puts "#{i} #{row.map{|el| el ? 'X' : '_'}.join('  ')}"
    end
  end

  def valid?
    all_pos.none? do |row,col|
      self[row,col] && unsafe?(row,col)
    end
  end

  private
  def unsafe?(row,col)
    share_row?(row,col) || share_col?(row,col) || share_diag?(row,col)
  end

  def []=(row,col,val)
    @grid[row][col] = val
  end

  def share_row?(row,col)
    (0...size).any? do |other_col|
      self[row,other_col] && col != other_col
    end
  end

  def share_col?(row,col)
    (0...size).any? do |other_row|
      self[other_row,col] && row != other_row
    end
  end

  def share_diag?(row,col)
    get_diags(row,col).any? { |diag| self[*diag] && diag != [row,col] }
  end

  def get_diags(row,col)
    all_pos.select do |new_row, new_col|
      (row - new_row).abs == (col - new_col).abs
    end
  end

  def in_range?(row,col)
    (0...size).include?(row) && (0...size).include?(col)
  end

  def all_pos
    indices = (0...size).to_a
    indices.product(indices)
  end
end

class QueensSolver
  def initialize(size = 8, queens_count = size)
    if queens_count > size
      raise Exception.new("can't have more queens than board size")
    end

    @queens_count = queens_count
    @size = size
    @solution = solve
    render_solution
  end

  def render_solution
    if @solution
      board = Board.new(@size)
      board.place_queens(@solution)
      board.render
      print "positions: "
      @solution.sort.each.with_index do
        |pos,i| i == @solution.size - 1 ? (print pos) : (print "#{pos}, ")
      end
    else
      puts "no solution found"
    end
  end

  def solve(queen_pos = [])
    board = Board.new(@size)
    board.place_queens(queen_pos)
    return queen_pos if board_won?(board)
    return nil if board.all_safe_pos.empty?

    board.all_safe_pos.shuffle.each do |next_pos|
      next_queen_pos = queen_pos + [next_pos]
      next_solve = solve(next_queen_pos)
      return next_solve if next_solve
    end
    nil
  end

  def board_won?(board)
    board.count >= @queens_count && board.valid?
  end
end

if __FILE__ == $0
  print "specify board size > "
  input = gets.chomp
  input.empty? ? size = 8 : size = input.to_i

  if size > 11
    puts "boards larger than 10 may take a really long time"
  else
    QueensSolver.new(size)
  end
end
