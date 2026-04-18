defmodule SVGM.MixProject do
  use Mix.Project

  @version "0.3.7"
  @source_url "https://github.com/maxnordlund/svgm"

  @doc """
  See https://hexdocs.pm/mix/Mix.Project.html
  """
  def project do
    [
      app: :svgm,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [
        ignore_modules: [
          Mix.Tasks.Svgm.FixBeams,
          SVGM.Native
        ]
      ],

      # Documentation https://hexdocs.pm/ex_doc/readme.html
      name: "SVGM",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),

      # Hex https://hex.pm/docs/publish#adding-metadata-to-mixexs
      description: "NIF wrapper for svgm-core, a SVG optimization library in Rust.",
      package: packages()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli() do
    [
      preferred_envs: [
        bench: :test
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.37.3", runtime: false},
      {:rustler_precompiled, "~> 0.9.0"},

      # Dev & Test
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  # See https://hexdocs.pm/mix/Mix.Tasks.Compile.Elixir.html#module-configuration
  defp elixirc_paths(:test) do
    ["lib", "test"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end

  defp aliases do
    [
      bench: ["run test/svgm_bench.exs"],
      check: ["credo", "svgm.cargo clippy"],
      clean: ["clean", "svgm.clean", "svgm.cargo clean"],
      docs: ["svgm.readme", "docs"],
      format: ["format", "svgm.cargo fmt"]
    ]
  end

  # See https://hexdocs.pm/ex_doc/ExDoc.html#generate/4
  defp docs do
    [
      assets: %{
        "assets" => "assets"
      },
      extras: ["README.md", "LICENSE-APACHE", "LICENSE-MIT"],
      main: "readme"
    ]
  end

  defp packages() do
    [
      licenses: ["Apache-2.0", "MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: [
        # Elixir
        ".formatter.exs",
        "mix.exs",
        # Instead of a plain `lib`, this wildcard avoids shipping the internal
        # mix tasks.
        "lib/svgm*",

        # Rust related
        "Cargo.*",
        "native",
        "checksum-*.exs",

        # General
        "README.md",
        "LICENSE*"
      ],
      source_ref: "v#{@version}"
    ]
  end
end
