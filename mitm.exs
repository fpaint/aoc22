# Monkey in the middle
# Keeps singing that tune
# I don't want to hear it
# Get rid of it soon

defmodule Monkey do
  defstruct [items: [], operation: "", divisor: 2, toss_true: 0, toss_false: 0, score: 0]

  @regs %{
    items: {~r/Starting items: ([\d, ]+)/, &Monkey.str_to_ints/1},
    operation: {~r/Operation: (.+)/, &Monkey.noop/1},
    divisor: {~r/Test: divisible by ([\d]+)/, &String.to_integer/1},
    toss_true: {~r/If true: throw to monkey ([\d]+)/, &String.to_integer/1},
    toss_false: {~r/If false: throw to monkey ([\d]+)/, &String.to_integer/1}
  }
  def noop(a), do: a
  def str_to_ints(str), do: str |> String.split(", ") |> Enum.map(&String.to_integer/1)

  def from_input([str | rest]) do
    [_, id] = Regex.run(~r/Monkey ([\d]+):/, str)
    data = Enum.reduce(rest, %{}, fn str, acc ->
      key = Enum.find(Map.keys(@regs), nil, fn key -> String.match?(str, elem(@regs[key], 0)); end)
      if !key, do: raise "Bad string #{str}"
      {reg, op} = @regs[key]
      value = Regex.run(reg, str) |> Enum.at(1) |> op.()
      Map.put(acc, key, value)
    end)
    {String.to_integer(id), struct(Monkey, data)}
  end

  def new_value(old_value, operation) do
    {result, _} = Code.eval_string(operation, [old: old_value])
    result
  end

  def turn(monkey, worry_fun) do
    tosses = Enum.map(monkey.items, fn item ->
      worry = item |> new_value(monkey.operation) |> worry_fun.()
      cond do
        rem(worry, monkey.divisor) == 0 -> {worry, monkey.toss_true}
        true -> {worry, monkey.toss_false}
      end
    end)
    {%Monkey{monkey | items: [], score: monkey.score + Enum.count(monkey.items)}, tosses}
  end

  def simple_turn(monkey) do
    turn(monkey, fn worry -> div(worry, 3); end)
  end
end

defmodule Mitm do
  def read_monkeys(filename) do
    File.stream!(filename)
      |> Enum.map(&String.trim/1)
      |> Enum.chunk_every(7)
      |> Enum.map(fn m -> Enum.reject(m, fn s -> s=="";end); end)
      |> Enum.map(&Monkey.from_input/1)
      |> Enum.into(%{})
  end

  def div3(worry), do: div(worry, 3)
  def modulo(worry, lcm), do: rem(worry, lcm)
  def lcm(monkeys) do
    monkeys
      |> Map.values
      |> Enum.map(&(&1.divisor))
      |> Enum.product
  end

  def turn_and_toss(id, monkeys, worry_fun) do
    {monkey, tosses} = Monkey.turn(monkeys[id], worry_fun)
    Enum.reduce(tosses, Map.put(monkeys, id, monkey), fn {item, new_id}, ms ->
      Map.update!(ms, new_id, fn m -> %Monkey{m | items: m.items ++ [item]}; end)
    end)
  end

  def one_round(monkeys, worry_fun) do
    Map.keys(monkeys) |> Enum.reduce(monkeys, fn id, m -> turn_and_toss(id, m, worry_fun); end)
  end

  def most_active_after_rounds(monkeys, count, worry_fun) do
    Enum.reduce(1..count, monkeys, fn _, ms -> one_round(ms, worry_fun); end)
      |> Map.values
      |> Enum.map(&(&1.score))
      |> Enum.sort(:desc)
      |> Enum.take(2)
      |> Enum.product
  end

  def twenty_rounds(monkeys) do
    most_active_after_rounds(monkeys, 20, &div3/1)
  end

  def ten_thousand_rounds(monkeys) do
    most_active_after_rounds(monkeys, 10000, fn worry -> modulo(worry, lcm(monkeys));end)
  end

  def test do
    monkeys = Mitm.read_monkeys("test_input11.txt")
    ten_thousand_rounds(monkeys)
  end
end

monkeys = Mitm.read_monkeys("input11.txt")
IO.puts Mitm.twenty_rounds(monkeys)
IO.puts Mitm.ten_thousand_rounds(monkeys)

# IO.inspect Mitm.test, charlists: :as_lists
