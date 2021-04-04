defmodule SyncWeb.EventControllerTest do
  use SyncWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "GET /events" do
    test "lists repo prs that has a mention to current mapped user", %{conn: conn} do
      expect(Sync.MockPRSyncServer, :list_prs, fn ->
        [
          %Sync.Github.PR{id: 1, body: "Please help @conan"},
          %Sync.Github.PR{id: 2, body: "Body without mention"}
        ]
      end)

      conn =
        conn
        |> init_test_session([])
        |> put_session(:current_user, %Sync.Github.User{id: 1, name: "test"})
        |> put_session(:current_mapped_user, %Sync.Github.User{id: 10, name: "conan"})
        |> get("/events")

      assert html_response(conn, 200) =~ "Please help @conan"
      refute html_response(conn, 200) =~ "Body without mention"
    end
  end
end
