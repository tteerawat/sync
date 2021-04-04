defmodule Sync.GithubTest do
  use ExUnit.Case, async: true

  alias Sync.Github

  setup do
    {:ok, bypass: Bypass.open()}
  end

  describe "list_repo_users!/3" do
    test "returns a list of github user of the given repo", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/repos/serokell/test/contributors", fn conn ->
        Plug.Conn.resp(conn, 200, "[{\"id\":1,\"login\":\"a\"},{\"id\":2,\"login\":\"b\"}]")
      end)

      base_api_url = "http://localhost:#{bypass.port}"

      result = Github.list_repo_users!("serokell", "test", base_api_url)

      assert result == [
               %Github.User{id: 1, name: "a"},
               %Github.User{id: 2, name: "b"}
             ]
    end
  end

  describe "list_repo_prs!/3" do
    test "returns a list of github pull requests of the given repo", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/repos/serokell/test/pulls", fn conn ->
        Plug.Conn.resp(conn, 200, "[{\"body\":\"test\",\"title\":\"test\"}]")
      end)

      base_api_url = "http://localhost:#{bypass.port}"

      result = Github.list_repo_prs!("serokell", "test", base_api_url)

      assert result == [
               %Github.PR{title: "test", body: "test"}
             ]
    end
  end
end
