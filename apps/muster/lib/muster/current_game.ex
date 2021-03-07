defmodule Muster.CurrentGame do
  use GenServer

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

  @spec get() :: Game.t() | nil
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @spec new() :: Game.t()
  def new() do
    GenServer.call(__MODULE__, :new)
  end

  @spec move(Game.direction()) :: Game.t()
  def move(direction) do
    GenServer.call(__MODULE__, {:move, direction})
  end

  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  def handle_call(:new, _from, _game) do
    game = Game.new()
    {:reply, game, game}
  end

  def handle_call({:move, direction}, _from, game) do
    game = Game.move(game, direction)
    {:reply, game, game}
  end
end
