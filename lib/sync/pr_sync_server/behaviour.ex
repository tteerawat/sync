defmodule Sync.PRSyncServer.Behaviour do
  @callback list_prs :: [Sync.Github.PR.t()]
  @callback list_users :: [Sync.Github.User.t()]
end
