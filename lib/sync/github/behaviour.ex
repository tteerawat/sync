defmodule Sync.Github.Behaviour do
  @callback list_repo_prs!(String.t(), String.t(), Keyword.t()) :: [Sync.Github.PR.t()]
end
