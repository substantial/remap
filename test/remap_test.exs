defmodule RemapTest do
  use ExUnit.Case
  import Remap
  doctest Remap

  test "map single key" do
    actual =
      %{"first_name" => "John"}
      |> remap(%{name: ~m"first_name"})

    assert actual == %{name: "John"}
  end

  test "map multiple keys" do
    actual =
      %{
        "first_name" => "John",
        "last_name" => "Doe",
      }
      |> remap(%{
        name: ~m"first_name",
        surname: ~m"last_name",
      })

    assert actual == %{
      name: "John",
      surname: "Doe",
    }
  end

  test "map nested keys" do
    actual =
      %{"person" => %{"first_name" => "John"}}
      |> remap(%{name: ~m"person.first_name"})

    assert actual == %{name: "John"}
  end

  test "extract list of children properties" do
    actual =
      %{"children" => [
         %{"first_name" => "Sally"},
         %{"first_name" => "Frank"},
       ]}
      |> remap(%{child_names: ~m"children[*].first_name"})

    assert actual == %{child_names: ["Sally", "Frank"]}
  end
end
