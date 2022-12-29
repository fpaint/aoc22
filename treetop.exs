defmodule Treetop do
  def proc_stream(stream) do
    proc_line = fn str -> str
      |> String.trim
      |> String.to_charlist
      |> Enum.map(fn c -> String.to_integer(List.to_string([c]));end);
    end
    stream
      |> Stream.map(proc_line)
      |> Enum.to_list
  end

# auxilary
  def matrix_op(m1, m2, fun) do
    Enum.zip_with(m1, m2, fn l1, l2 -> Enum.zip_with(l1, l2, fun); end)
  end

  def transpose(matrix) do
    Enum.zip_reduce(matrix, [], fn l, acc -> [l | acc]; end) |> Enum.reverse
  end

  def map_with_rest([x|xs], fun) do
    [fun.(x, xs) | map_with_rest(xs, fun)]
  end
  def map_with_rest([], _), do: []

  def two_ways_proc(list, proc_fun, zip_fun) do
    forward = proc_fun.(list)
    backward = list |> Enum.reverse |> proc_fun.() |> Enum.reverse
    Enum.zip_with(forward, backward, zip_fun)
  end

  def matix_proc(matrix, proc_fun, zip_fun) do
    map_proc = fn l -> two_ways_proc(l, proc_fun, zip_fun); end
    horizontal = Enum.map(matrix, map_proc)
    vertical = Enum.map(transpose(matrix), map_proc) |> transpose
    matrix_op(horizontal, vertical, zip_fun)
  end

# first part
  def min_heights(list) do
    Enum.reduce(list, {[], -1}, fn(x, {l, m}) -> {[m | l], Enum.max([m, x])};end) |> elem(0) |> Enum.reverse
  end

  def count_visible(matrix) do
    heights = matix_proc(matrix, &min_heights/1, fn a, b -> Enum.min([a, b]);end)
    visibility_map = matrix_op(matrix, heights, fn
      m, h when m > h -> 1
      _, _ -> 0
    end)
    visibility_map |> Enum.map(&Enum.sum/1) |> Enum.sum
  end

# second part
  def distance(base, [x|xs]) do
    cond do
      x >= base -> 1
      x < base -> 1 + distance(base, xs)
      true -> 0
    end
  end
  def distance(_, []), do: 0

  def one_way_distance(list) do
    map_with_rest(list, fn x, xs -> distance(x, xs); end)
  end

  def best_place_visibility(matrix) do
    matrix
      |> matix_proc(&one_way_distance/1, fn a, b -> a * b;end)
      |> Enum.map(&Enum.max/1)
      |> Enum.max
  end

# sandbox
  def test do
    matrix = [[3, 0, 3, 7, 3],
              [2, 5, 5, 1, 2],
              [6, 5, 3, 3, 2],
              [3, 3, 5, 4, 9],
              [3, 5, 3, 9, 0]]
    IO.inspect best_place_visibility(matrix)
  end
end

matrix = File.stream!('input08.txt') |> Treetop.proc_stream
IO.inspect(Treetop.count_visible(matrix))
IO.inspect(Treetop.best_place_visibility(matrix))

# Treetop.test
