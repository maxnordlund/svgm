defmodule Mix.Tasks.Svgm.Cargo do
  use Mix.Task

  @shortdoc "Runs `cargo`."
  @moduledoc """
  Runs `cargo` with the given arguments.

  The difference between this and `mix cmd` is that the later captures standard
  output, which `cargo` interprets as it's being piped, even though it's output
  is forwarded to the BEAM's standard output. This breaks/disables colouring.

  This makes sure to execute `cargo` such that it properly inherits the BEAM's
  standard output.
  """

  @requirements ["loadpaths"]

  @impl true
  def run(args) do
    shell = Mix.shell()

    shell.cmd(
      {"cargo", args},
      # Bypass stdio capture, but only if the mix shell refer to stdio.
      use_stdio: shell != Mix.Shell.IO
    )
  end
end
