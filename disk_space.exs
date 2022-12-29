
defmodule Tree.Node do
  defstruct [:id, :type, :name, :parent, size: :empty, nodes: []]
end

defmodule Tree do
  defstruct [count: 0, nodes: %{}]
  alias Tree.Node

  def new do
    %Tree{count: 1, nodes: %{0 => %Node{id: 0, type: :root, name: "/", parent: 0}}}
  end

  def add(tree, parent_id, tree_node) do
    id = tree.count
    nodes = tree.nodes
      |> Map.put(id, %Node{tree_node | id: id, parent: parent_id})
      |> Map.update!(parent_id, fn node -> Map.put(node, :nodes, [id | node.nodes]);end)
    %Tree{tree | count: id + 1, nodes: nodes}
  end

  def get(tree, node_id) do
    Map.fetch!(tree.nodes, node_id)
  end

  def get_child_id(tree, node_id, name) do
    node = tree |> get(node_id)
    Enum.find(node.nodes, nil, fn id -> tree.nodes[id].name == name;end)
  end

  def update(tree, node_id, proc) do
    %Tree{tree | nodes: Map.update!(tree.nodes, node_id, proc)}
  end
end

defmodule DiskSpace do
  def proc_data(stream) do
    stream
      |> Stream.map(&String.trim/1)
      |> Enum.reduce(%{tree: Tree.new, node_id: 0}, &proc_line/2)
      |> Map.fetch!(:tree)
      |> node_size
      |> elem(0)
  end

  def small_dirs(tree, limit \\ 100000) do
    Map.values(tree.nodes)
      |> Enum.filter(fn node -> node.type == :dir && node.size <= limit; end)
      |> Enum.map(fn node -> node.size; end)
  end

  def enought_to_delete(tree, limit \\ 8381165) do
    Map.values(tree.nodes)
      |> Enum.filter(fn node -> node.type == :dir && node.size >= limit; end)
      |> Enum.map(fn node -> node.size; end)
      |> Enum.min
  end

  def proc_line(str, ctx) do
    cond do
      String.match?(str, ~r/^\$ cd/) -> cd(str, ctx)
      String.match?(str, ~r/^dir /) -> dir(str, ctx)
      String.match?(str, ~r/^[\d]+ /) -> file(str, ctx)
      true -> ctx
    end
  end

  def cd(str, ctx) do
    [_, name] = Regex.run(~r/\$ cd ([\w\.\/]+)$/, str)
    IO.puts "cd #{name}"
    case name do
      "/" -> %{ctx | node_id: 0}
      ".." -> %{ctx | node_id: Tree.get(ctx.tree, ctx.node_id).parent}
      _ -> %{ctx | node_id: Tree.get_child_id(ctx.tree, ctx.node_id, name)}
    end
  end

  def dir(str, ctx) do
    [_, name] = Regex.run(~r/^dir ([\w\.]+)$/, str)
    IO.puts "add dir #{name}"
    %{ctx | tree: Tree.add(ctx.tree, ctx.node_id, %Tree.Node{type: :dir, name: name})}
  end

  def file(str, ctx) do
    [_, size, name] = Regex.run(~r/^([\d]+) ([\w\.]+)$/, str)
    IO.puts "add file #{name} #{size}"
    tree = Tree.add(ctx.tree, ctx.node_id, %Tree.Node{type: :file, name: name, size: String.to_integer(size)})
    %{ctx | tree: tree}
  end

  def node_size(tree, node_id \\ 0) do
    node = tree.nodes[node_id]
    fun = fn(id, acc) ->
      {tree, size} = node_size(elem(acc, 0), id)
      {tree, size + elem(acc, 1)}
    end
    case node do
      %{size: size} when size != :empty -> {tree, size}
      %{id: id, nodes: ids} ->
        {tree, size} = Enum.reduce(ids, {tree, 0}, fun)
        {Tree.update(tree, id, fn node -> %Tree.Node{node | size: size};end), size}
    end
  end

  def test do
    data = [
      "$ cd /",
      "$ ls",
      "dir blgtdv",
      "dir gsdsdg",
      "$ cd blgtdv",
      "$ ls",
      "10000 abc",
      "12345 bcd"
    ]
    Enum.reduce(data, %{tree: Tree.new, node_id: 0}, &proc_line/2)
      |> Map.fetch!(:tree)
      |> node_size
      |> elem(0)
      |> small_dirs
  end
end

DiskSpace.proc_data(File.stream!('input07.txt'))
  |> DiskSpace.enought_to_delete
  |> IO.puts

# IO.inspect DiskSpace.test
