defmodule MusterWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: MusterWeb.PubSub},
      {MusterWeb.GameMonitor, name: MusterWeb.GameMonitor},
      # Start the Telemetry supervisor
      MusterWeb.Telemetry,
      # Start the Endpoint (http/https)
      MusterWeb.Endpoint
      # Start a worker by calling: MusterWeb.Worker.start_link(arg)
      # {MusterWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MusterWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MusterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
