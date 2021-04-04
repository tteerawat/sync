# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sync,
  github: Sync.Github,
  pr_sync_server: Sync.PRSyncServer,
  owner: System.get_env("GITHUB_REPO_OWNER"),
  repo: System.get_env("GITHUB_REPO_NAME")

config :sync, Sync.Github,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configures the endpoint
config :sync, SyncWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B7vw/qr4iPo6lHB+cnVGC4YIo2EuocpPf3tLtk5WbHPlbl6gRs0XcHlZTQq33ZNJ",
  render_errors: [view: SyncWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Sync.PubSub,
  live_view: [signing_salt: "uFN4xGm7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
