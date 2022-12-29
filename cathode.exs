defmodule Cathode do
  def cycles(cmd_list, x \\ 1)
  def cycles([cmd | rest], x) do
    case cmd do
      {:noop, _} -> [x | cycles(rest, x)]
      {:addx, [count]} -> [x, x | cycles(rest, x + count)]
    end
  end
  def cycles([], _), do: []

  def selected_points(cycles, num, count) do
    cond do
      Enum.count(cycles) > count ->
        [x | rest] = Enum.drop(cycles, count - 1)
        [{x, num + count} | selected_points(rest, num + count, 40)]
      true -> []
    end
  end

  def signal_strength(data) do
    data
      |> Cathode.cycles
      |> Cathode.selected_points(0, 20)
      |> Enum.map(fn {x, step} -> x*step; end)
      |> Enum.sum
  end

  def final_picture(data) do
    data
      |> Cathode.cycles
      |> Enum.chunk_every(40)
      |> Enum.map(&one_row/1)
  end

  def one_row(line) do
    fun = fn {x, step}
      when step >= x-1 and step <= x+1 -> ?#
      _ -> ?.
    end
    line
      |> Enum.with_index
      |> Enum.map(fun)
  end

  def parsed_input(stream) do
    stream |> Enum.map(&parsed_line/1)
  end

  def parsed_line(str) do
    regs = %{
      addx: ~r/^addx (-?[\d]+)/,
      noop: ~r/^noop/
    }
    key = Enum.find(Map.keys(regs), nil, fn key -> String.match?(str, regs[key]); end)
    if !key, do: raise "Bad string #{str}"
    {key, Regex.run(regs[key], str) |> Enum.drop(1) |> Enum.map(&String.to_integer/1)}
  end

  def test do
    ["noop", "addx 3", "addx -5"]
      |> parsed_input
      |> cycles
  end
end

data = File.stream!("input10.txt")
  |> Stream.map(&String.trim/1)
  |> Cathode.parsed_input

IO.puts Cathode.signal_strength(data)
Enum.map Cathode.final_picture(data), &IO.puts/1

# IO.inspect Cathode.test