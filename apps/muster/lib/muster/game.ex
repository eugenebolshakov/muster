defmodule Muster.Game do
  alias Muster.Game.Grid

  @type status :: :waiting_for_players | :on | :won | :lost | :stopped
  @type player :: :player1 | :player2

  @type t :: %__MODULE__{
          status: status(),
          players: [player()],
          current_player: player() | nil,
          grid: Grid.t()
        }

  @type direction :: :left | :right | :up | :down

  @enforce_keys [:status, :grid]
  defstruct [status: nil, grid: nil, players: [], current_player: nil]

  @grid_size 6
  @first_tile 2
  @new_tile 1
  @winning_tile 2048
  @number_of_players 2

  @spec new() :: t()
  def new() do
    grid =
      @grid_size
      |> Grid.new()
      |> Grid.put_tile_in_random_space(@first_tile)

    %__MODULE__{status: :waiting_for_players, grid: grid}
  end

  @spec add_player(t(), player()) :: {:ok, t()} | {:error, :game_is_on}
  def add_player(%__MODULE__{status: :waiting_for_players} = game, player) do
    game = %{game | players: game.players ++ [player]}

    game = if length(game.players) == @number_of_players do
      %{game | status: :on, current_player: hd(game.players)}
    else
      game
    end

    {:ok, game}
  end

  def add_player(%__MODULE__{}, _), do: {:error, :game_is_on}

  @spec move(t(), player(), direction()) :: {:ok, t()} | {:error, :player_cant_move}
  def move(%__MODULE__{status: :on, current_player: player} = game, player, direction) do
    game =
      game
      |> move_tiles(direction)
      |> check_win()
      |> check_loss()
      |> maybe_add_new_tile()
      |> maybe_toggle_player()

    {:ok, game}
  end

  def move(%__MODULE__{}, _, _), do: {:error, :player_cant_move}

  defp move_tiles(game, direction) do
    grid = Grid.move_tiles(game.grid, direction)
    %{game | grid: grid}
  end

  defp check_win(game) do
    if Grid.tile_present?(game.grid, @winning_tile) do
      %{game | status: :won}
    else
      game
    end
  end

  defp check_loss(game) do
    if game.status == :on && Grid.count_spaces(game.grid) == 0 do
      %{game | status: :lost}
    else
      game
    end
  end

  defp maybe_add_new_tile(game) do
    if game.status == :on do
      grid = Grid.put_tile_in_random_space(game.grid, @new_tile)
      %{game | grid: grid}
    else
      game
    end
  end

  defp maybe_toggle_player(game) do
    if game.status == :on do
      %{game | current_player: Enum.find(game.players, & &1 != game.current_player)}
    else
      game
    end
  end

  @spec stop(t()) :: t()
  def stop(%__MODULE__{} = game) do
    %{game | status: :stopped}
  end

  @spec ended?(t()) :: boolean()
  def ended?(%__MODULE__{status: status}) do
    status in ~w(won lost stopped)a
  end
end
