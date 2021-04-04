defmodule SyncWeb.Router do
  use SyncWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SyncWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SyncWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/sign-in", AuthController, :sign_in
    delete "/sign-out", AuthController, :sign_out
    get "/auth/callback", AuthController, :callback

    get "/profile", ProfileController, :show
    post "/profile", ProfileController, :map_user

    get "/events", EventController, :index
  end
end
