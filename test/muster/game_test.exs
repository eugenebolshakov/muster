defmodule Muster.GameTest do
  use ExUnit.Case

  alias Muster.Game

  describe "new/0" do
    test "returns a Game with a 6x6 grid" do
      %{grid: grid} = Game.new()

      assert length(grid) == 6

      grid
      |> Enum.with_index()
      |> Enum.each(fn {row, i} ->
        assert length(row) == 6, "Row #{i} has wrong length"
      end)
    end

    test "places a tile of value 2 in a random space" do
      tile_locations =
        0..5
        |> Enum.map(fn _ ->
          %{grid: grid} = Game.new()

          elements = List.flatten(grid)
          assert length(elements) == 36

          assert Enum.count(elements, &(&1 == 2)) == 1
          assert Enum.count(elements, &is_nil/1) == 35

          Enum.find_index(elements, &(&1 == 2))
        end)
        |> Enum.uniq()

      assert length(tile_locations) > 1, "Tile placed in the same location 5 times"
    end
  end

  describe "move/2" do
    test "moves tiles in the passed direction" do
      game = %Game{
        grid: [
          [nil, 1, nil, 2, nil, nil],
          [1, 1, nil, nil, 1, nil],
          [nil, nil, nil, 2, 3, nil],
          [3, 3, 6, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil],
          [nil, 1, nil, 2, nil, nil]
        ]
      }

      %{grid: grid} = Game.move(game, :left)

      assert grid == [
               [1, 2, nil, nil, nil, nil],
               [2, 1, nil, nil, nil, nil],
               [2, 3, nil, nil, nil, nil],
               [6, 6, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [1, 2, nil, nil, nil, nil]
             ]
    end
  end
end
