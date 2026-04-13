defmodule SVGM.Native do
  use Rustler, otp_app: :svgm, crate: "svgm_native"

  def optimize(_svg) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
