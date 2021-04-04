defmodule SyncWeb.ProfileController do
  use SyncWeb, :controller

  import SyncWeb.AuthPlug

  plug :authenticate

  def show(conn, _params) do
    repo_users = Sync.PRSyncServer.list_users()

    render(conn, "show.html", repo_users: repo_users)
  end

  def map_user(conn, %{"id" => id, "name" => name}) do
    mapped_user = %Sync.Github.User{id: id, name: name}

    conn
    |> put_flash(:info, "You have been mapped to #{name}!")
    |> put_session(:current_mapped_user, mapped_user)
    |> redirect(to: "/events")
  end
end
