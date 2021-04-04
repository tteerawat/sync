defmodule Sync.Github do
  defmodule User do
    defstruct [:id, :name]

    @type t :: %__MODULE__{
            id: non_neg_integer(),
            name: String.t()
          }
  end

  defmodule PR do
    defstruct [:title, :body]

    @type t :: %__MODULE__{
            title: String.t(),
            body: String.t()
          }
  end

  alias Sync.HTTPClient

  @base_api_url "https://api.github.com"
  @per_page 100

  @spec list_repo_users!(String.t(), String.t(), String.t()) :: [User.t()]
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

  @spec list_repo_prs!(String.t(), String.t(), String.t()) :: [PR.t()]
  def list_repo_prs!(owner, repo, base_api_url \\ @base_api_url) do
    url = base_api_url <> "/repos/#{owner}/#{repo}/pulls"

    query_params = %{
      per_page: @per_page,
      state: "all",
      sort: "created"
    }

    headers = [{"Accept", "application/vnd.github.v3+json"}]

    {:ok, %HTTPClient.JsonResponse{body: body}} =
      HTTPClient.json_request(:get, url, headers: headers, query_params: query_params)

    Enum.map(body, fn %{title: title, body: body} ->
      %PR{title: title, body: body}
    end)
  end
end
