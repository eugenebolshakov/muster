defmodule Muster.Game.GridTest do
  use ExUnit.Case
  import Muster.TestHelper

  alias Muster.Game.Grid

  describe "new/0" do
    test "returns an empty list of tiles" do
      assert Grid.new() == []
    end
  end

  describe "put_tile_in_random_space/2" do
    test "adds tile with the passed value" do
      assert [%{value: 1}] = Grid.put_tile_in_random_space([], 1)
    end

    test "adds tile into an empty space" do
      grid = [
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 0, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1]
      ]

      new_tile =
        grid
        |> tiles()
        |> Grid.put_tile_in_random_space(2)
        |> Enum.find(fn tile -> tile.value == 2 end)

      assert new_tile.row == 3
      assert new_tile.column == 4
    end

    test "adds tile into a random space" do
      tile_locations =
        0..5
        |> Enum.map(fn _ ->
          assert [tile] = Grid.put_tile_in_random_space([], 1)
          {tile.row, tile.column}
        end)
        |> Enum.uniq

      assert length(tile_locations) > 1, "Tile placed in the same location 5 times"
    end
  end

  describe "move_tiles/2" do
    @grid [
      [0, 1, 0, 0, 0, 1],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [1, 0, 0, 0, 0, 2]
    ]

    test "moves tiles in a grid left" do
      assert move_tiles(@grid, :left) == tiles([
               [2, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [1, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [1, 2, 0, 0, 0, 0]
             ])
    end

    test "moves tiles in a grid right" do
      assert move_tiles(@grid, :right) == tiles([
               [0, 0, 0, 0, 0, 2],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 1],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 1, 2]
             ])
    end

    test "moves tiles in a grid up" do
      assert move_tiles(@grid, :up) == tiles([
               [1, 1, 0, 0, 0, 2],
               [0, 0, 0, 0, 0, 2],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0]
             ])
    end

    test "moves tiles in a grid down" do
      assert move_tiles(@grid, :down) == tiles([
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 2],
               [1, 1, 0, 0, 0, 2]
             ])
    end
  end

  describe "move_tiles_in_row/1" do
    test "moves tiles to the beginning" do
      assert move_tiles([1]) == row([1])
      assert move_tiles([0, 1]) == row([1])
      assert move_tiles([1, 0, 2]) == row([1, 2])
      assert move_tiles([0, 1, 2]) == row([1, 2])
      assert move_tiles([1, 0, 0, 2]) == row([1, 2])
      assert move_tiles([0, 0, 1, 0, 0, 2]) == row([1, 2])
    end

    test "merges tiles with the same numbers and sums the numbers" do
      assert move_tiles([1, 1]) == row([2])
      assert move_tiles([2, 2]) == row([4])
      assert move_tiles([1, 0, 1]) == row([2])
      assert move_tiles([1, 0, 0, 1]) == row([2])
      assert move_tiles([0, 1, 0, 1]) == row([2])
    end

    test "merges leftmost tiles" do
      assert move_tiles([1, 1, 1]) == row([2, 1])
      assert move_tiles([0, 1, 0, 1, 0, 1]) == row([2, 1])
      assert move_tiles([1, 0, 1, 1]) == row([2, 1])
    end

    test "merges pairs of tiles" do
      assert move_tiles([1, 1, 1, 1]) == row([2, 2])
      assert move_tiles([0, 1, 0, 1, 0, 1, 0, 1]) == row([2, 2])
    end

    test "merges tiles once per move" do
      assert move_tiles([1, 1, 2]) == row([2, 2])
      assert move_tiles([1, 0, 1, 0, 2]) == row([2, 2])
      assert move_tiles([1, 1, 0, 2]) == row([2, 2])
      assert move_tiles([2, 0, 1, 1]) == row([2, 2])
    end

    test "can handle empty row" do
      assert move_tiles([]) == row([])
    end
  end

  describe "tile_present?/2" do
    test "returns true if tile is present in the grid" do
      refute Grid.tile_present?(tiles([[]]), 1)
      refute Grid.tile_present?(tiles([[0]]), 1)
      refute Grid.tile_present?(tiles([[2]]), 1)
      refute Grid.tile_present?(tiles([[0, 2], [3, 0]]), 1)

      assert Grid.tile_present?(tiles([[1]]), 1)
      assert Grid.tile_present?(tiles([[2, 0], [0, 1]]), 1)
    end
  end

  describe "count_spaces/1" do
    test "returns number of spaces in a grid" do
      grid = [
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1]
      ]

      assert Grid.count_spaces(tiles(grid)) == 0

      grid = put_in(grid, [Access.at(0), Access.at(0)], 0)
      assert Grid.count_spaces(tiles(grid)) == 1

      grid = put_in(grid, [Access.at(0), Access.at(1)], 0)
      assert Grid.count_spaces(tiles(grid)) == 2
    end
  end

  defp move_tiles(grid, direction) do
    Grid.move_tiles(tiles(grid), direction)
  end

  defp move_tiles(row_tiles) do
    row_tiles
    |> row()
    |> Grid.move_tiles_in_row()
  end
end
