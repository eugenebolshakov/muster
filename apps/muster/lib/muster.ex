defmodule Muster do
  alias Muster.{CurrentGame, Game}

  @spec get_current_game() :: Game.t() | nil
  def get_current_game() do
    CurrentGame.get()
  end

  @spec join_game() :: {:ok, Game.t(), Game.player()} | {:error, :game_is_on}
  def join_game() do
    CurrentGame.join()
  end

  @spec move(Game.direction()) :: Game.t()
  def move(direction) do
    CurrentGame.move(direction)
  end

  @spec stop_current_game() :: Game.t() | nil
  def stop_current_game() do
    CurrentGame.stop()
  end

  @spec restart_current_game() :: {:ok, Game.t, Game.player()} | {:error, :game_is_on}
  def restart_current_game() do
    CurrentGame.restart()
  end
end
