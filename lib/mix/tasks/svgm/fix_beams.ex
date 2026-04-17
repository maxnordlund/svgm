defmodule Mix.Tasks.Svgm.FixBeams do
  @shortdoc "Fixes source location in beam debug info"

  @moduledoc """
  #{@shortdoc}

  This adjusts the source file location inside the beams for the currently
  running `elixir`. The end result is that `elixir_ls`/`expert` goto definition
  now works.

  By default it prints a progress bar on standard error, but this can be
  disabled with `--no-progress`. To see the result for each individual file
  enable `--verbose` output. Finally, you may safely run it using `--dry-run`.

  ## Options

  - `-v`, `--verbose`: Prints the result of each fil
  - `-n`, `--dry-run`: Runs the task without modifying any file.
  - `--no-progress`: Disables the progress bar.
  """
  alias Mix.Tasks.Svgm.FixBeams

  use Mix.Task

  @options [
    aliases: [v: :verbose, n: :dry_run],
    strict: [dry_run: :boolean, progress: :boolean, verbose: :boolean]
  ]

  defstruct dry_run: false,
            progress: true,
            verbose: false,
            total: 0,
            existing_sources: 0,
            missing_beam_files: 0,
            missing_sources: 0,
            fixed: 0

  @impl true
  def run(args) do
    {options, _args} = OptionParser.parse!(args, @options)
    progress = Keyword.get(options, :progress, true)

    if progress do
      Mix.shell().info([
        [:green, "Existing sources", :default_color, ?/],
        [:red, "Missing BEAM's", :default_color, ?/],
        [:yellow, "Missing sources", :default_color],
        "/Fixed/Total"
      ])
    end

    all_available_modules =
      for {_module_name, path, _loaded} <- :code.all_available(),
          is_relevant_module(path) do
        path
      end

    state = %FixBeams{
      dry_run: Keyword.get(options, :dry_run, false),
      progress: progress,
      verbose: Keyword.get(options, :verbose, false),
      total: length(all_available_modules)
    }

    state = Enum.reduce(all_available_modules, state, &fix_beam/2)

    if progress do
      print_progress_bar(state)
      Mix.shell().info("")
    end
  end

  # In-memory modules, for example mix.exs, have no beam file.
  # Let's just ignore them.
  defp is_relevant_module(~c""), do: false
  # Ignore preloaded and cover compiled modules
  defp is_relevant_module(path), do: is_list(path)

  defp fix_beam(beam_path, %FixBeams{} = state) do
    with {:ok, beam} <- File.read(beam_path),
         {:ok, module, chunks} <- :beam_lib.all_chunks(beam),
         {:ok, source_path} when is_binary(source_path) <- source_path(module, beam_path) do
      {:ok, beam} =
        fix_chunks(chunks, source_path)
        |> :beam_lib.build_module()

      state.dry_run || File.write(beam_path, beam)
      print_result(state, [:yellow, "± patching beam "], beam_path)
      %FixBeams{state | fixed: state.fixed + 1}
    else
      {:ok, :source_exists} ->
        print_result(state, ["  source exists "], beam_path)
        %FixBeams{state | existing_sources: state.existing_sources + 1}

      {:error, :source_missing} ->
        print_result(state, [:red, "? missing source"], beam_path)
        %FixBeams{state | missing_sources: state.missing_sources + 1}

      {:error, :enoent} ->
        print_result(state, [:red, "- missing beam  "], beam_path)
        %FixBeams{state | missing_beam_files: state.missing_beam_files + 1}
    end
    |> print_progress_bar()
  end

  defp fix_chunks(chunks, source_path) do
    chunks = chunks |> Enum.map(&chunk_to_keyword/1)
    chunks = put_in(chunks[:CInf][:source], String.to_charlist(source_path))

    chunks =
      case chunks[:Dbgi] do
        {:debug_info_v1, :elixir_erl, {:elixir_v1, info}} ->
          info = put_in(info.file, source_path)
          put_in(chunks[:Dbgi], {:debug_info_v1, :elixir_erl, {:elixir_v1, info}})

        {:debug_info_v1, :erl_abstract_code, {_forms, _compile_options}} ->
          chunks
      end

    Enum.map(chunks, &keyword_to_chunk/1)
  end

  @doc """
  Returns the likely path to the source for this BEAM file.

  For example, say you have installed Elixir at
  `~/.asdf/installs/elixir/1.19.5/`. Inside `lib/` you have a directory per
  application, and inside these you'll find another `lib/`. There you'll find a
  `ebin/` directory with the BEAM files, as well as the sources.

  Thus for a path like `lib/elixir/ebin/Elixir.Access.beam` we want
  `lib/elixir/lib/access.ex`. Similarily for
  `lib/eex/ebin/Elixir.EEx.Compiler.beam` we want `lib/eex/lib/eex/compiler.ex`.
  Note that `compiler.ex` is inside `eex/`.
  """
  def source_path(module, beam_path) do
    source = to_string(module.module_info(:compile)[:source])
    lib = lib_directory(beam_path)

    cond do
      File.exists?(source) ->
        {:ok, :source_exists}

      String.starts_with?(Atom.to_string(module), "Elixir.") ->
        source_path = Path.join(lib, Macro.underscore(module) <> ".ex")

        if File.exists?(source_path) do
          {:ok, source_path}
        else
          elixir_source_path(lib, source)
        end

      true ->
        with {:error, :source_missing} <- erlang_source_path(beam_path) do
          elixir_source_path(lib, source)
        end
    end
  end

  defp elixir_source_path(lib, source) do
    # From something like /home/runner/work/elixir/elixir/lib/access.ex
    # to ~/.asdf/installs/elixir/1.19.5/lib/access.ex
    source_path = Path.join(lib, split_last_lib(source))

    if File.exists?(source_path) do
      {:ok, source_path}
    else
      {:error, :source_missing}
    end
  end

  defp lib_directory(beam_path) do
    Path.join([beam_path, "..", "..", "lib"])
    |> Path.expand()
  end

  defp split_last_lib(source) do
    List.foldr(Path.split(source), [], &split_last_lib/2)
  catch
    path -> path
  end

  defp split_last_lib("lib", path), do: throw(Path.join(path))
  defp split_last_lib(part, path), do: [part | path]

  defp erlang_source_path(beam_path) do
    case :filelib.find_source(beam_path) do
      {:ok, source_path} -> {:ok, to_string(source_path)}
      {:error, :not_found} -> {:error, :source_missing}
    end
  end

  defp chunk_to_keyword({name, data}) when name in ~w(Attr CInf Dbgi)c do
    {List.to_atom(name), :erlang.binary_to_term(data)}
  end

  defp chunk_to_keyword({name, data}) do
    {List.to_atom(name), data}
  end

  defp keyword_to_chunk({name, data}) when name in ~w(Attr CInf Dbgi)a do
    {Atom.to_charlist(name), :erlang.term_to_binary(data)}
  end

  defp keyword_to_chunk({name, data}) do
    {Atom.to_charlist(name), data}
  end

  defp print_result(%FixBeams{verbose: true}, message, beam_path) do
    Mix.shell().info([
      ?\r,
      :clear_line,
      message,
      " ",
      IO.ANSI.syntax_colors()[:atom],
      Path.basename(beam_path, ".beam"),
      :default_color
    ])
  end

  defp print_result(%FixBeams{verbose: false}, _message, _beam_path) do
    :ok
  end

  defp print_progress_bar(%FixBeams{progress: true} = state) do
    {:ok, columns} = :io.columns()
    {counter_width, counter} = counter(state)
    bar = bar(state, columns - counter_width - 1)

    if Mix.shell() == Mix.Shell.IO do
      IO.write(:stderr, IO.ANSI.format([?\r, :clear_line, bar, " ", counter]))
    end

    state
  end

  defp print_progress_bar(%FixBeams{progress: false} = state) do
    state
  end

  defp counter(%FixBeams{} = state) do
    {widths, segments} =
      Enum.unzip([
        counter_segment(:green, state.existing_sources),
        counter_segment(:red, state.missing_beam_files),
        counter_segment(:yellow, state.missing_sources),
        counter_segment(:default_color, state.fixed),
        counter_segment(:default_color, state.total)
      ])

    {Enum.sum(widths) + 5, Enum.intersperse(segments, ?/)}
  end

  defp counter_segment(colour, value) do
    value = Integer.to_string(value)
    {String.length(value), [colour, value, :default_color]}
  end

  defp bar(%FixBeams{} = state, bar_width) do
    {widths, segments} =
      Enum.unzip([
        bar_segment(:green, state.existing_sources, state.total, bar_width),
        bar_segment(:red, state.missing_beam_files, state.total, bar_width),
        bar_segment(:yellow, state.missing_sources, state.total, bar_width),
        bar_segment(:default_color, state.fixed, state.total, bar_width)
      ])

    left_width = bar_width - Enum.sum(widths)
    [segments, :default_color, String.duplicate("-", left_width)]
  end

  defp bar_segment(_colour, _field, 0, _bar_width), do: {0, ""}
  defp bar_segment(_colour, field, _total, _bar_width) when field < 0, do: {0, ""}

  defp bar_segment(colour, field, total, bar_width) do
    width = round(field / total * bar_width)
    {width, [colour, String.duplicate("=", width)]}
  end
end
