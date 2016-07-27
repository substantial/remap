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

  @spec remap(Node.t, template) :: [any]
  def remap(data, template) when is_map(template) do
    for {key, value} <- template, into: %{}, do: {key, apply_template(value, data)}
  end

  def remap(data, template) when is_list(template) do
    for value <- template, do: apply_template(value, data)
  end

  def remap(data, template) do
    apply_template(template, data)
  end

  defp apply_template({:remap_path, :list, path}, data) do
    follow_path(path, data, data)
  end

  defp apply_template({:remap_path, :element, path}, data) do
    result = follow_path(path, data, data)
    Enum.at(result, 0)
  end

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
