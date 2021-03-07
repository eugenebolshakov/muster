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

    test "returns a game that is on" do
      assert Game.new().status == :on
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
