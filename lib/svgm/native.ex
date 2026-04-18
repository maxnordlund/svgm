defmodule SVGM.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  env_config = Application.compile_env(:html5ever, Html5ever, [])

  mode =
    if Mix.env() in [:dev, :test] do
      :debug
    else
      :release
    end

  use RustlerPrecompiled,
    otp_app: :svgm,
    crate: "svgm_native",
    mode: mode,
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("SVGM_BUILD") in ["1", "true"] or env_config[:build_from_source],
    version: version

  def optimize(_svg, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
