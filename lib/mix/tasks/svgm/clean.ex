defmodule Mix.Tasks.Svgm.Clean do
  use Mix.Task

  @shortdoc "Deletes generated documentation and coverage files"

  @moduledoc """
  #{@shortdoc}

  This command deletes the documentation and test coverage artifacts.

  ## Command line options
    * `--no-cargo` - does not remove the `cargo/` directory
    * `--no-cover` - does not remove the `cover/` directory
    * `--no-doc` - does not remove the `doc/` directory
  """

  @requirements []

  # Boolean switches automatically get a "--no-*" variant
  @switches [
    cargo: :boolean,
    cover: :boolean,
    doc: :boolean
  ]

  @impl true
  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: @switches)
    project_config = Mix.Project.config()

    if Keyword.get(options, :doc, true) do
      doc_dir = project_config[:docs][:output] || "doc"
      File.rm_rf!(doc_dir)
      Mix.shell().info("Removed #{doc_dir}")
    end

    if Keyword.get(options, :cover, true) do
      cover_dir = project_config[:test_coverage][:output] || "cover"
      File.rm_rf!(cover_dir)
      Mix.shell().info("Removed #{cover_dir}")
    end
  end
end
