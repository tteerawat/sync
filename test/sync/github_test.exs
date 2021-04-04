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

  describe "list_repo_prs!/4" do
    test "returns a list of github pull requests of the given repo", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/repos/serokell/test/pulls", fn conn ->
        Plug.Conn.resp(conn, 200, "[{\"id\": 1, \"body\":\"test\",\"title\":\"test\"}]")
      end)

      base_api_url = "http://localhost:#{bypass.port}"

      result = Github.list_repo_prs!("serokell", "test", base_api_url: base_api_url)

      assert result == [
               %Github.PR{id: 1, title: "test", body: "test"}
             ]
    end
  end

  describe "authorize_url/0" do
    test "returns aurhtorize url with client id" do
      result = Github.authorize_url()

      assert result == "https://github.com/login/oauth/authorize?client_id=client-id-123"
    end
  end

  describe "get_user_from_code!/1" do
    test "returns user from the given code", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/login/oauth/access_token", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"access_token\":\"token-123\"}")
      end)

      Bypass.expect(bypass, "GET", "/user", fn conn ->
        assert {"authorization", "token token-123"} in conn.req_headers
        assert {"accept", "application/vnd.github.v3+json"} in conn.req_headers

        Plug.Conn.resp(conn, 200, "{\"id\": 1, \"name\": \"test\"}")
      end)

      code = "123"
      base_url = "http://localhost:#{bypass.port}"
      base_api_url = "http://localhost:#{bypass.port}"

      result = Github.get_user_from_code!(code, base_url, base_api_url)

      assert result == %Sync.Github.User{id: 1, name: "test"}
    end
  end
end
