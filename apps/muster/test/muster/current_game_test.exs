defmodule Muster.CurrentGameTest do
  use ExUnit.Case

  alias Muster.CurrentGame

  setup do
    current_game = start_supervised!(CurrentGame)
    %{current_game: current_game}
  end

  describe "join/1" do
    test "allows two players to join", %{current_game: current_game} do
      assert {:ok, game, :player1} = CurrentGame.join(current_game)
      assert game.status == :waiting_for_players
      assert game.players == [:player1]

      assert {:ok, game, :player2} = CurrentGame.join(current_game)
      assert game.status == :on
      assert game.players == [:player1, :player2]

      assert CurrentGame.join(current_game) == {:error, :game_is_on}
    end
  end

  describe "get/1" do
    test "returns current game", %{current_game: current_game} do
      refute CurrentGame.get(current_game)

      assert {:ok, game, _player} = CurrentGame.join(current_game)
      assert CurrentGame.get(current_game) == game
    end
  end

  describe "move/2" do
    setup :start_game

    test "makes a move", %{current_game: current_game} do
      game = CurrentGame.get(current_game)
      after_move = CurrentGame.move(current_game, :left)
      refute game.current_player == after_move.current_player
    end
  end

  describe "stop/1" do
    setup :start_game

    test "stops current game", %{current_game: current_game} do
      assert CurrentGame.get(current_game).status == :on

      game = CurrentGame.stop(current_game)
      assert game.status == :stopped
      assert CurrentGame.get(current_game).status == :stopped
    end
  end

  describe "restart" do
    setup [:start_game, :stop_game]

    test "starts a new game and adds a player", %{current_game: current_game} do
      assert CurrentGame.get(current_game).status == :stopped

      assert {:ok, game, :player1} = CurrentGame.restart(current_game)
      assert game.status == :waiting_for_players
      assert game.players == [:player1]

      assert CurrentGame.get(current_game) == game
    end
  end

  defp start_game(%{current_game: current_game} = context) do
    {:ok, _, _} = CurrentGame.join(current_game)
    {:ok, %{status: :on}, _} = CurrentGame.join(current_game)
    context
  end

  defp stop_game(%{current_game: current_game} = context) do
    CurrentGame.stop(current_game)
    context
  end
end
