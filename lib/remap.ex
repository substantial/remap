defmodule Remap do
  @type path :: [step]
  @type step :: :root
    | {:member, String.t}
    | {:children, :all}

  def remap(data, map) do
    for {key, value} <- map, into: %{}, do: {key, apply_mapping(value, data)}
  end

  def apply_mapping({:remap, path}, data) do
    follow_path(path, data, data)
  end

  @spec follow_path(path, any, any) :: any
  def follow_path([], _root, current), do: current
  def follow_path([:root | rest], root, _current) do
    follow_path(rest, root, root)
  end

  def follow_path([{:member, key} | rest], root, current) do
    follow_path(rest, root, Access.get(current, key))
  end

  def follow_path([{:children, :all} | rest], root, current) do
    for child <- current do
      follow_path(rest, root, child)
    end
  end

  @spec sigil_p(String.t, []) :: {:remap, path}
  defmacro sigil_p({:<<>>, _, [term]}, modifiers) do
    path =
      term
      |> Remap.Parser.parse
      |> apply_modifiers(modifiers)

    quote do
      {:remap, unquote(path)}
    end
  end

  defp apply_modifiers(path, _modifiers) do
    path
  end
end
