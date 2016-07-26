defmodule Remap.ParserTest do
  use ExUnit.Case, async: true
  alias Remap.Parser

  test "parse key only" do
    assert Parser.parse("foo") == [{:key, "foo"}]
  end

  test "parse multiple keys" do
    assert Parser.parse("foo.bar.baz") ==
      [{:key, "foo"}, {:key, "bar"}, {:key, "baz"}]
  end

  test "start with root" do
    assert Parser.parse("$.foo") ==
      [:root, {:key, "foo"}]
  end

  test "all children" do
    assert Parser.parse("foo[*]") ==
      [{:key, "foo"}, {:children, :all}]
  end
end
