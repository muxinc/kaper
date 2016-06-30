defmodule Kaper.Mixfile do
  use Mix.Project

  def project do
    [app: :kaper,
     version: "0.0.4",
     elixir: "~> 1.2",
     test_coverage: [tool: ExCoveralls],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: [
       contributors: ["Scott Kidder"],
       maintainers: ["Scott Kidder"],
       licenses: ["MIT"],
       links: %{github: "https://github.com/muxinc/kaper"},
       files: ["lib/*", "mix.exs", "README.md", "LICENSE"],
     ],
     description: """
     Elixir Kapacitor Client
     """]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:exvcr, "~> 0.7.4", only: [:test]},
     {:meck, "~> 0.8.4", only: [:test]},
     {:excoveralls, "~> 0.4", only: [:dev, :test]},
     {:poison, "~> 2.1"},
     {:httpoison, "~> 0.8.0"},
     {:hackney, "~> 1.4.10"},
     {:dogma, "~> 0.1.6", only: [:dev]}
    ]
  end
end
