defmodule Muster.Game do
  alias Muster.Game.Grid

  @type status :: :on | :won

  @type t :: %__MODULE__{
          status: status(),
          grid: Grid.t()
        }

  @type direction :: :left | :right | :up | :down

  @enforce_keys [:status, :grid]
  defstruct [:status, :grid]

  @grid_size 6
  @first_tile 2
  @new_tile 1
  @winning_tile 2048

  @spec new() :: t()
  def new() do
    grid =
      @grid_size
      |> Grid.new()
      |> Grid.put_tile_in_random_space(@first_tile)

    %__MODULE__{status: :on, grid: grid}
  end

  @spec move(t(), direction()) :: t()
  def move(%__MODULE__{status: :on} = game, direction) do
    game
    |> move_tiles(direction)
    |> check_win()
    |> maybe_add_new_tile()
  end

  defp move_tiles(game, direction) do
    grid = Grid.move_tiles(game.grid, direction)
    %{game | grid: grid}
  end

  defp check_win(game) do
    if Grid.tile_present?(game.grid, @winning_tile) do
      %{game | status: :won}
    else
      game
    end
  end

  defp maybe_add_new_tile(game) do
    if game.status == :on do
      grid = Grid.put_tile_in_random_space(game.grid, @new_tile)
      %{game | grid: grid}
    else
      game
    end
  end
end
