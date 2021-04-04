defmodule SyncWeb.AuthController do
  use SyncWeb, :controller

  @github Application.compile_env!(:sync, :github)

  def sign_in(conn, _) do
    redirect(conn, external: @github.authorize_url())
  end

  def sign_out(conn, _) do
    conn
    |> put_flash(:info, "Bye :)")
    |> delete_session(:current_user)
    |> redirect(to: "/")
  end

  def callback(conn, %{"code" => code}) do
    current_user = @github.get_user_from_code!(code)

    conn
    |> put_flash(:info, "Welcome #{current_user.name}!")
    |> put_session(:current_user, current_user)
    |> put_session(:current_mapped_user, current_user)
    |> redirect(to: "/profile")
  end
end
