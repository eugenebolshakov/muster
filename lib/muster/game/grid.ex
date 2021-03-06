defmodule Muster.Game.Grid do
  alias Muster.Game

  @type tile :: pos_integer
  @type row :: [Game.tile() | nil]
  @type t :: [row()]

  @spec move_tiles(t(), Game.direction()) :: t()
  def move_tiles(grid, :left) do
    Enum.map(grid, &move_tiles/1)
  end

  def move_tiles(grid, :right) do
    grid
    |> reverse_columns()
    |> move_tiles(:left)
    |> reverse_columns()
  end

  def move_tiles(grid, :up) do
    grid
    |> transpose_grid()
    |> move_tiles(:left)
    |> transpose_grid()
  end

  def move_tiles(grid, :down) do
    grid
    |> transpose_grid()
    |> reverse_columns()
    |> move_tiles(:left)
    |> reverse_columns()
    |> transpose_grid()
  end

  @spec move_tiles(row()) :: row()
  def move_tiles(row) do
    case row do
      [] ->
        []

      [nil | rest] ->
        move_tiles(rest) ++ [nil]

      [tile | [nil | rest]] ->
        move_tiles([tile] ++ rest) ++ [nil]

      [tile | [tile | rest]] ->
        [tile + tile] ++ move_tiles(rest) ++ [nil]

      [tile | rest] ->
        [tile] ++ move_tiles(rest)
    end
  end

  def transpose_grid([]), do: []
  def transpose_grid([[] | _] = grid), do: grid

  @spec transpose_grid(t()) :: [t()]
  def transpose_grid([row | _] = grid) do
    Enum.map(0..(length(grid) - 1), fn i ->
      Enum.map(0..(length(row) - 1), fn j ->
        get_in(grid, [Access.at(j), Access.at(i)])
      end)
    end)
  end

  defp reverse_columns(grid) do
    Enum.map(grid, &Enum.reverse/1)
  end
end
