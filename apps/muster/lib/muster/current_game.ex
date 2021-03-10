defmodule Muster.CurrentGame do
  use GenServer

  @type server :: pid() | __MODULE__

  alias Muster.Game

  def init(nil) do
    {:ok, nil}
  end

  def init(%Game{} = game) do
    {:ok, game}
  end

  def init(_), do: {:error, "Game must be a #{Game} or nil"}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @spec get(server()) :: Game.t() | nil
  def get(server \\ __MODULE__) do
    GenServer.call(server, :get)
  end

  @spec join(server()) :: {:ok, Game.t(), Game.player()} | {:error, :game_is_on}
  def join(server \\ __MODULE__) do
    GenServer.call(server, :join)
  end

  @spec move(server(), Game.direction()) :: Game.t()
  def move(server \\ __MODULE__, direction) do
    GenServer.call(server, {:move, direction})
  end

  @spec stop(server()) :: Game.t() | nil
  def stop(server \\ __MODULE__) do
    GenServer.call(server, :stop)
  end

  @spec restart(server()) :: {:ok, Game.t(), Game.player()} | {:error, :game_is_on}
  def restart(server \\ __MODULE__) do
    GenServer.call(server, :restart)
  end

  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  def handle_call(:join, _from, game) do
    join_game(game || Game.new())
  end

  def handle_call({:move, direction}, _from, game) do
    game = Game.move(game, direction)
    {:reply, game, game}
  end

  def handle_call(:stop, _from, game) do
    game = game && Game.stop(game)
    {:reply, game, game}
  end

  def handle_call(:restart, _from, game) do
    if is_nil(game) || Game.ended?(game) do
      join_game(Game.new)
    else
      {:error, :game_is_on}
    end
  end

  defp join_game(game) do
    if game.status == :waiting_for_players do
      player = String.to_atom("player#{length(game.players) + 1}")
      game = Game.add_player(game, player)
      {:reply, {:ok, game, player}, game}
    else
      {:reply, {:error, :game_is_on}, game}
    end
  end
end
