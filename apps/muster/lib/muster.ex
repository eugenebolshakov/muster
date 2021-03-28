defmodule Muster do
  alias Muster.{CurrentGame, Game}

  @spec get_current_game() :: Game.t()
  def get_current_game() do
    CurrentGame.get()
  end

  @spec join_game() :: {:ok, Game.t(), Game.player()} | {:error, :game_is_on}
  def join_game() do
    CurrentGame.join()
  end

  @spec move(Game.player(), Game.direction()) :: {:ok, Game.t()} | {:error, :player_cant_move}
  def move(player, direction) do
    CurrentGame.move(player, direction)
  end

  @spec stop_current_game() :: Game.t()
  def stop_current_game() do
    CurrentGame.stop()
  end

  @spec restart_current_game() :: {:ok, Game.t(), Game.player()} | {:error, :game_is_on}
  def restart_current_game() do
    CurrentGame.restart()
  end
end
