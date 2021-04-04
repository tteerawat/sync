defmodule SyncWeb.AuthPlugTest do
  use SyncWeb.ConnCase

  alias SyncWeb.AuthPlug

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(SyncWeb.Router, :browser)
      |> get("/")

    {:ok, conn: conn}
  end

  describe "authenticate/2" do
    test "halts conn if no current_user assigned", %{conn: conn} do
      conn = AuthPlug.authenticate(conn, [])

      assert get_flash(conn, :error) =~ "You must be signed in to access the page"
      assert conn.halted
    end

    test "does not halt conn if current_user assigned", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> AuthPlug.authenticate([])

      refute conn.halted
    end
  end
end
