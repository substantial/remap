defmodule RemapTest do
  use ExUnit.Case, async: true
  import Remap
  doctest Remap

  defmodule TestStruct do
    defstruct [:value]
  end

  test "map single key" do
    actual =
      %{first_name: "John"}
      |> remap(%{name: ~p"first_name"})

    assert actual == %{name: "John"}
  end

  test "list as data" do
    actual =
      [%{first_name: "John"}]
      |> remap(%{name: ~p"[*].first_name"})

    assert actual == %{name: "John"}
  end

  test "list as result" do
    actual =
      [%{first_name: "John"}]
      |> remap([~p"[*].first_name"])

    assert actual == ["John"]
  end

  test "single value as result" do
    actual =
      [%{first_name: "John"}]
      |> remap(~p"[*].first_name")

    assert actual == "John"
  end

  test "nested template" do
    actual =
      %{
        children: [
          %{first_name: "John"},
          %{first_name: "Sally"},
        ],
      }
      |> remap(%{
        info: %{
          child_names: ~p"children[*].first_name"l,
        },
      })

    assert actual == %{
      info: %{
        child_names: ["John", "Sally"],
      },
    }
  end

  test "struct template" do
    actual =
      %{foo: "bar"}
      |> remap(%TestStruct{value: ~p"foo"})

    assert actual == %TestStruct{value: "bar"}
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

  describe "subscript ([...])" do
    test "extract list of children properties" do
      actual =
        %{children: [
          %{first_name: "Sally"},
          %{first_name: "Frank"},
        ]}
        |> remap(%{child_names: ~p"children[*].first_name"l})

      assert actual == %{child_names: ["Sally", "Frank"]}
    end

    test "extract string key" do
      actual =
        %{"foo" => "bar"}
      |> remap(%{foo: ~p(["foo"])})

      assert actual == %{foo: "bar"}
    end

    test "descendant subscript with string key" do
      actual =
        %{
          "x" => %{"foo" => "bar1"},
          "y" => %{"foo" => "bar2"},
        }
        |> remap(%{foo: ~p(..["foo"])l})

      assert actual == %{foo: ["bar1", "bar2"]}
    end
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
