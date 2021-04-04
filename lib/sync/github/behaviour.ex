defmodule Sync.Github.Behaviour do
  @callback list_repo_users!(String.t(), String.t()) :: [Sync.Github.User.t()]
  @callback list_repo_prs!(String.t(), String.t(), Keyword.t()) :: [Sync.Github.PR.t()]
  @callback authorize_url() :: String.t()
  @callback get_user_from_code!(String.t()) :: User.t()
end
