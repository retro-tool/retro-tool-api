defmodule Xrt.Release do
  @moduledoc """
  Tasks to run on a elixir release:

  Example:

    ./release eval "Xrt.Release.migrate"
  """

  @app :retro

  @spec migrate() :: any()
  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @spec rollback(repo :: module(), String.t()) :: any()
  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
