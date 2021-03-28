ExUnit.start()

defmodule Muster.TestHelper do
  alias Muster.Game
  alias Muster.Game.Tile

  def set_grid(game, grid) do
    grid =
      grid
      |> tiles()
      |> Enum.with_index()
      |> Enum.map(fn {tile, index} ->
        %Tile{tile | id: index + 1}
      end)

    %Game{game | grid: grid, next_id: List.last(grid).id + 1}
  end

  def tiles(rows) do
    rows
    |> Enum.with_index()
    |> Enum.flat_map(fn {row_tiles, i} ->
      row(row_tiles, i)
    end)
  end

  def row(tile_values, row_index \\ 0) do
    tile_values
    |> Enum.with_index()
    |> Enum.filter(fn {value, _index} -> value != 0 end)
    |> Enum.map(fn {value, index} -> %Tile{row: row_index, column: index, value: value} end)
  end
end
