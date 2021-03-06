defmodule Muster.Game do
  @type t :: %__MODULE__{
          grid: [Muster.row()]
        }

  @enforce_keys [:grid]
  defstruct [:grid]

  @grid_size 6
  @first_tile 2

  @spec new() :: t()
  def new() do
    grid =
      nil
      |> List.duplicate(@grid_size)
      |> List.duplicate(@grid_size)
      |> put_tile_in_random_space(@first_tile)

    %__MODULE__{grid: grid}
  end

  defp put_tile_in_random_space(grid, tile) do
    random_index =
      grid
      |> list_spaces()
      |> Enum.random()

    put_tile_at(grid, tile, random_index)
  end

  defp list_spaces(grid) do
    grid
    |> List.flatten()
    |> Enum.with_index()
    |> Enum.filter(fn {cell, _i} -> is_nil(cell) end)
    |> Enum.map(fn {nil, i} -> i end)
  end

  defp put_tile_at(grid, tile, index) do
    i = div(index, @grid_size)
    j = Integer.mod(index, @grid_size)
    put_in(grid, [Access.at(i), Access.at(j)], tile)
  end
end
