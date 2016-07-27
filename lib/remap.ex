defmodule Remap do
  alias Remap.Node

  @type path :: [step]
  @type member :: {:identifier, atom}
    | :wildcard
  @type step :: :root
    | {:child, member}
    | {:descendant, member}
  @type modifier :: ?s | ?l
  @type template :: %{} | [any] | path

  @spec remap(Node.t, template) :: any
  def remap(data, template) do
    do_remap(data, template, data)
  end

  @spec do_remap(Node.t, template, Node.t) :: any
  def do_remap(data, template, root) when is_map(template) do
    for {key, child_template} <- Map.to_list(template), into: %{}  do
      {key, apply_template(data, child_template, root)}
    end
  end

  def do_remap(data, template, root) when is_list(template) do
    for child_template <- template, do: apply_template(data, child_template, root)
  end

  def do_remap(data, template, root) do
    apply_template(data, template, root)
  end

  defp apply_template(data, {:remap_path, :list, path}, root) do
    follow_path(path, data, root)
  end

  defp apply_template(data, {:remap_path, :element, path}, root) do
    result = follow_path(path, data, root)
    Enum.at(result, 0)
  end

  defp apply_template(data, {{:remap_path, :list, path}, template}, root) do
    results = follow_path(path, data, root)
    for result <- results do
      do_remap(result, template, root)
    end
  end

  defp apply_template(data, template, root) when is_list(template) or is_map(template) do
    do_remap(data, template, root)
  end

  defp apply_template(_data, template, _root), do: template

  @spec follow_path(path, Node.t, Node.t) :: any
  defp follow_path([], _root, current), do: [current]
  defp follow_path([:root | rest], root, _current) do
    follow_path(rest, root, root)
  end

  defp follow_path([{:child, member} | rest], root, current) do
    children = Node.get_members(current, member)
    Enum.flat_map(children, &follow_path(rest, root, &1))
  end

  defp follow_path([{:descendant, member} | rest], root, current) do
    children = traverse(current, member)
    Enum.flat_map(children, &follow_path(rest, root, &1))
  end

  # defp follow_path([{:subscript, subscript} | rest]) do
  #   Enum.flat_map(current, &)
  # end

  @spec traverse(Node.t, member) :: [any]
  defp traverse(data, member) do
    Node.get_members(data, member) ++
      Enum.flat_map(Node.get_children(data), &traverse(&1, member))
  end

  defmacro sigil_p({:<<>>, _, [term]}, modifiers) do
    path =
      term
      |> Remap.Parser.parse
      |> apply_modifiers(modifiers)

    destination =
      if Enum.member?(modifiers, ?l) do
        :list
      else
        :element
      end

    quote do
      {:remap_path, unquote(destination), unquote(path)}
    end
  end

  @spec apply_modifiers(path, [modifier]) :: path
  defp apply_modifiers(path, []), do: path

  defp apply_modifiers(path, [?s | modifiers]) do
    path
    |> Enum.map(&stringify_keys/1)
    |> apply_modifiers(modifiers)
  end

  defp apply_modifiers(path, [_ | modifiers]), do: apply_modifiers(path, modifiers)

  @spec stringify_keys(step) :: step
  defp stringify_keys({relation, {:identifier, key}}) do
    {relation, {:identifier, Atom.to_string(key)}}
  end

  defp stringify_keys(step), do: step
end
