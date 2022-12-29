defmodule Tuning do

  def uniq?([x|xs]) do
    x not in xs and uniq?(xs)
  end
  def uniq?([]) do true; end

  def read_file(filename) do
    p = File.stream!(filename, [], 1)
      |> Stream.chunk_every(14, 1)
      |> Enum.find_index(&uniq?/1)
    p + 14
  end
end

IO.inspect Tuning.read_file('input06.txt')