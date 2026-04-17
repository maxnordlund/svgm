defmodule SVGM.Options do
  @moduledoc false

  defstruct preset: :default,
            precision: nil,
            pass_overrides: %{}

  @type t :: %__MODULE__{
          preset: :default | :safe,
          precision: non_neg_integer() | nil,
          pass_overrides: %{String.t() => boolean()}
        }

  @doc """
  Converts the given keyword list to a `SVGM.Options` struct.
  """
  def from(keywords) do
    %__MODULE__{
      preset: keywords[:preset] || :default,
      precision: keywords[:precision],
      pass_overrides: keywords[:pass_overrides] || %{}
    }
  end
end
