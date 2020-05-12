import Config

config :retro, XrtWeb.Endpoint,
  http: [port: 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  check_origin: false

config :retro, Xrt.Repo,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool_size: 15

config :retro, XrtWeb.Endpoint, live_view: [signing_salt: System.get_env("SECRET_SALT")]

config :retro,
  dashboard_auth: [
    username: System.get_env("DASHBOARD_USER"),
    password: System.get_env("DASHBOARD_PASSWORD"),
    realm: System.get_env("DASHBOARD_REALM")
  ]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: System.get_env("SENTRY_ENVIRONMENT"),
