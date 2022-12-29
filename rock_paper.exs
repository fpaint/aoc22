# A - rock X=1+3 Y=2+6 Z=3+0
# B - paper X=1+0 Y=2+3 Z=3+6
# C - scissors X=1+6 Y=2+0 Z=3+3

# X - loose
# Y - draw
# Z - win

# A - rock X=0+3 Y=3+1 Z=6+2
# B - paper X=0+1 Y=3+2 Z=6+3
# C - scissors X=0+2 Y=3+3 Z=6+1

defmodule RockPaper do
  def proc_line str do
    case str |> String.trim |> String.split(" ") do
      ["A", "X"] -> 4
      ["A", "Y"] -> 8
      ["A", "Z"] -> 3
      ["B", "X"] -> 1
      ["B", "Y"] -> 5
      ["B", "Z"] -> 9
      ["C", "X"] -> 7
      ["C", "Y"] -> 2
      ["C", "Z"] -> 6
      _ -> 0
    end
  end

  def proc_line_2 str do
    case str |> String.trim |> String.split(" ") do
      ["A", "X"] -> 3
      ["A", "Y"] -> 4
      ["A", "Z"] -> 8
      ["B", "X"] -> 1
      ["B", "Y"] -> 5
      ["B", "Z"] -> 9
      ["C", "X"] -> 2
      ["C", "Y"] -> 6
      ["C", "Z"] -> 7
      _ -> 0
    end
  end

  def read_file filename do
    list = File.stream!(filename)
      |> Stream.map(&proc_line_2/1)
    Enum.sum list
  end
end

IO.puts(RockPaper.read_file 'input02.txt')
