defmodule Sync.Github.User do
  defstruct [:id, :name]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          name: String.t()
        }
end
