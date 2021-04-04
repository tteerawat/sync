defmodule SyncWeb.EventController do
  use SyncWeb, :controller

  import SyncWeb.AuthPlug

  plug :authenticate

  def index(conn, _params) do
    current_mappped_user = conn.assigns.current_mapped_user

    events =
      Sync.PRSyncServer.list_prs()
      |> Enum.filter(fn pr -> String.contains?(pr.body, "@#{current_mappped_user.name}") end)

    render(conn, "index.html", events: events)
  end
end
