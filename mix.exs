defmodule Zendesk.MixProject do
  use Mix.Project

  @version "0.0.2"
  @repo "https://github.com/parallel-markets/zendesk"

  def project do
    [
      app: :zendesk,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An Elixir client for the Zendesk (zendesk.com) platform",
      package: package(),
      source_url: @repo,
      docs: [
        source_ref: "v#{@version}",
        main: "readme",
        extras: ["README.md"],
        formatters: ["html"]
      ],
      preferred_cli_env: [test: :test, lint: :test, "ci.test": :test]
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo, "Changelog" => "#{@repo}/blob/master/CHANGELOG.md"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28", only: :dev},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "credo"
      ],
      "ci.test": [
        "lint",
        "test"
      ]
    ]
  end
end
