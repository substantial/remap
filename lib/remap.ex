defmodule Remap do
  @type path :: [step]
  @type member :: {:identifier, atom}
  @type step :: :root
    | {:child, member}
    | {:descendant, member}
    | {:children, :all}
  @type modifier :: ?s | ?l
  @type modifiers :: [modifier]

  def remap(data, map) do
    for {key, value} <- map, into: %{}, do: {key, apply_mapping(value, data)}
  end

  def apply_mapping({:remap_path, :list, path}, data) do
    follow_path(path, data, data)
  end

  def apply_mapping({:remap_path, :element, path}, data) do
    result = follow_path(path, data, data)
    Enum.at(result, 0)
  end

  @spec follow_path(path, any, any) :: any
  defp follow_path([], _root, current), do: [current]
  defp follow_path([:root | rest], root, _current) do
    follow_path(rest, root, root)
  end

  defp follow_path([{:child, member} | rest], root, current) do
    children = get_members(current, member)
    Enum.flat_map(children, &follow_path(rest, root, &1))
  end

  defp follow_path([{:descendant, member} | rest], root, current) do
    children = traverse(current, member)
    Enum.flat_map(children, &follow_path(rest, root, &1))
  end

  defp follow_path([{:children, :all} | rest], root, current) do
    Enum.flat_map(current, &follow_path(rest, root, &1))
  end

  @spec get_members(any, member) :: any
  defp get_members(data, {:identifier, key}) when is_map(data) do
    if Map.has_key?(data, key) do
      [Map.get(data, key)]
    else
      []
    end
  end

  defp get_members(_data, {:identifier, _key}), do: []

  @spec traverse(any, member) :: [any]
  defp traverse(data, member) when is_map(data) do
    get_members(data, member) ++
      Enum.flat_map(data, fn {_key, value} -> traverse(value, member) end)
  end

  defp traverse(data, member) when is_list(data) do
    get_members(data, member) ++
      Enum.flat_map(data, fn value -> traverse(value, member) end)
  end

  defp traverse(_data, _member), do: []

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

  @spec apply_modifiers(path, modifiers) :: path
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
