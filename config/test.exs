use Mix.Config

config :sync, github: Sync.MockGithub, pr_sync_server: Sync.MockPRSyncServer

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sync, SyncWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :sync, Sync.Github,
  client_id: "client-id-123",
  client_secret: "client-secret-123"
