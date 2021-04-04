defmodule Sync.Github.PR do
  defstruct [:id, :title, :body]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          title: String.t(),
          body: String.t()
        }
end
