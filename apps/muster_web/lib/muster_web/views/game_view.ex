defmodule MusterWeb.GameView do
  use MusterWeb, :view

  def player_name(player, current_player) do
    if player == current_player do
      "You"
    else
      player
    end
  end
end
