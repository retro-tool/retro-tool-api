defmodule Xrt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Xrt.Repo,
      XrtWeb.Monitoring.Dashboard,
      # Start the endpoint when the application starts
      XrtWeb.Endpoint,
      # Start the absinthe subsctiption server when the application starts
      absinthe_subscriptions(XrtWeb.Endpoint)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xrt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    XrtWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @spec absinthe_subscriptions(atom) :: %{
          type: :supervisor,
          id: Absinthe.Subscription,
          start: {Absinthe.Subscription, :start_link, [atom]}
        }
  def absinthe_subscriptions(name) do
    %{
      type: :supervisor,
      id: Absinthe.Subscription,
      start: {Absinthe.Subscription, :start_link, [name]}
    }
  end
end
