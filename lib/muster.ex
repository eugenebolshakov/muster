defmodule Muster do
  alias Muster.{CurrentGame, Game}

  @spec get_current_game() :: Game.t() | nil
  def get_current_game() do
    CurrentGame.get()
  end

  @spec new_game() :: Game.t()
  def new_game() do
    CurrentGame.new()
  end

  @spec move(Game.direction()) :: Game.t()
  def move(direction) do
    CurrentGame.move(direction)
  end
end
