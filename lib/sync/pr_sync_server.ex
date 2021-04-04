defmodule Sync.PRSyncServer do
  use GenServer

  require Logger

  @github Application.compile_env!(:sync, :github)
  @interval :timer.seconds(15)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec list_prs :: [Sync.Github.PR.t()]
  def list_prs do
    GenServer.call(__MODULE__, :list_prs)
  end

  @impl true
  def init(opts) do
    initial_state = %{
      owner: Keyword.fetch!(opts, :owner),
      repo: Keyword.fetch!(opts, :repo),
      page: 1,
      per_page: Keyword.get(opts, :per_page, 50),
      prs: []
    }

    delay_on_app_start = Keyword.get(opts, :delay_on_app_start, :timer.seconds(5))
    Process.send_after(self(), :sync, delay_on_app_start)

    {:ok, initial_state}
  end

  @impl true
  def handle_call(:list_prs, _, state) do
    {:reply, state.prs, state}
  end

  @impl true
  def handle_info(:sync, %{owner: owner, repo: repo, prs: current_prs, page: page, per_page: per_page} = state) do
    Logger.info("Syncing PRs ...")

    prs = @github.list_repo_prs!(owner, repo, page: page, per_page: per_page)

    new_page =
      case Enum.count(prs) do
        ^per_page ->
          # move to the next page
          page + 1

        _less_than_per_page ->
          # stay at the current page
          page
      end

    new_state = %{
      state
      | page: new_page,
        prs: Enum.uniq_by(current_prs ++ prs, & &1.id)
    }

    Process.send_after(self(), :sync, @interval)

    {:noreply, new_state}
  end
end
