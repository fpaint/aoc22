defmodule Knot do
  defstruct [x: 0, y: 0]

  def new(x, y), do: %Knot{x: x, y: y}
  def new([x, y]), do: %Knot{x: x, y: y}

  def op(knot, fun), do: new(fun.(knot.x), fun.(knot.y))

  def bop(a, %Knot{x: x, y: y}, fun), do: new(fun.(a.x, x), fun.(a.y, y))
  def bop(a, [x, y], fun), do: new(fun.(a.x, x), fun.(a.y, y))

  def move(knot, delta), do: bop(knot, delta, &(&1 + &2))

  def delta(knot, other_knot), do: bop(knot, other_knot, &(&1 - &2))

  def absolute(knot), do: op(knot, &abs/1)

  def sign(knot) do
    fun = fn
      x when x >= 0 -> 1
      x when x < 0 -> -1
    end
    op(knot, fun)
  end

  def follow(knot, head) do
    move(knot, direction(delta(knot, head)))
  end

  def direction(delta) do
    %{x: x, y: y} = absolute(delta)
    move = cond do
      x <= 1 and y <= 1 -> %Knot{x: 0, y: 0}
      x == 2 and y <= 1 -> %Knot{x: -1, y: -y}
      x <= 1 and y == 2 -> %Knot{x: -x, y: -1}
      x == 2 and y == 2 -> %Knot{x: -1, y: -1}
      true -> raise "Bad delta [#{x}, #{y}]"
    end
    bop(move, sign(delta), &(&1 * &2))
  end
end

defmodule Rope do
  def proc_stream(stream) do
    stream
      |> Stream.map(&parse_move/1)
      |> Enum.to_list
      |> build_path(Knot.new(0, 0))
  end

  def two_knots(head_path) do
    head_path
      |> follow(Knot.new(0, 0))
      |> Enum.uniq
      |> Enum.count
  end

  def ten_knots(head_path) do
    Enum.reduce(1..9, head_path, fn _, path -> follow(path, Knot.new(0, 0));end)
      |> Enum.uniq
      |> Enum.count
  end

  def parse_move(str) do
    [_, dir, count] = Regex.run(~r/^([ULDR]) ([\d]+)/, str)
    delta = case dir do
      "U" -> [0, 1]
      "D" -> [0, -1]
      "R" -> [1, 0]
      "L" -> [-1, 0]
    end
    {delta, String.to_integer(count)}
  end

  def build_path([{delta, count} | rest], position) do
    cond do
      count > 1 -> [position | build_path([{delta, count - 1} | rest], Knot.move(position, delta))]
      count == 1 -> [position | build_path(rest, Knot.move(position, delta))]
    end
  end
  def build_path([], position), do: [position]

  def follow([current | path], position) do
    new_position = Knot.follow(position, current)
    [new_position | follow(path, new_position)]
  end
  def follow([], position), do: []

  def test do
    path = ["R 5", "U 8", "L 8", "D 3", "R 17", "D 10", "L 25", "U 20"]
      |> Enum.map(&parse_move/1)
      |> build_path(Knot.new(0, 0))
    ten_knots(path)
  end
end

data = File.stream!("input09.txt") |> Stream.map(&String.trim/1)
head_path = Rope.proc_stream(data)

IO.puts Rope.two_knots(head_path)
IO.puts Rope.ten_knots(head_path)

# IO.puts Rope.test
