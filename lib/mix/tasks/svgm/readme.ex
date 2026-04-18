defmodule Mix.Tasks.Svgm.Readme do
  use Mix.Task
  require Record

  Record.defrecordp(
    :docs_v1,
    Record.extract(:docs_v1, from_lib: "kernel/include/eep48.hrl")
  )

  Record.defrecordp(
    :docs_v1_entry,
    Record.extract(:docs_v1_entry, from_lib: "kernel/include/eep48.hrl")
  )

  @shortdoc "Renders the README"

  @moduledoc """
  #{@shortdoc}

  This reads various files and renders the repository README.
  """

  @requirements ["compile"]

  @impl true
  def run(_args) do
    Mix.shell().info("Rendering README")

    docs = Code.fetch_docs(SVGM)
    optimize_doc = Enum.find_value(docs_v1(docs, :docs), &optimize_doc_finder(&1))

    rustler_version =
      Mix.Dep.cached()
      |> Enum.find_value(&rustler_version_finder/1)

    readme =
      EEx.eval_file(
        "README.md.eex",
        version: Mix.Project.config()[:version],
        module_doc: docs_v1(docs, :module_doc)["en"],
        optimize_doc: optimize_doc,
        rustler_version: rustler_version
      )

    File.write!("README.md", readme)
  end

  defp optimize_doc_finder(entry) do
    entry = Tuple.insert_at(entry, 0, :docs_v1_entry)

    if docs_v1_entry(entry, :kind_name_arity) == {:function, :optimize!, 2} do
      docs_v1_entry(entry, :doc)["en"]
    end
  end

  defp rustler_version_finder(%Mix.Dep{app: :rustler} = dep) do
    {:ok, version} = dep.status
    version
  end

  defp rustler_version_finder(%Mix.Dep{}) do
    nil
  end
end
