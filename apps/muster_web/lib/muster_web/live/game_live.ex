defmodule MusterWeb.GameLive do
  use MusterWeb, :live_view
  alias MusterWeb.GameView
  alias MusterWeb.Endpoint

  @topic "game_update"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@topic)

      case Muster.join_game() do
        {:ok, game, player} ->
          Endpoint.broadcast_from(self(), @topic, "player_joined", %{})
          {:ok, assign(socket, game: game, player: player)}

        {:error, :game_is_on} ->
          game = Muster.get_current_game()
          {:ok, assign(socket, game: game, player: nil)}
      end
    else
      game = Muster.get_current_game()
      {:ok, assign(socket, game: game, player: nil)}
    end
  end

  @key_mappings %{
    "ArrowUp" => :up,
    "ArrowDown" => :down,
    "ArrowLeft" => :left,
    "ArrowRight" => :right
  }

  @impl true
  def handle_event("move", %{"key" => key}, socket) do
    if direction = @key_mappings[key] do
      game = Muster.move(direction)
      Endpoint.broadcast_from(self(), @topic, "player_moved", %{})
      {:noreply, assign(socket, game: game)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  @events ~w(player_joined player_moved)
  def handle_info(%{event: event}, socket) when event in @events do
    game = Muster.get_current_game()
    {:noreply, assign(socket, game: game)}
  end
end
