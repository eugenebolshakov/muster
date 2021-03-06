defmodule Muster.Game do
  alias Muster.Game.Grid

  @type t :: %__MODULE__{
          grid: Grid.t()
        }

  @type direction :: :left | :right | :up | :down

  @enforce_keys [:grid]
  defstruct [:grid]

  @grid_size 6
  @first_tile 2

  @spec new() :: t()
  def new() do
    grid =
      @grid_size
      |> Grid.new()
      |> Grid.put_tile_in_random_space(@first_tile)

    %__MODULE__{grid: grid}
  end

  @spec move(t(), direction()) :: t()
  def move(%__MODULE__{} = game, direction) do
    %__MODULE__{grid: Grid.move_tiles(game.grid, direction)}
  end
end
