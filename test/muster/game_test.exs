defmodule Muster.GameTest do
  use ExUnit.Case

  alias Muster.Game

  describe "new/0" do
    test "returns a Game with a 6x6 grid" do
      game = Game.new()

      assert game.grid == [
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil]
             ]
    end
  end
end
