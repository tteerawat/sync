defmodule SyncWeb.AuthPlug do
  @behaviour Plug

  import Phoenix.Controller
  import Plug.Conn

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, _) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> assign(:current_mapped_user, get_session(conn, :current_mapped_user))
  end

  def authenticate(conn, _) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in to access the page")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
