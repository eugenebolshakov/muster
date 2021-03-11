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

    test "returns a grid with a single tile of value 2" do
      %{grid: grid} = Game.new()

      elements = List.flatten(grid)
      assert length(elements) == 36

      assert Enum.count(elements, &(&1 == 2)) == 1
      assert Enum.count(elements, &is_nil/1) == 35
    end

    test "returns a game that is waiting for players" do
      game = Game.new()
      assert game.status == :waiting_for_players
    end
  end

  describe "add_player/2" do
    test "adds the player to the list" do
      game = Game.new
      assert game.players == []

      assert {:ok, game} = Game.add_player(game, :player1)
      assert game.players == [:player1]
    end

    test "starts the game when 2 players are added" do
      game = Game.new
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
      game = Game.new
      assert {:ok, game} = Game.add_player(game, :player1)
      assert {:ok, game} = Game.add_player(game, :player2)
      assert Game.add_player(game, :player3) == {:error, :game_is_on}
    end
  end

  describe "move/2" do
    setup :start_game

    test "moves tiles and adds a tile of value 1", %{game: game} do
      game = %{game | grid: [
          [nil, 1, nil, 2, nil, nil],
          [1, 1, nil, nil, 1, nil],
          [nil, nil, nil, 2, 3, nil],
          [3, 3, 6, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil],
          [nil, 1, nil, 2, nil, nil]
        ]
      }

      assert {:ok, %{grid: grid}} = Game.move(game, :player1, :left)

      expected_grid = [
        [1, 2, nil, nil, nil, nil],
        [2, 1, nil, nil, nil, nil],
        [2, 3, nil, nil, nil, nil],
        [6, 6, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil],
        [1, 2, nil, nil, nil, nil]
      ]

      Enum.each(0..5, fn i ->
        Enum.each(0..5, fn j ->
          expected_cell = get_in_grid(expected_grid, i, j)
          cell = get_in_grid(grid, i, j)

          if is_nil(expected_cell) do
            assert is_nil(cell) || cell == 1, "Expected nil or 1 at #{i}:#{j}, got: #{cell}"
          else
            assert cell == expected_cell, "Wrong cell at #{i}:#{j}"
          end
        end)
      end)

      expected_spaces =
        expected_grid
        |> List.flatten()
        |> Enum.count(&is_nil/1)

      spaces =
        grid
        |> List.flatten()
        |> Enum.count(&is_nil/1)

      assert spaces == expected_spaces - 1, "Wrong number of spaces left"
    end

    test "game is won when a tile reaches the value 2048", %{game: game} do
      game = %{game | grid: [[1024, 512, 512, nil, nil, nil]] ++ build_empty_rows(5)}

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert get_in_grid(game.grid, 0, 0) == 1024
      assert get_in_grid(game.grid, 0, 1) == 1024
      assert game.status == :on

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert get_in_grid(game.grid, 0, 0) == 2048
      assert game.status == :won
    end

    test "game is lost when there is no space to add a new tile", %{game: game} do
      game = %{game | grid: [[1, 2, 3, 4, 5, nil]] ++ List.duplicate([1, 2, 3, 4, 5, 6], 5)}

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert get_in_grid(game.grid, 0, 5) == 1
      assert game.status == :on

      assert {:ok, game} = Game.move(game, game.current_player, :left)
      assert game.status == :lost
    end

    test "toggles current player" do
      game = %Game{status: :on, players: [:player1, :player2], current_player: :player1, grid: build_empty_rows(6)}

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
      player = Enum.find(game.players, & &1 != game.current_player)
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

  defp get_in_grid(grid, i, j) do
    get_in(grid, [Access.at(i), Access.at(j)])
  end

  defp start_game(context) do
    game = %Game{
      status: :on,
      players: [:player1, :player2],
      current_player: :player1,
      grid: build_empty_rows(6)
    }

    Map.put(context, :game, game)
  end

  defp build_empty_rows(number_of_rows) do
    nil
    |> List.duplicate(6)
    |> List.duplicate(number_of_rows)
  end
end
