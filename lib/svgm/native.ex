defmodule SVGM.Native do
  @moduledoc false

  use Rustler, otp_app: :svgm, crate: "svgm_native"

  def optimize(_svg, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
