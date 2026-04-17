defmodule SVGMTest.Helpers do
  @moduledoc """
  This module contains helpers used by both the `ExUnit` tests and `Benchee`
  benchmark.
  """

  @doc """
  Read SVG from the "assets" directory or svgm-core fixtures, in that order.
  """
  def read_svg!("assets/" <> name) do
    assets()
    |> Path.join(name)
    |> File.read!()
  end

  def read_svg!(name) do
    svgm_core_test_fixtures()
    |> Path.join(name)
    |> File.read!()
  end

  @doc """
  List the available SVG's that can be read by `svg/1` from the given source.
  """
  @spec list_svgs(:assets | :svgm_core) :: [Path.t()]
  def list_svgs(:assets) do
    assets = assets()
    repo_root = Path.dirname(assets)

    for path <- Path.wildcard("#{assets}/**/*.svg") do
      Path.relative_to(path, repo_root)
    end
  end

  def list_svgs(:svgm_core) do
    fixtures = svgm_core_test_fixtures()

    for path <- Path.wildcard("#{fixtures}/**/*.svg") do
      Path.relative_to(path, fixtures)
    end
  end

  defp assets do
    Path.expand("../../assets", __DIR__)
  end

  defp svgm_core_test_fixtures do
    package = Enum.find(cargo_manifest()["packages"], &svgm_core_package?/1)
    Path.expand("../tests/fixtures", package["manifest_path"])
  end

  defp svgm_core_package?(%{"name" => "svgm-core"}) do
    true
  end

  defp svgm_core_package?(_) do
    false
  end

  defp cargo_manifest do
    if manifest = :persistent_term.get(__MODULE__, nil) do
      manifest
    else
      {manifest, 0} = System.cmd("cargo", ["metadata", "--format-version", "1"])
      manifest = JSON.decode!(manifest)
      :persistent_term.put(__MODULE__, manifest)
      manifest
    end
  end
end
