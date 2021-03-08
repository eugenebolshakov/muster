# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :muster_web,
  generators: [context_app: :muster]

# Configures the endpoint
config :muster_web, MusterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZdlTifqoLyyjPmZa5xXjPrKVp/LsM1/Q7dPF/dply6pjcaMVLgb9JCQMrkk+/hv2",
  render_errors: [view: MusterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MusterWeb.PubSub,
  live_view: [signing_salt: "mzaFLbTd"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
