defmodule SyncWeb.PageControllerTest do
  use SyncWeb.ConnCase, async: true

  describe "GET /" do
    test "shows sign in button if no current_user exists", %{conn: conn} do
      conn = get(conn, "/")

      assert html_response(conn, 200) =~ "Sign in with Github"
    end

    test "shows sign out button if current_user exists", %{conn: conn} do
      conn =
        conn
        |> init_test_session([])
        |> put_session(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> get("/")

      assert html_response(conn, 200) =~ "Sign out"
    end
  end
end
