
defmodule Rucksack do

  def count_dups str do
    {a, b} = str |> to_charlist |> Enum.split(round(String.length(str)/2))
    dups(a, b) |> Enum.map(&prioriry/1) |> Enum.sum
  end

  def dups(a, b) do
    Enum.filter(a, (fn x -> x in b; end)) |> Enum.uniq
  end

  def prioriry(c) do
    case c do
      c when (?a <= c and c <= ?z) -> (c - ?a + 1)
      c when (?A <= c and c <= ?Z) -> (c - ?A + 27)
    end
  end

  def badge a, b, c do
    Enum.filter(a, (fn x -> x in b and x in c; end)) |> Enum.uniq
  end

  def count_badges(list) do
    [a, b, c] = list
    badge(a, b, c) |> Enum.map(&prioriry/1) |> Enum.sum
  end

  def read_file_first filename do
    list = File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&count_dups/1)
    Enum.sum list
  end

  def read_file_second filename do
    list = File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&to_charlist/1)
      |> Stream.chunk_every(3)
      |> Stream.map(&count_badges/1)
    Enum.sum list
  end
end

IO.puts(Rucksack.read_file_second 'input03.txt')

