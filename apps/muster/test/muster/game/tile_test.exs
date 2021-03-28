defmodule Muster.Game.TileTest do
  use ExUnit.Case

  alias Muster.Game.Tile

  describe "reverse_column/2" do
    test "reverses tile's position in the row" do
      assert Tile.reverse_column(tile(column: 0), 5) == tile(column: 5)
      assert Tile.reverse_column(tile(column: 1), 5) == tile(column: 4)
      assert Tile.reverse_column(tile(column: 2), 5) == tile(column: 3)
      assert Tile.reverse_column(tile(column: 3), 5) == tile(column: 2)
      assert Tile.reverse_column(tile(column: 4), 5) == tile(column: 1)
      assert Tile.reverse_column(tile(column: 5), 5) == tile(column: 0)
    end
  end

  describe "transpose/1" do
    test "swaps tile's row and column" do
      assert Tile.transpose(tile(row: 1, column: 2)) == tile(row: 2, column: 1)
    end
  end

  describe "compare/2" do
    test "compares tiles in the same row" do
      assert Tile.compare(tile(column: 1), tile(column: 0)) == :gt
      assert Tile.compare(tile(column: 0), tile(column: 1)) == :lt
      assert Tile.compare(tile(column: 0), tile(column: 0)) == :eq
    end

    test "compares tiles in different rows" do
      assert Tile.compare(tile(row: 1), tile(row: 0)) == :gt
      assert Tile.compare(tile(row: 0), tile(row: 1)) == :lt
      assert Tile.compare(tile(row: 0), tile(row: 0)) == :eq
    end
  end

  defp tile(attrs) do
    attrs = Keyword.merge([row: 0, column: 0, value: 1], attrs)
    struct(Tile, attrs)
  end
end
