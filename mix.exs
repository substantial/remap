defmodule Remap.Mixfile do
  use Mix.Project

  def project do
    [app: :remap,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
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
end
