defmodule Sync.Github do
  @behaviour Sync.Github.Behaviour

  alias Sync.Github.{PR, User}
  alias Sync.HTTPClient

  require Logger

  @base_url "https://github.com"
  @base_api_url "https://api.github.com"
  @per_page 100

  @impl true
  def list_repo_users!(owner, repo, base_api_url \\ @base_api_url) do
    url = base_api_url <> "/repos/#{owner}/#{repo}/contributors"

    query_params = %{
      per_page: @per_page
    }

    headers = [{"Accept", "application/vnd.github.v3+json"}]

    {:ok, %HTTPClient.JsonResponse{body: body}} =
      HTTPClient.json_request(:get, url, headers: headers, query_params: query_params)

    Enum.map(body, fn %{id: id, login: login} ->
      %User{id: id, name: login}
    end)
  end

  @impl true
  def list_repo_prs!(owner, repo, opts \\ []) do
    base_api_url = Keyword.get(opts, :base_api_url, @base_api_url)

    url = base_api_url <> "/repos/#{owner}/#{repo}/pulls"

    query_params = %{
      page: opts[:page] || 1,
      per_page: opts[:per_page] || @per_page,
      state: "all",
      sort: "created",
      direction: "asc"
    }

    headers = [{"Accept", "application/vnd.github.v3+json"}]

    case HTTPClient.json_request(:get, url, headers: headers, query_params: query_params) do
      {:ok, %HTTPClient.JsonResponse{status: 200, body: body}} ->
        Enum.map(body, fn %{id: id, title: title, body: body} ->
          %PR{id: id, title: title, body: body}
        end)

      {:ok, %HTTPClient.JsonResponse{status: 403, body: %{message: message}}} ->
        Logger.warn(message)
        []
    end
  end

  @impl true
  def authorize_url do
    url = @base_url <> "/login/oauth/authorize"
    query_params = %{client_id: client_id()}
    HTTPClient.Helpers.build_url(url, query_params)
  end

  @impl true
  def get_user_from_code!(code, base_url \\ @base_url, base_api_url \\ @base_api_url) do
    code
    |> exchange_code_for_access_token!(base_url)
    |> get_user_from_access_token!(base_api_url)
  end

  defp exchange_code_for_access_token!(code, base_url) do
    url = base_url <> "/login/oauth/access_token"
    headers = [{"Accept", "application/json"}]

    body_params = %{
      code: code,
      client_id: client_id(),
      client_secret: client_secret()
    }

    {:ok, %HTTPClient.JsonResponse{body: %{access_token: access_token}}} =
      HTTPClient.json_request(:post, url, headers: headers, body_params: body_params)

    access_token
  end

  defp get_user_from_access_token!(token, base_api_url) do
    url = base_api_url <> "/user"

    headers = [
      {"Accept", "application/vnd.github.v3+json"},
      {"Authorization", "token " <> token}
    ]

    {:ok, %HTTPClient.JsonResponse{status: 200, body: body}} = HTTPClient.json_request(:get, url, headers: headers)

    struct(User, body)
  end

  defp client_id do
    Application.get_env(:sync, __MODULE__)[:client_id]
  end

  defp client_secret do
    Application.get_env(:sync, __MODULE__)[:client_secret]
  end
end
