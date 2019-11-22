defmodule Xrt.Repo.Migrations.CreateRetroItems do
  use Ecto.Migration

  def change do
    create table(:retro_items) do
      add :title, :string
      add :retro_id, references(:retros)
      timestamps()
    end
  end
end
