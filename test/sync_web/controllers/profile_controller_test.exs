defmodule SyncWeb.ProfileControllerTest do
  use SyncWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "GET /profile" do
    test "lists repo users", %{conn: conn} do
      expect(Sync.MockPRSyncServer, :list_users, fn ->
        [
          %Sync.Github.User{id: 1, name: "test"},
          %Sync.Github.User{id: 10, name: "conan"}
        ]
      end)

      conn =
        conn
        |> init_test_session([])
        |> put_session(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> get("/profile")

      assert response = html_response(conn, 200)
      assert response =~ "Profile"
      assert response =~ "Click the name to map your user to"
      assert response =~ "test"
      assert response =~ "conan"
    end
  end

  describe "POST /profile" do
    test "map current_user to the selected github user", %{conn: conn} do
      conn =
        conn
        |> init_test_session([])
        |> put_session(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> post("/profile", %{"id" => 10, "name" => "conan"})

      assert get_flash(conn, :info) == "You have been mapped to conan!"
      assert redirected_to(conn) == "/events"
    end
  end
end
