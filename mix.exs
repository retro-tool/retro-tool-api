defmodule Xrt.MixProject do
  use Mix.Project

  def project do
    [
      app: :retro,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Xrt.Application, []},
      extra_applications: apps(Mix.env())
    ]
  end

  def apps(env \\ nil)

  def apps(:test) do
    [:ex_machina | apps()]
  end

  def apps(_) do
    [:logger, :runtime_tools, :absinthe_plug, :ecto_sql]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.16"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto, "~> 3.4", override: true},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:absinthe, "~> 1.4.0"},
      {:absinthe_phoenix, "~> 1.4.0"},
      {:absinthe_plug, "~> 1.4"},
      {:poison, "~> 3.0"},
      {:elixir_uuid, "~> 1.2"},
      {:ecto_enum, "~> 1.1"},
      {:ex_machina, "~> 2.2"},
      {:stream_data, "~> 0.1", only: :test},
      {:distillery, "~> 2.0", runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:basic_auth, "~> 2.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
