defmodule Sync.PRSyncServerTest do
  use ExUnit.Case

  import Mox

  alias Sync.PRSyncServer

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    expect(Sync.MockGithub, :list_repo_prs!, fn "serokell", "test", _ ->
      []
    end)

    pid = start_supervised!({PRSyncServer, owner: "serokell", repo: "test", per_page: 10, delay_on_app_start: 0})

    :timer.sleep(300)

    {:ok, pid: pid}
  end

  describe "start_link/1" do
    test "set state correctly", %{pid: pid} do
      state = :sys.get_state(pid)

      assert state == %{
               owner: "serokell",
               repo: "test",
               page: 1,
               per_page: 10,
               prs: []
             }
    end
  end

  describe "list_prs/0" do
    test "returns prs from state" do
      result = PRSyncServer.list_prs()

      assert result == []
    end
  end
end
