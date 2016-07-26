defmodule Remap.Parser do
  @spec parse(String.t) :: [Remap.instruction]
  def parse(str) do
    {:ok, tokens, _} =
      str
      |> to_char_list
      |> :remap_lexer.string

    {:ok, instructions} = :remap_parser.parse(tokens)
    instructions
  end
end
