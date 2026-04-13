defmodule SVGM do
  @moduledoc Path.expand("../README.md", __DIR__)
             |> File.read!()

  @doc ~S"""
  Optimize an SVG string.

  ## Examples

      iex> SVGM.optimize(~s|
      ...> <svg version="1.1"
      ...>     width="300" height="200"
      ...>     xmlns="http://www.w3.org/2000/svg">
      ...>   <rect width="100%" height="100%" fill="red" />
      ...>   <circle cx="150" cy="100" r="80" fill="green" />
      ...>   <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
      ...> </svg>
      ...> |)
      {:ok, ~s|<svg xmlns="http://www.w3.org/2000/svg" height="200" width="300"><rect fill="red" height="100%" width="100%"/><circle cx="150" cy="100" fill="green" r="80"/><text fill="#fff" font-size="60" text-anchor="middle" x="150" y="125">SVG</text></svg>|}
  """
  def optimize(svg) do
    SVGM.Native.optimize(svg)
  end
end
