
defmodule ElfFood do
  def read_file filename do
    list = File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_by(fn v -> v == ""; end)
      |> Stream.filter(fn l -> l != [""]; end)
      |> Stream.map(fn l -> Enum.sum(Enum.map(l, &String.to_integer/1)); end)
    IO.inspect(Enum.sort(list, :desc) |> Enum.take(3) |> Enum.sum)
  end
end

ElfFood.read_file 'input01.txt'
