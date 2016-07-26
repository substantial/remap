defmodule Remap.Parser do
  @spec parse(String.t) :: Remap.path
  def parse(str) do
    {:ok, tokens, _} =
      str
      |> to_char_list
      |> :remap_lexer.string

    {:ok, path} = :remap_parser.parse(tokens)
    path
  end
end
