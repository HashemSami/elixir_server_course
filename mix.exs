defmodule Survey.MixProject do
  use Mix.Project

  def project do
    [
      app: :survey,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :observer, :wx]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 5.0"},
      {:earmark, "~> 1.4"},
      {:httpoison, "~> 2.0"}
    ]
  end
end
