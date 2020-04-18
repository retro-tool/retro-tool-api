defmodule XrtWeb.Router do
  use XrtWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug XrtWeb.Graphql.Context
  end

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: System.get_env("ADMIN_PASSWORD")
  end

  forward "/api/graphiql", Absinthe.Plug.GraphiQL, schema: XrtWeb.Schema

  scope "/api" do
    pipe_through :api

    forward "/graph", Absinthe.Plug, schema: XrtWeb.Schema
  end

  scope "/" do
    pipe_through [:browser, :admins_only]

    live_dashboard "/api/dashboard"
  end
end
