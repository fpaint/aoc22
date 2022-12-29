
defmodule Stack do
  defstruct items: []

  def push(stack, value) do
    put_in stack.items, [value | stack.items]
  end

  def pop(stack) do
    [x|rest] = stack.items
    stack = put_in stack.items, rest
    {x, stack}
  end

  def unshift(stack, value) do
    put_in stack.items, stack.items ++ [value]
  end

  def head(stack) do
    [x|_] = stack.items
    x
  end
end

defmodule Stacks do
  defstruct items: %{}

  def insert(stacks, num, value) do
    cond do
      value == '' ->
        stacks
      Map.has_key?(stacks.items, num) ->
        update_in(stacks.items, (fn items -> Map.put(items, num, Stack.unshift(items[num], value)); end))
      true ->
        update_in(stacks.items, (fn items -> Map.put(items, num, %Stack{items: [value]}); end))
    end
  end

  def move(stacks, from, count, to) when count > 0 do
    {value, stack} = Stack.pop(stacks.items[from])
    %Stacks{stacks | items: stacks.items
      |> Map.replace(from, stack)
      |> Map.update!(to, fn stack -> Stack.push(stack, value); end)
    }
      |> move(from, count-1, to)
  end
  def move(stacks, _, _, _), do: stacks

  def move9001(stacks, from, count, to) when count > 0 do
    {value, stack} = Stack.pop(stacks.items[from])
    stacks = %Stacks{stacks | items: stacks.items |> Map.replace(from, stack)} |> move9001(from, count-1, to)
    %Stacks{stacks | items: stacks.items |> Map.update!(to, fn stack -> Stack.push(stack, value); end)}
  end
  def move9001(stacks, _, _, _), do: stacks

  def insert_crates(stacks, [x | rest], num \\ 1) do
    cond do
      rest == [] -> insert(stacks, num, x)
      true -> insert_crates(insert(stacks, num, x), rest, num + 1)
    end
  end

  def result(stacks) do
    Enum.map(stacks.items, fn {_, stack} -> Stack.head(stack); end)
  end

  def proc_line(str, stacks) do
    cond do
      String.match?(str, ~r/\[[A-Z]\]/) ->
        crates = to_charlist(str) |> Enum.chunk_every(3, 4) |> Enum.map(fn x -> Enum.filter(x, fn c -> c not in '[ ]'; end); end)
        insert_crates stacks, crates
      String.match?(str, ~r/move (\d+) from (\d+) to (\d+)/) ->
        [_, count, from, to] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, str)
        move9001(stacks, String.to_integer(from), String.to_integer(count), String.to_integer(to))
      true -> stacks
    end
  end

  def read_file(filename) do
    File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Enum.reduce(%Stacks{}, &proc_line/2)
  end
end

stacks = Stacks.read_file('input05.txt')
IO.puts Stacks.result(stacks)
