defmodule Sync.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    children =
      [
        # Start the Telemetry supervisor
        SyncWeb.Telemetry,

        # Start the PubSub system
        {Phoenix.PubSub, name: Sync.PubSub},

        # Start the Endpoint (http/https)
        SyncWeb.Endpoint,

        # Start Finch for http
        {Finch, name: Sync.Finch}
      ] ++ list_children_by_env(args[:env])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sync.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SyncWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp list_children_by_env(:test) do
    []
  end

  defp list_children_by_env(_) do
    owner = Application.get_env(:sync, :owner) || raise "Github owner must be set"
    repo = Application.get_env(:sync, :repo) || raise "Github repo must be set"

    [
      {Sync.PRSyncServer, owner: owner, repo: repo}
    ]
  end
end
