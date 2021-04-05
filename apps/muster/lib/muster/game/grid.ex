defmodule Muster.Game.Grid do
  alias Muster.Game
  alias Muster.Game.Tile

  @type t :: [Tile.t()]

  @grid_size 6

  @spec new() :: t()
  def new() do
    []
  end

  @spec put_tile_in_random_space(t(), Tile.value()) :: t()
  def put_tile_in_random_space(tiles, value) do
    {row, column} = tiles |> spaces |> Enum.random()
    tile = %Tile{row: row, column: column, value: value}
    sort([tile | tiles])
  end

  @spec put_ids(t(), next_id :: Tile.id()) :: {t(), next_id :: Tile.id()}
  def put_ids(tiles, next_id) do
    Enum.map_reduce(tiles, next_id, fn tile, next_id ->
      if tile.id do
        {tile, next_id}
      else
        {%{tile | id: next_id}, next_id + 1}
      end
    end)
  end

  defp spaces(tiles) do
    indices = 0..(@grid_size - 1)

    positions =
      Enum.flat_map(indices, fn row ->
        Enum.map(indices, fn column ->
          {row, column}
        end)
      end)

    tile_positions = Enum.map(tiles, fn tile -> {tile.row, tile.column} end)
    positions -- tile_positions
  end

  defp sort(tiles) do
    Enum.sort(tiles, Tile)
  end

  @spec move_tiles(t(), Game.direction()) :: t()
  def move_tiles(tiles, :left) do
    tiles
    |> rows()
    |> Enum.map(&move_tiles_in_row/1)
    |> List.flatten()
  end

  def move_tiles(tiles, :right) do
    tiles
    |> reverse_columns()
    |> move_tiles(:left)
    |> reverse_columns()
  end

  def move_tiles(tiles, :up) do
    tiles
    |> transpose()
    |> move_tiles(:left)
    |> transpose()
  end

  def move_tiles(tiles, :down) do
    tiles
    |> transpose()
    |> reverse_columns()
    |> move_tiles(:left)
    |> reverse_columns()
    |> transpose()
  end

  defp rows(tiles) do
    Enum.map(0..(@grid_size - 1), fn row_index ->
      Enum.filter(tiles, fn tile -> tile.row == row_index end)
    end)
  end

  @spec move_tiles_in_row([Tile.t()], Tile.index()) :: [Tile.t()]
  def move_tiles_in_row(row, current_column \\ 0) do
    case row do
      [] ->
        []

      [%{value: value} = tile | [%{value: value} | rest]] ->
        [
          %Tile{row: tile.row, column: current_column, value: value * 2}
          | move_tiles_in_row(rest, current_column + 1)
        ]

      [tile | rest] ->
        [%{tile | column: current_column} | move_tiles_in_row(rest, current_column + 1)]
    end
  end

  defp reverse_columns(tiles) do
    tiles
    |> Enum.map(&Tile.reverse_column(&1, @grid_size - 1))
    |> sort()
  end

  defp transpose(tiles) do
    tiles
    |> Enum.map(&Tile.transpose/1)
    |> sort()
  end

  @spec tile_present?(t(), Tile.value()) :: boolean()
  def tile_present?(tiles, value) do
    Enum.any?(tiles, fn tile -> tile.value == value end)
  end

  @spec count_spaces(t()) :: integer()
  def count_spaces(tiles) do
    tiles
    |> spaces
    |> length
  end
end
