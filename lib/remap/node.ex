defprotocol Remap.Node do
  @dialyzer {:nowarn_function, __protocol__: 1, impl_for!: 1}
  @fallback_to_any true

  @type t :: any

  @spec get_members(t, Remap.member) :: [any]
  def get_members(data, member)

  @spec get_children(t) :: [any]
  def get_children(data)
end

defimpl Remap.Node, for: Any do
  def get_members(_data, _member), do: []

  def get_children(_data), do: []
end

defimpl Remap.Node, for: List do
  def get_members(_list, {:identifier, _key}), do: []

  def get_children(list), do: list
end

defimpl Remap.Node, for: Map do
  def get_members(map, {:identifier, key}) do
    if Map.has_key?(map, key) do
      [Map.get(map, key)]
    else
      []
    end
  end

  def get_children(map), do: Map.values(map)
end
