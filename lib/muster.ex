defmodule Muster do
  @type tile :: pos_integer
  @type row :: [tile() | nil]

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
end
