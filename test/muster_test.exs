defmodule MusterTest do
  use ExUnit.Case

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
end
