defmodule Remap.Mixfile do
  use Mix.Project

  def project do
    [app: :remap,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.3", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    Map maps from maps/lists to another using JSONPath.
    """
  end

  defp package do
    [
      name: :remap,
      files: ["lib", "src", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Aaron Jensen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/substantial/remap"}
    ]
  end
end
