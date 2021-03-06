defmodule Muster.Game do
  @type t :: %__MODULE__{
          grid: [Muster.rows()]
        }

  @enforce_keys [:grid]
  defstruct [:grid]

  @grid_size 6

  def new() do
    grid =
      nil
      |> List.duplicate(@grid_size)
      |> List.duplicate(@grid_size)

    %__MODULE__{grid: grid}
  end
end
