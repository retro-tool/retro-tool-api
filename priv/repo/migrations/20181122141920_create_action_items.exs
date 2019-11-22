defmodule Xrt.Repo.Migrations.CreateActionItems do
  use Ecto.Migration

  def change do
    create table(:action_items) do
      add :title, :string, null: false
      add :completed, :boolean
      add :retro_id, references(:retros), null: false
      timestamps()
    end
  end
end
