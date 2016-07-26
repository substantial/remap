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
      |> remap(%{child_names: ~p"children[*].first_name"})

    assert actual == %{child_names: ["Sally", "Frank"]}
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
