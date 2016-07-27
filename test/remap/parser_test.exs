defmodule Remap.ParserTest do
  use ExUnit.Case, async: true
  alias Remap.Parser

  test "parse key only" do
    assert Parser.parse("foo") == [{:child, {:identifier, :foo}}]
  end

  test "parse multiple keys" do
    assert Parser.parse("foo.bar.baz") ==
      [
        {:child, {:identifier, :foo}},
        {:child, {:identifier, :bar}},
        {:child, {:identifier, :baz}},
      ]
  end

  test "start with root" do
    assert Parser.parse("$.foo") ==
      [:root, {:child, {:identifier, :foo}}]
  end

  describe "subscript ([])" do
    test "descendant wildcard" do
      assert Parser.parse("..[*]") ==
        [{:descendant, :wildcard}]
    end

    test "child wildcard" do
      assert Parser.parse("[*]") ==
        [{:child, :wildcard}]
    end

    test "child string identifier" do
      assert Parser.parse("[\"foo\"]") ==
        [{:child, {:identifier, "foo"}}]
    end

    test "descendant string identifier" do
      assert Parser.parse("$..[\"foo\"]") ==
        [:root, {:descendant, {:identifier, "foo"}}]
    end
  end

  describe "wildcard (*)" do
    test "all children" do
      assert Parser.parse("foo[*]") ==
        [{:child, {:identifier, :foo}}, {:child, :wildcard}]
    end

    test "wildcard members" do
      assert Parser.parse("*") ==
        [{:child, :wildcard}]
    end
  end
end
