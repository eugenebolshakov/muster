defmodule MusterWeb.GameView do
  use MusterWeb, :view

  def player_name(player, current_player) do
    if player == current_player do
      "You"
    else
      player
    end
  end

  def all_tiles(game) do
    Enum.sort_by(game.grid ++ game.merged_tiles, & &1.id)
  end
end
