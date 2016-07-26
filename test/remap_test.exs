defmodule RemapTest do
  use ExUnit.Case, async: true
  import Remap
  doctest Remap

  test "map single key" do
    actual =
      %{first_name: "John"}
      |> remap(%{name: ~p"first_name"})

    assert actual == %{name: "John"}
  end

  test "map multiple keys" do
    actual =
      %{
        first_name: "John",
        last_name: "Doe",
      }
      |> remap(%{
        name: ~p"first_name",
        surname: ~p"last_name",
      })

    assert actual == %{
      name: "John",
      surname: "Doe",
    }
  end

  test "map nested keys" do
    actual =
      %{person: %{first_name: "John"}}
      |> remap(%{name: ~p"person.first_name"})

    assert actual == %{name: "John"}
  end

  test "extract list of children properties" do
    actual =
      %{children: [
         %{first_name: "Sally"},
         %{first_name: "Frank"},
       ]}
      |> remap(%{child_names: ~p"children[*].first_name"l})

    assert actual == %{child_names: ["Sally", "Frank"]}
  end

  describe "wildcard (*)" do
    test "get values of map" do
      values =
        %{
          foo: "1",
          bar: "2",
        }
        |> remap(%{values: ~p"*"l})
        |> Map.get(:values)
        |> Enum.sort # order is not guaranteed by maps

      assert values == ["1", "2"]
    end
  end

  describe "descendant steps (..)" do
    test "extract list of child properties" do
      actual =
        %{children: [
             %{first_name: "Sally"},
             %{first_name: "Frank"},
           ]}
           |> remap(%{child_names: ~p"$..first_name"l})

      assert actual == %{child_names: ["Sally", "Frank"]}
    end

    test "nested child properties are totally flattened" do
      actual =
        %{children: [
             [%{first_name: "Sally"}],
             %{first_name: "Frank"},
           ]}
           |> remap(%{child_names: ~p"$..first_name"l})

      assert actual == %{child_names: ["Sally", "Frank"]}
    end

    test "recursive child properties" do
      actual =
        %{foo: [
           %{foo: %{foo: :bar}},
         ]}
         |> remap(%{foos: ~p"$..foo"l})

      assert actual == %{foos: [[%{foo: %{foo: :bar}}], %{foo: :bar}, :bar]}
    end

    test "start with .." do
      actual =
        %{children: [
             %{first_name: "Sally"},
             %{first_name: "Frank"},
           ]}
           |> remap(%{child_names: ~p"..first_name"l})

      assert actual == %{child_names: ["Sally", "Frank"]}
    end
  end

  describe "s modifier" do
    test "treat keys as strings" do
      actual =
        %{"person" => %{"first_name" => "John"}}
        |> remap(%{name: ~p"person.first_name"s})

      assert actual == %{name: "John"}
    end
  end
end
