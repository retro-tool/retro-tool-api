defmodule Xrt.Repo.Migrations.CreateRetros do
  use Ecto.Migration

  def change do
    create table(:retros) do
      add :slug, :string
      timestamps()
    end
  end
end
