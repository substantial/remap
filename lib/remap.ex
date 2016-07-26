defmodule Remap do
  @type instruction :: :root
    | {:key, String.t}
    | {:children, :all}

  def remap(data, map) do
    for {key, value} <- map, into: %{}, do: {key, apply_mapping(value, data)}
  end

  def apply_mapping({:remap, instructions}, data) do
    do_instructions(instructions, data, data)
  end

  @spec do_instructions([instruction], any, any) :: any
  def do_instructions([], _root, current), do: current
  def do_instructions([:root | rest], root, _current) do
    do_instructions(rest, root, root)
  end

  def do_instructions([{:key, key} | rest], root, current) do
    do_instructions(rest, root, Access.get(current, key))
  end

  def do_instructions([{:children, :all} | rest], root, current) do
    for child <- current do
      do_instructions(rest, root, child)
    end
  end

  @spec sigil_m(String.t, []) :: {:remap, [instruction]}
  def sigil_m(term, _modifiers) do
    {:ok, tokens, _} =
      term
      |> String.to_charlist
      |> :remap_lexer.string

    {:remap, tokens}
  end
end
