defmodule MusterTest do
  use ExUnit.Case

  describe "move_tiles/2" do
    @grid [
      [nil, 1, 1],
      [nil, nil, 1],
      [1, nil, 2]
    ]

    test "moves tiles in a grid left" do
      assert Muster.move_tiles(@grid, :left) == [
               [2, nil, nil],
               [1, nil, nil],
               [1, 2, nil]
             ]
    end

    test "moves tiles in a grid right" do
      assert Muster.move_tiles(@grid, :right) == [
               [nil, nil, 2],
               [nil, nil, 1],
               [nil, 1, 2]
             ]
    end

    test "moves tiles in a grid up" do
      assert Muster.move_tiles(@grid, :up) == [
               [1, 1, 2],
               [nil, nil, 2],
               [nil, nil, nil]
             ]
    end

    test "moves tiles in a grid down" do
      assert Muster.move_tiles(@grid, :down) == [
               [nil, nil, nil],
               [nil, nil, 2],
               [1, 1, 2]
             ]
    end
  end

  describe "move_tiles/1" do
    test "moves tiles to the beginning" do
      assert Muster.move_tiles([1]) == [1]
      assert Muster.move_tiles([nil, 1]) == [1, nil]
      assert Muster.move_tiles([1, nil]) == [1, nil]
      assert Muster.move_tiles([1, nil, 2]) == [1, 2, nil]
      assert Muster.move_tiles([nil, 1, 2]) == [1, 2, nil]
      assert Muster.move_tiles([1, 2, nil]) == [1, 2, nil]
      assert Muster.move_tiles([1, nil, nil, 2]) == [1, 2, nil, nil]

      assert Muster.move_tiles([nil, nil, 1, nil, nil, 2, nil, nil]) ==
               [1, 2] ++ List.duplicate(nil, 6)
    end

    test "merges tiles with the same numbers and sums the numbers" do
      assert Muster.move_tiles([1, 1]) == [2, nil]
      assert Muster.move_tiles([2, 2]) == [4, nil]
      assert Muster.move_tiles([1, nil, 1]) == [2, nil, nil]
      assert Muster.move_tiles([1, nil, nil, 1]) == [2, nil, nil, nil]
      assert Muster.move_tiles([nil, 1, nil, 1]) == [2, nil, nil, nil]
      assert Muster.move_tiles([1, nil, 1, nil]) == [2, nil, nil, nil]
    end

    test "merges leftmost tiles" do
      assert Muster.move_tiles([1, 1, 1]) == [2, 1, nil]
      assert Muster.move_tiles([nil, 1, nil, 1, nil, 1, nil]) == [2, 1, nil, nil, nil, nil, nil]
      assert Muster.move_tiles([1, nil, 1, 1]) == [2, 1, nil, nil]
    end

    test "merges pairs of tiles" do
      assert Muster.move_tiles([1, 1, 1, 1]) == [2, 2, nil, nil]

      assert Muster.move_tiles([nil, 1, nil, 1, nil, 1, nil, 1, nil]) ==
               [2, 2] ++ List.duplicate(nil, 7)
    end

    test "merges tiles once per move" do
      assert Muster.move_tiles([1, 1, 2]) == [2, 2, nil]
      assert Muster.move_tiles([1, nil, 1, nil, 2]) == [2, 2, nil, nil, nil]
      assert Muster.move_tiles([1, 1, nil, 2]) == [2, 2, nil, nil]
      assert Muster.move_tiles([2, nil, 1, 1]) == [2, 2, nil, nil]
    end

    test "can handle empty row" do
      assert Muster.move_tiles([]) == []
      assert Muster.move_tiles([nil]) == [nil]
      assert Muster.move_tiles([nil, nil]) == [nil, nil]
      assert Muster.move_tiles([nil, nil, nil]) == [nil, nil, nil]
    end
  end

  describe "transpose_grid/1" do
    test "replaces rows with columns" do
      grid = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]

      assert Muster.transpose_grid(grid) == [
               [1, 4, 7],
               [2, 5, 8],
               [3, 6, 9]
             ]
    end
  end
end
