defmodule Sync.HTTPClient do
  defmodule JsonResponse do
    defstruct [:status, :body]

    @type t :: %__MODULE__{
            status: non_neg_integer(),
            body: term()
          }
  end

  require Logger

  @json_content_type_header {"Content-Type", "application/json"}

  @spec json_request(atom(), String.t(), Keyword.t()) ::
          {:ok, JsonResponse.t()} | {:error, {:error, Mint.Types.error()}}
  def json_request(method, url, opts \\ []) do
    headers = Keyword.get(opts, :headers, [])
    body_params = Keyword.get(opts, :body_params, nil)

    headers_with_content_type = [@json_content_type_header | headers]
    body = maybe_build_json_body(body_params)

    result =
      method
      |> Finch.build(url, headers_with_content_type, body)
      |> Finch.request(Sync.Finch)

    case result do
      {:ok, %Finch.Response{} = response} ->
        json_response = %JsonResponse{
          status: response.status,
          body: Jason.decode!(response.body, keys: :atoms)
        }

        {:ok, json_response}

      {:error, exception} ->
        Logger.error(fn -> inspect(exception) end)

        {:error, exception}
    end
  end

  defp maybe_build_json_body(nil), do: nil
  defp maybe_build_json_body(%{} = body_params), do: Jason.encode!(body_params)
end
