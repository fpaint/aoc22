
defmodule Cleanup do

  def parse_ranges str do
    to_range = fn x -> x |> String.split("-") |> Enum.map(&String.to_integer/1); end
    str |> String.trim |> String.split(",") |> Enum.map(to_range)
  end

  def in_range x, [a, b] do
    a <= x and x <= b
  end

  def range_inside_of [a, b], range do
    (in_range(a, range) && in_range(b, range))
  end

  def range_overlap [a, b], range do
    (in_range(a, range) || in_range(b, range))
  end

  def check_ranges [range_a, range_b] do
    # match = range_inside_of(range_a, range_b) || range_inside_of(range_b, range_a)
    match = range_overlap(range_a, range_b) || range_overlap(range_b, range_a)
    if match, do: 1, else: 0
  end

  def read_file(filename) do
    list = File.stream!(filename)
      |> Stream.map(&parse_ranges/1)
      |> Stream.map(&check_ranges/1)
    Enum.sum(list)
  end
end

IO.inspect(Cleanup.read_file 'input04.txt')
