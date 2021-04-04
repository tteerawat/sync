defmodule SyncWeb.AuthControllerTest do
  use SyncWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "GET /sign-in" do
    test "redirects to github authorize url", %{conn: conn} do
      expect(Sync.MockGithub, :authorize_url, fn -> "http://test-url.com" end)

      conn = get(conn, "/sign-in")

      assert redirected_to(conn) == "http://test-url.com"
    end
  end

  describe "DELETE /sign-out" do
    test "clears session and redirects to homepage", %{conn: conn} do
      conn =
        conn
        |> init_test_session([])
        |> put_session(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> delete("/sign-out")

      assert get_session(conn, :current_user) == nil
      assert get_flash(conn, :info) =~ "Bye"
      assert redirected_to(conn) == "/"
    end
  end

  describe "GET /auth/callback" do
    test "assigns user and redirects to /profile page", %{conn: conn} do
      user = %Sync.Github.User{id: 1, name: "test"}
      expect(Sync.MockGithub, :get_user_from_code!, fn "test-code" -> user end)

      conn = get(conn, "/auth/callback", %{"code" => "test-code"})

      assert get_session(conn, :current_user) == user
      assert get_session(conn, :current_mapped_user) == user
      assert get_flash(conn, :info) =~ "Welcome test!"
      assert redirected_to(conn) == "/profile"
    end
  end
end
