defmodule MusterTest do
  use ExUnit.Case

  test "Play a game" do
    refute Muster.get_current_game()

    game = Muster.new_game()
    assert Muster.get_current_game() == game

    game = Muster.move(:left)
    assert Muster.get_current_game() == game
  end
end
