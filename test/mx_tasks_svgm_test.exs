defmodule MixTasksSvgmTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  setup_all do
    shell = Mix.shell()
    Mix.shell(Mix.Shell.Process)
    on_exit(fn -> Mix.shell(shell) end)
  end

  setup %{task: task, tmp_dir: tmp_dir} do
    working_directory = File.cwd!()
    File.cd!(tmp_dir)
    on_exit(fn -> File.cd!(working_directory) end)

    Mix.Task.reenable(task)
    on_exit(&Mix.Shell.Process.flush/0)
  end

  @tag task: "svgm.cargo"
  test "mix svgm.cargo version" do
    Mix.Task.run("svgm.cargo", ["version"])

    assert_receive {:mix_shell, :run, ["cargo " <> _ | _]}
  end

  describe "mix svgm.clean" do
    @describetag task: "svgm.clean"

    test "removes the doc directory" do
      File.mkdir!("doc")

      Mix.Task.run("svgm.clean")

      refute File.exists?("doc")
    end

    test "removes the cover directory" do
      File.mkdir!("cover")

      Mix.Task.run("svgm.clean")

      refute File.exists?("cover")
    end

    test "removes both directories" do
      File.mkdir!("doc")
      File.mkdir!("cover")

      Mix.Task.run("svgm.clean")

      refute File.exists?("doc")
      refute File.exists?("cover")
    end
  end

  @tag task: "svgm.readme"
  test "mix svgm.readme" do
    Path.expand("../README.md.eex", __DIR__)
    |> File.copy!("README.md.eex")

    Mix.Task.run("svgm.readme")

    assert File.exists?("README.md")
    assert File.read!("README.md") == File.read!(Path.expand("../README.md", __DIR__))
  end
end
