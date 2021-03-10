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

      game = Game.add_player(game, :player1)
      assert game.players == [:player1]
    end

    test "starts the game when 2 players are added" do
      game = Game.new
      assert game.players == []
      assert game.status == :waiting_for_players
      refute game.current_player

      game = Game.add_player(game, :player1)
      assert game.players == [:player1]
      assert game.status == :waiting_for_players
      refute game.current_player

      game = Game.add_player(game, :player2)
      assert game.players == [:player1, :player2]
      assert game.status == :on
      assert game.current_player == :player1
    end
  end

  describe "move/2" do
    test "moves tiles and adds a tile of value 1" do
      game = %Game{
        status: :on,
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

    test "game is won when a tile reaches the value 2048" do
      grid = [[1024, 512, 512, nil, nil, nil]] ++ build_empty_rows(5)
      game = %Game{status: :on, grid: grid}

      game = Game.move(game, :left)
      assert get_in_grid(game.grid, 0, 0) == 1024
      assert get_in_grid(game.grid, 0, 1) == 1024
      assert game.status == :on

      game = Game.move(game, :left)
      assert get_in_grid(game.grid, 0, 0) == 2048
      assert game.status == :won
    end

    test "game is lost when there is no space to add a new tile" do
      grid = [[1, 2, 3, 4, 5, nil]] ++ List.duplicate([1, 2, 3, 4, 5, 6], 5)
      game = %Game{status: :on, grid: grid}

      game = Game.move(game, :left)
      assert get_in_grid(game.grid, 0, 5) == 1
      assert game.status == :on

      game = Game.move(game, :left)
      assert game.status == :lost
    end

    test "toggles current player" do
      game = %Game{status: :on, players: [:player1, :player2], current_player: :player1, grid: build_empty_rows(6)}

      game = Game.move(game, :left)
      assert game.current_player == :player2

      game = Game.move(game, :left)
      assert game.current_player == :player1
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

  defp build_empty_rows(number_of_rows) do
    nil
    |> List.duplicate(6)
    |> List.duplicate(number_of_rows)
  end
end
