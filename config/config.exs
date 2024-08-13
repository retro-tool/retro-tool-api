# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :retro,
  ecto_repos: [Xrt.Repo]

# Configures the endpoint
config :retro, XrtWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0pGsyh3H8V2YBtkrRn5p5hvffAr5Vt1/uPby4XWc5f8qzlWBLz1QKhaB9LlDf2IS",
  render_errors: [view: XrtWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Xrt.PubSub,
  live_view: [signing_salt: "SALT"]

# Configures Elixir's Logger
config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sentry,
  included_environments: ["prod"],
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
