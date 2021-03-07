defmodule Muster.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Muster.CurrentGame, [name: Muster.CurrentGame]}
    ]

    opts = [strategy: :one_for_one, name: Muster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
