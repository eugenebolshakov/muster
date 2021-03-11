defmodule MusterWeb.GameLive do
  use MusterWeb, :live_view
  alias MusterWeb.{Endpoint, GameMonitor, GameView}

  @topic "game_update"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@topic)
      socket = join_game(socket)
      {:ok, socket}
    else
      game = Muster.get_current_game()
      {:ok, assign(socket, game: game, player: nil)}
    end
  end

  defp join_game(socket) do
    case Muster.join_game() do
      {:ok, game, player} ->
        Endpoint.broadcast_from(self(), @topic, "player_joined", %{})
        start_playing(socket, game, player)

      {:error, :game_is_on} ->
        game = Muster.get_current_game()
        assign(socket, game: game, player: nil)
    end
  end

  defp start_playing(socket, game, player) do
    GameMonitor.monitor(&unmount/0)
    assign(socket, game: game, player: player)
  end

  @key_mappings %{
    "ArrowUp" => :up,
    "ArrowDown" => :down,
    "ArrowLeft" => :left,
    "ArrowRight" => :right
  }

  @impl true
  def handle_event("move", %{"key" => key}, socket) do
    with true <- Map.has_key?(@key_mappings, key),
         {:ok, game} <- Muster.move(socket.assigns.player, @key_mappings[key]) do
      Endpoint.broadcast_from(self(), @topic, "player_moved", %{})
      {:noreply, assign(socket, game: game)}
    else
      _ ->
        game = Muster.get_current_game()
        {:noreply, assign(socket, game: game)}
    end
  end

  @impl true
  def handle_event("restart_game", _value, socket) do
    case Muster.restart_current_game() do
      {:ok, game, player} ->
        Endpoint.broadcast_from(self(), @topic, "game_restarted", %{})
        {:noreply, start_playing(socket, game, player)}

      {:error, :game_is_on} ->
        game = Muster.get_current_game()
        {:noreply, assign(socket, game: game, player: nil)}
    end
  end

  @impl true
  def handle_event("join_game", _value, socket) do
    {:noreply, join_game(socket)}
  end

  @impl true
  @events ~w(player_joined player_moved)
  def handle_info(%{event: event}, socket) when event in @events do
    game = Muster.get_current_game()
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_info(%{event: "player_left"}, socket) do
    GameMonitor.demonitor()
    game = Muster.get_current_game()
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_info(%{event: "game_restarted"}, socket) do
    game = Muster.get_current_game()
    {:noreply, assign(socket, game: game, player: nil)}
  end

  def unmount() do
    Muster.stop_current_game()
    Endpoint.broadcast(@topic, "player_left", %{})
  end
end
