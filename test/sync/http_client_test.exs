defmodule Sync.HTTPClientTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Sync.HTTPClient

  setup do
    {:ok, bypass: Bypass.open()}
  end

  describe "json_request/3" do
    test "returns {:ok, response}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/todos/1", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"comleted\":false,\"id\":1}")
      end)

      result = HTTPClient.json_request(:get, "http://localhost:#{bypass.port}/todos/1")

      assert result ==
               {:ok,
                %HTTPClient.JsonResponse{
                  status: 200,
                  body: %{id: 1, comleted: false}
                }}
    end

    test "returns {:error, exception}", %{bypass: bypass} do
      Bypass.down(bypass)

      error_message =
        capture_log(fn ->
          result = HTTPClient.json_request(:get, "http://localhost:#{bypass.port}/todos/1")

          assert result == {:error, %Mint.TransportError{reason: :econnrefused}}
        end)

      assert error_message =~ "[error]"
    end
  end
end
