defmodule MusterTest do
  use ExUnit.Case

  test "Play a game" do
    refute Muster.get_current_game()

    assert {:ok, game, :player1} = Muster.join_game()
    assert game.status == :waiting_for_players
    assert Muster.get_current_game() == game

    assert {:ok, game, :player2} = Muster.join_game()
    assert game.status == :on
    assert game.current_player == :player1
    assert Muster.get_current_game() == game

    game = Muster.move(:left)
    assert game.current_player == :player2
    assert Muster.get_current_game() == game

    game = Muster.stop_current_game()
    assert game.status == :stopped
    assert Muster.get_current_game() == game
  end
end
