defmodule Muster.GameTest do
  use ExUnit.Case
  import Muster.TestHelper

  alias Muster.Game

  @empty_grid [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0]
  ]

  describe "new/0" do
    test "returns a grid with a single tile of value 2" do
      assert %{grid: [tile]} = Game.new()

      assert tile.value == 2
      assert tile.row in 0..5
      assert tile.column in 0..5
      assert tile.id
    end

    test "returns a game that is waiting for players" do
      game = Game.new()
      assert game.status == :waiting_for_players
    end
  end

  describe "add_player/2" do
    test "adds the player to the list" do
      game = Game.new()
      assert game.players == []

      assert {:ok, game} = Game.add_player(game, :player1)
      assert game.players == [:player1]
    end

    test "starts the game when 2 players are added" do
      game = Game.new()
      assert game.players == []
      assert game.status == :waiting_for_players
      refute game.current_player

      assert {:ok, game} = Game.add_player(game, :player1)
      assert game.players == [:player1]
      assert game.status == :waiting_for_players
      refute game.current_player

      assert {:ok, game} = Game.add_player(game, :player2)
      assert game.players == [:player1, :player2]
      assert game.status == :on
      assert game.current_player == :player1
    end

    test "returns error if the game is already on" do
      game = Game.new()
      assert {:ok, game} = Game.add_player(game, :player1)
      assert {:ok, game} = Game.add_player(game, :player2)
      assert Game.add_player(game, :player3) == {:error, :game_is_on}
    end
  end

  describe "move/2" do
    setup :start_game

    test "moves tiles and adds a tile of value 1", %{game: game} do
      game = %{
        game
        | grid:
            tiles([
              [0, 1, 0, 2, 0, 0],
              [1, 1, 0, 0, 1, 0],
              [0, 0, 0, 2, 3, 0],
              [3, 3, 6, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 1, 0, 2, 0, 0]
            ])
      }

      expected_grid =
        tiles([
          [1, 2, 0, 0, 0, 0],
          [2, 1, 0, 0, 0, 0],
          [2, 3, 0, 0, 0, 0],
          [6, 6, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [1, 2, 0, 0, 0, 0]
        ])

      assert {:ok, %{grid: grid}} = Game.move(game, :player1, :left)
      assert [new_tile] = remove_ids(grid) -- expected_grid
      assert new_tile.value == 1
    end

    test "assigns unique ids to tiles", %{game: game} do
      game = %{
        game
        | grid:
            tiles([
              [0, 1, 0, 2, 0, 0],
              [1, 1, 0, 0, 1, 0],
              [0, 0, 0, 2, 3, 0],
              [3, 3, 6, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 1, 0, 2, 0, 0]
            ])
      }

      assert {:ok, %{grid: grid}} = Game.move(game, :player1, :left)
      assert Enum.map(grid, & &1.id) |> Enum.uniq() |> length == length(grid)
    end

    test "stores merged tiles", %{game: game} do
      game =
        set_grid(game, [
          [1, 1, 2, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0]
        ])

      assert {:ok, game} = Game.move(game, :player1, :left)
      assert Enum.at(game.grid, 0).value == 2
      assert Enum.at(game.grid, 1).value == 2
      assert Enum.map(game.merged_tiles, & &1.value) == [1, 1]

      assert {:ok, game} = Game.move(game, :player2, :left)
      assert Enum.at(game.grid, 0).value == 4
      assert Enum.map(game.merged_tiles, & &1.value) == [1, 1, 2, 2]
    end

    test "game is won when a tile reaches the value 2048", %{game: game} do
      game = %{
        game
        | grid:
            tiles([
              [1024, 512, 512, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0]
            ])
      }

      assert {:ok, %{grid: [tile1 | [tile2 | _]]} = game} =
               Game.move(game, game.current_player, :left)

      assert tile1.value == 1024
      assert tile2.value == 1024
      assert game.status == :on

      assert {:ok, %{grid: [tile | _]} = game} = Game.move(game, game.current_player, :left)
      assert tile.value == 2048
      assert game.status == :won
    end

    test "game is lost when there is no space to add a new tile", %{game: game} do
      game = %{
        game
        | grid:
            tiles([
              [1, 2, 3, 4, 5, 6],
              [1, 2, 3, 4, 5, 6],
              [1, 2, 3, 4, 5, 6],
              [1, 2, 3, 4, 5, 6],
              [1, 2, 3, 4, 5, 6],
              [1, 2, 3, 4, 5, 0]
            ])
      }

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert length(game.grid) == 36
      assert List.last(game.grid).value == 1
      assert game.status == :on

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert game.status == :lost
    end

    test "toggles current player" do
      game = %Game{
        status: :on,
        players: [:player1, :player2],
        current_player: :player1,
        grid: tiles(@empty_grid)
      }

      assert {:ok, game} = Game.move(game, :player1, :left)
      assert game.current_player == :player2

      assert {:ok, game} = Game.move(game, :player2, :left)
      assert game.current_player == :player1
    end

    test "returns error if game is not on", %{game: game} do
      game = %{game | status: "stopped"}
      assert Game.move(game, game.current_player, :left) == {:error, :player_cant_move}
    end

    test "returns error if it's not player's turn", %{game: game} do
      player = Enum.find(game.players, &(&1 != game.current_player))
      assert Game.move(game, player, :left) == {:error, :player_cant_move}
    end
  end

  describe "stop/1" do
    test "stops the game" do
      game = Game.new()
      game = Game.stop(game)
      assert game.status == :stopped
    end
  end

  describe "endded?/1" do
    test "returns true if game has ended" do
      game = Game.new()

      refute Game.ended?(%{game | status: :waiting_for_players})
      refute Game.ended?(%{game | status: :on})

      assert Game.ended?(%{game | status: :won})
      assert Game.ended?(%{game | status: :lost})
      assert Game.ended?(%{game | status: :stopped})
    end
  end

  defp start_game(context) do
    game = %Game{
      status: :on,
      players: [:player1, :player2],
      current_player: :player1,
      grid: tiles(@empty_grid)
    }

    Map.put(context, :game, game)
  end

  defp remove_ids(tiles) do
    Enum.map(tiles, &%{&1 | id: nil})
  end
end
