defmodule MusterWeb.GameLive do
  use MusterWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    game = Muster.get_current_game()
    {:ok, assign(socket, game: game)}
  end

  @impl true
  def handle_event("start_game", _value, socket) do
    game = Muster.new_game()
    {:noreply, assign(socket, game: game)}
  end

  @key_mappings %{
    "ArrowUp" => :up,
    "ArrowDown" => :down,
    "ArrowLeft" => :left,
    "ArrowRight" => :right
  }

  @impl true
  def handle_event("move", %{"key" => key}, socket) do
    game = if direction = @key_mappings[key] do
      Muster.move(direction)
    else
      Muster.get_current_game()
    end
    {:noreply, assign(socket, game: game)}
  end
end
